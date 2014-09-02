class SDL::Base::Type::Service < SDL::Base::Type
  include SDL::Types::SDLType

  include ActiveSupport::Inflector

  include Mongoid::Document
  include Mongoid::Timestamps

  # THIS IS THE VERSION ID, NOT THE SERVICE ID !
  field :_id, type: String, default: -> { SecureRandom.uuid }

  field :service_id, type: String, default: -> { SecureRandom.uuid }

  field :service_deleted, type: Boolean, default: false

  index({ service_id: 1 }, { unique: false, name: 'service_id' })

  field :identifier, type: Symbol
  field :sdl_parts, type: Hash, default: {}

  def self.latest_approved(service_id)
    where(:service_id => service_id, 'status.identifier' => 'approved', 'service_deleted' => false).sort(:updated_at => -1).limit(1).first
  end

  def self.versions(service_id)
    versions = where(service_id: service_id).order(updated_at: -1).only(:_id, :service_id, :status, :service_deleted, :created_at, :updated_at).to_a

    versions.select{|v| (v.status.identifier == :approved) && !v.service_deleted?}.each do |version|
      if(@newer_updated_at)
        newer_updated_at = @newer_updated_at.clone
        version.define_singleton_method :valid_until do
          newer_updated_at
        end
      end

      def version.valid_from
        updated_at
      end

      @newer_updated_at = version.updated_at
    end

    versions
  end

  def self.latest_with_status(status_identifier, deleted = false)
    @id_version_updated = collection.aggregate(
      {'$match' => {
          'status.identifier' => status_identifier,
          'service_deleted' => deleted
      }},
      {'$sort' => {:service_id => 1, :updated_at => -1}},
      {'$group' => {
          :_id => '$service_id',
          :updated_at => {
              '$first' => '$updated_at'
          },
          :version_id => {
              '$first' => '$_id'
          }
        }
      }
    )

    where(:_id => {'$in' => @id_version_updated.collect{|ivu|ivu[:version_id]}})
  end

  has_many :service_bookings

  def to_service_sdl
    combine_service_sdl_parts sdl_parts
  end

  def combine_service_sdl_parts(sdl_parts)
    sdl = StringIO.new

    sdl_parts.each do |key, part|
      sdl << "#BEGIN #{key}\r\n"
      part.lines.each do |line|
        sdl << "#{line}\r\n"
      end
      sdl << "#END #{key}\r\n"
    end

    sdl.string
  end

  def load_service_from_sdl(filename = nil)
    self.class.properties.each do |property|
      unless self[property.name].blank?
        self.send "#{property.name}=", nil
      end
    end

    receiver = SDL::Receivers::TypeInstanceReceiver.new(self)

    receiver.instance_eval(to_service_sdl, filename || 'service_sdl')

    self
  end

  def unload

  end

  def new_draft
    sdl_parts_draft = Hash.new.update(sdl_parts)

    sdl_parts_draft['meta'].gsub!('approved', 'draft')

    Service.new(sdl_parts: sdl_parts_draft, service_id: service_id).load_service_from_sdl
  end

  class << self
    def add_property_setters(sym, type, multi)
      if multi
        embeds_many sym, as: type.name.demodulize.pluralize.underscore.to_sym, class_name: type.name, inverse_of: nil
      else
        embeds_one sym, as: type.name.demodulize.underscore.to_sym, class_name: type.name, inverse_of: nil
      end
    end
  end

  wraps self
  codes local_name.underscore.to_sym

  superclass.subtypes << self

  @registered = true
end