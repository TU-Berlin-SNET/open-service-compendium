require 'sdl'

class ServiceController < ApplicationController
  respond_to :html, :xml, :json, :rdf

  def list
    @services = compendium.services
  end

  def show
    @service = compendium.services[params[:id]]
  end

  private
    def compendium
      @compendium ||= ServiceController.build_compendium
    end

    def self.build_compendium
      compendium = SDL::Base::ServiceCompendium.new

      sdl_gem_dir = Gem::Specification.find_by_name('sdl-ng').gem_dir

      # Load SDL
      Dir.glob(File.join(sdl_gem_dir, 'examples', '**', '*.sdl.rb')) do |filename|
        compendium.facts_definition do
          eval(File.read(filename), binding, filename)
        end
      end

      # Load Service Definitions
      Dir.glob(File.join(sdl_gem_dir, 'examples', '**', '*.service.rb')) do |filename|
        compendium.service filename.match(%r[.+/(.+).service.rb])[1] do
          eval(File.read(filename), binding, filename)
        end
      end

      compendium
    end
end
