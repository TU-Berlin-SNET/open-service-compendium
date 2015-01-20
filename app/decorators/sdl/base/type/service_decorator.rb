class SDL::Base::Type::ServiceDecorator < Draper::Decorator
  delegate_all

  def table_hash(holder = object)
    if holder.class < SDL::Base::Type
      begin
        h.render "type_instance_#{holder.class.local_name.underscore}", instance: holder
      rescue ActionView::MissingTemplate
        puts "Cannot find #{"type_instance_#{holder.class.local_name.underscore}"}"

        @property_hash = property_hash(holder)

        if @property_hash.blank?
          holder.documentation
        else
          @property_hash
        end
      end
    elsif holder.class < SDL::Types::SDLSimpleType
      h.render "value_#{holder.class.name.demodulize.underscore}", value: holder
    else
      holder.map do |item|
        table_hash item
      end
    end
  end

  def property_hash(holder)
    Hash[
      holder.property_values.map do |property, value|
        [property.documentation, table_hash(value)]
      end
    ]
  end

  def table_view
    h.make_table(class: 'service_table') do |t|
      table_view_recursive(object, t)
    end
  end

  def table_view_recursive(holder, t)
    holder.property_values.each do |property, value|
      t.row do
        t.td class: "property #{property.name}" do property.documentation end

        if value.class < SDL::Base::Type
          render_value(value, t)
        elsif value.class < SDL::Types::SDLSimpleType
          t.td h.render "value_#{value.class.name.demodulize.underscore}", value: value
        elsif value.is_a? Array
          t.column do
            value.each do |item|
              render_value item, t
            end
          end
        else
          t.td "Error. Cannot render #{value.class.to_s}."
        end
      end
    end
  end

  def render_value(value, t)
    begin
      t.td h.render "type_instance_#{value.class.local_name.underscore}", instance: value
    rescue ActionView::MissingTemplate
      if value.property_values.blank?
        t.td value.documentation
      else
        t.column do
          table_view_recursive value, t
        end
      end
    end
  end
end