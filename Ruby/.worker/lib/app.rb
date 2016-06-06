module ZooRack
  class App
    DEFAULT_ENV = 'production'.freeze


    def initialize
      # Full physical path to application root.
      @root_path = ENV[ 'APPL_PHYSICAL_PATH' ].freeze

      # Note! It's important to have this set before bundle setup, otherwise dev mode will be used.
      ENV[ 'RAILS_ENV' ] = ENV[ 'RACK_ENV' ] ||= DEFAULT_ENV

      # Use bundled gems if applicable
      bundle_setup

      build_app
    end


    def build_app
      config_ru = File.join( @root_path, 'config.ru' )
      if File.exist?( config_ru )
        assure_rack
        inner_app = build_config_ru( config_ru )
      else
        # Let's see if it's Rails 2.3, lower versions aren't supported.
        require File.join( @root_path, 'config/boot.rb' )
        require File.join( @root_path, 'config/environment.rb' )

        defined?( Rails::VERSION::STRING ) or raise 'Could\'t determine Rails version.'

        if 2 != Rails::VERSION::MAJOR or 3 != Rails::VERSION::MINOR
          raise 'Only Rails 2.3.x and Rails 3.x are currently supported.'
        end

        inner_app = rails2_dispatcher
        assure_rack
      end

      # This env tells Rails a prefix to add before assets.
      virtual_path = ENV[ 'APPL_VIRTUAL_PATH' ] || ''
      ENV[ 'RAILS_RELATIVE_URL_ROOT' ] = virtual_path

      map_path = ( virtual_path.empty? ? '/' : virtual_path )
      @app = Rack::Builder.new {
        if 'development' == ENV[ 'RAILS_ENV' ]
          __debug__ 'Dev mode.'
          use Rack::CommonLogger, $stderr
          use Rack::ShowExceptions
          use Rack::Lint
        end

        map( map_path ) do
          unless defined? ActionDispatch::Static
            use Rails::Rack::Static if defined? Rails
          end

          run inner_app
        end
      }.to_app
    end


    def call( env )
      @app.call( env )
    end


    def rails2_dispatcher
      return ActionController::Dispatcher.new if defined? ActionController::Dispatcher
      raise 'Couldn\'t load Rails 2.3 dispatcher'
    end


    def build_config_ru( config_ru )
      raw = File.read( config_ru )
      raw.sub!( /^__END__\n.*/, '' )

      eval( "::Rack::Builder.new {(#{raw}\n)}.to_app", TOPLEVEL_BINDING, config_ru )
    end


    def assure_rack
      eval( "require 'rack'" ) unless defined? Rack
      eval( "require 'rack/rewindable_input'" ) unless defined? Rack::RewindableInput

      __debug__ "Rack version: #{Rack::release}"
    end


    # Make sure we don't conflict with bundled gems
    def bundle_setup
      return unless File.exist?( File.join( @root_path, 'Gemfile' ) )

      begin
        Dir.chdir( @root_path )
        require 'bundler/setup'
      rescue LoadError => e
        __error__ "Couldn't run bundler/setup: #{e}"
      end
    end
  end
end