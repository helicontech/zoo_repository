module ZooRack
  class Worker
    def initialize
      @app = App.new
      @buffers = {}
      @socket = new_socket
    end


    def new_socket
      input = IO.new( $stdin.fileno, 'w+b' )
      input.binmode
      input.sync = true

      input
    end


    def run
      loop { process }
    end


    def process
      # Extract header
      header = @socket.readpartial( Record::HEADER_LENGTH )
      version, type, reqid, content_length, padding_length, reserved = *Record.parse_header( header )

      # Read body
      record_data = @socket.readpartial( content_length )
      @socket.readpartial( padding_length )

      record = Record.class_for( type ).parse( reqid, record_data )

      if request = next_request( record )
        handle_request( request )
      end
    end


    def handle_request( request )
      request.serve
      respond_to( request, FCGI_REQUEST_COMPLETE )
    end


    def next_request( rec )
      if rec.management_record?
        handle_management_record( rec )
        return nil
      end

      case rec.type
        when FCGI_BEGIN_REQUEST
          @buffers[ rec.request_id ] = RecordBuffer.new( rec )

        when FCGI_ABORT_REQUEST
          raise 'got ABORT_REQUEST' # FIXME
        else
          buf = @buffers[ rec.request_id ] or return nil # inactive request
          buf.push rec

          if buf.ready? # We've got complete request
            @buffers.delete rec.request_id
            return buf.new_request( @app )
          end
      end

      nil
    end


    def send_record( rec )
      @socket.write( rec.serialize )
    end


    def handle_management_record( rec )
      case rec.type
        when FCGI_GET_VALUES
          send_record( handle_get_values( rec ) )
        else
          send_record( UnknownTypeRecord.new( rec.request_id, rec.type ) )
        end
    end


    def handle_get_values(rec)
      h = {}
      rec.values.each_key do |name|
        h[ name ] = FCGI_DEFAULT_PARAMS[name]
      end

      ValuesRecord.new( FCGI_GET_VALUES_RESULT, rec.request_id, h )
    end


    def respond_to( req, status )
      split_data( FCGI_STDOUT, req.id, req.out ) do |rec|
        send_record rec
      end

      # split_data( FCGI_STDERR, req.id, req.err ) do |rec|
      #   send_record rec
      # end if req.err.length > 0

      send_record EndRequestRecord.new( req.id, 0, status )
    end


    DATA_UNIT = 16384
    def split_data( type, id, f )
      unless f.length == 0
        f.rewind
        while s = f.read( DATA_UNIT )
          yield GenericDataRecord.new( type, id, s )
        end
      end

      yield GenericDataRecord.new( type, id, '' )
    end

  end
end