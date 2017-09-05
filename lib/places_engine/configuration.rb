module PlacesEngine
  require 'erb'
  require 'yaml'

  class Configuration
  #
  # PlacesEngine::Configuration is configured via the config/places_engine.yml file, which
  # contains properties keyed by environment name. A sample places_engine.yml file
  # would look like:
  # production:
  #   geoserver:
  #     hostname: dev.thlib.org
  #     port: 8080
  #     scheme: https
  #     path: /thlib-geoserver
  #
  # development:
  #   geoserver:
  #     hostname:  localhost
  #     port: 8080
  #     scheme: http
  #     path: /thlib-geoserver
  #
  # test:
  #   geoserver:
  #     hostname: localhost
  #     port: 8080
  #     scheme: http
  #     path: /thlib-geoserver

    attr_writer :user_configuration

    #
    # The host name at which to connect to Geoserver. Default 'localhost'.
    #
    # ==== Returns
    #
    # String:: host name
    #
    def hostname
      unless defined?(@hostname)
        @hostname ||= user_configuration_from_key('geoserver', 'hostname')
        @hostname ||= default_hostname
      end
      @hostname
    end
    #
    # The port at which to connect to Geoserver.
    # Defaults to 8080
    #
    # ==== Returns
    #
    # Integer:: port
    #
    def port
      unless defined?(@port)
        @port ||= user_configuration_from_key('geoserver', 'port')
        @port   = @port.to_i if !@port.blank?
      end
      @port
    end
    #
    # The scheme to use, http or https.
    # Defaults to http
    #
    # ==== Returns
    #
    # String:: scheme
    #
    def scheme
      unless defined?(@scheme)
        @scheme ||= user_configuration_from_key('geoserver', 'scheme')
        @scheme ||= default_scheme
      end
      @scheme
    end

    #
    # The url path to the Geoserver
    # Default '/geoserver'.
    #
    # ==== Returns
    #
    # String:: path
    #
    def path
      unless defined?(@path)
        @path ||= user_configuration_from_key('geoserver', 'path')
        @path ||= default_path
      end
      @path
    end

    def default_hostname
      'localhost'
    end

    def default_scheme
      'http'
    end

    def default_path
      '/geoserver'
    end

    def geoserver_url(u = nil)
      res = "#{scheme}://"
      res << "#{hostname}"
      res << "#{u}@" if !u.blank?
      res << ":#{port}" if !port.blank?
      res << "#{path}"
    end

    #
    # return a specific key from the user configuration in config/places_engine.yml
    #
    # ==== Returns
    #
    # Mixed:: requested_key or nil
    #
    def user_configuration_from_key( *keys )
      keys.inject(user_configuration) do |hash, key|
        hash[key] if hash
      end
    end

    #
    # Memoized hash of configuration options for the current Rails environment
    # as specified in config/places_engine.yml
    #
    # ==== Returns
    #
    # Hash:: configuration options for current environment
    #
    def user_configuration
      @user_configuration ||=
        begin
          path = File.join(::Rails.root, 'config', 'places_engine.yml')
          if File.exist?(path)
            File.open(path) do |file|
              processed = ERB.new(file.read).result
              YAML.load(processed)[::Rails.env]
            end
          else
            {}
          end
        end
    end
  end
end
