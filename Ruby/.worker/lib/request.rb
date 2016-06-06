module ZooRack
  class Request
    PRESET_ENV = {
      'rack.version' => [1, 1],
      'rack.multithread' => false,
      'rack.multiprocess' => false,
      'rack.run_once' => false,

      # it's important to set this variable, otherwise rack 1.1.x would scream.
      'SCRIPT_NAME' => ''
    }.freeze

    def initialize( app, id, env, stdin, data = nil )
      @app = app
      @id = id
      @env = env
      @in = stdin
      @out = StringIO.new
      @err = StringIO.new
      @data = data || StringIO.new
    end

    attr_reader :id
    attr_reader :env
    attr_reader :in
    attr_reader :out
    attr_reader :err
    attr_reader :data


    def serve
      parts = @env[ 'REQUEST_URI' ].split( '?' )
      @env[ 'PATH_INFO' ] = parts[ 0 ]
      @env[ 'QUERY_STRING' ] = parts[ 1 ].to_s

      @env[ 'HTTP_VERSION' ] ||= @env[ 'SERVER_PROTOCOL' ]
      @env[ 'REQUEST_PATH' ] ||= '/'

      @env.delete 'CONTENT_TYPE' if @env[ 'CONTENT_TYPE' ] == ''
      @env.delete 'CONTENT_LENGTH' if @env[ 'CONTENT_LENGTH' ] == ''

      ## Rack: The environment must not contain the keys
      ## HTTP_CONTENT_TYPE or HTTP_CONTENT_LENGTH
      ## (use the versions without HTTP_).
      @env.delete 'HTTP_CONTENT_TYPE'
      @env.delete 'HTTP_CONTENT_LENGTH'

      rack_input = Rack::RewindableInput.new( @in )
      @env[ 'rack.input' ] = rack_input
      @env[ 'rack.errors' ] = @err
      @env[ 'rack.url_scheme' ] = [ 'yes', 'on', '1' ].include?( @env[ 'HTTPS' ] ) ? 'https' : 'http'
      @env.update( PRESET_ENV )

      status, headers, body = @app.call( @env )

      begin
        send_headers( @out, status, headers )
        send_body( @out, body )
      ensure
        body.close if body.respond_to? :close
      end
    ensure
      rack_input.close if rack_input.respond_to? :close
    end


    def send_headers( out, status, headers )
      status_code = ZooRack::HTTP_STATUS_CODES[ status ] || ''
      out.print "Status: #{status} #{status_code}\r\n"
      headers.each do |k, vs|
        vs.split( "\n" ).each { |v| out.print "#{k}: #{v}\r\n" }
      end

      out.print "\r\n"
      out.flush
    end


    def send_body( out, body )
      return if body.nil?

      body.each do |part|
        out.print part
        out.flush
      end
    end
  end
end