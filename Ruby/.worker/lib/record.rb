module ZooRack

  class RecordBuffer
    def initialize( rec )
      @begin_request = rec
      @envs = []
      @stdins = []
      @datas = []
    end

    def push( rec )
      case rec
        when ParamsRecord
          @envs.push rec

        when StdinDataRecord
          @stdins.push rec

        when DataRecord
          @datas.push rec

        else
          raise "got unknown record: #{rec.class}"
      end
    end

    def ready?
      case @begin_request.role
        when FCGI_RESPONDER
          completed? @envs and completed? @stdins

        when FCGI_AUTHORIZER
          completed? @envs

        when FCGI_FILTER
          completed? @envs and completed? @stdins and completed? @datas

        else
          raise "unknown role: #{@begin_request.role}"
      end
    end

    def completed?( records )
      records.last and records.last.empty?
    end
    private :completed?

    def new_request( app )
      Request.new( app, @begin_request.request_id, env(), stdin(), data() )
    end

    def env
      h = {}
      @envs.each {|rec| h.update rec.values}

      h
    end

    def stdin
      StringIO.new( @stdins.inject( '' ) {|buf, rec| buf << rec.flagment} )
    end

    def data
      StringIO.new( @datas.inject( '' ) {|buf, rec| buf << rec.flagment } )
    end
  end


  class Record
    # uint8_t  protocol_version;
    # uint8_t  record_type;
    # uint16_t request_id;     (big endian)
    # uint16_t content_length; (big endian)
    # uint8_t  padding_length;
    # uint8_t  reserved;
    HEADER_FORMAT = 'CCnnCC'
    HEADER_LENGTH = 8

    def self::parse_header(buf)
      return *buf.unpack(HEADER_FORMAT)
    end

    def self::class_for(type)
      RECORD_CLASS[type]
    end

    def initialize(type, reqid)
      @type = type
      @request_id = reqid
    end

    def version
      FCGI_PROTOCOL_VERSION
    end

    attr_reader :type
    attr_reader :request_id

    def management_record?
      @request_id == FCGI_NULL_REQUEST_ID
    end

    def serialize
      body = make_body()
      padlen = body.length % 8
      header = make_header(body.length, padlen)
      header + body + "\000" * padlen
    end

    private

    def make_header(clen, padlen)
      [version(), @type, @request_id, clen, padlen, 0].pack(HEADER_FORMAT)
    end
  end

  class BeginRequestRecord < Record
    # uint16_t role; (big endian)
    # uint8_t  flags;
    # uint8_t  reserved[5];
    BODY_FORMAT = 'nCC5'

    def BeginRequestRecord.parse(id, body)
      role, flags, *reserved = *body.unpack(BODY_FORMAT)
      new(id, role, flags)
    end

    def initialize(id, role, flags)
      super FCGI_BEGIN_REQUEST, id
      @role = role
      @flags = flags # TODO: graceful exit if flags = 0
    end

    attr_reader :role
    attr_reader :flags

    def make_body
      [@role, @flags, 0, 0, 0, 0, 0].pack(BODY_FORMAT)
    end
  end

  class AbortRequestRecord < Record
    def AbortRequestRecord.parse(id, body)
      new(id)
    end

    def initialize(id)
      super FCGI_ABORT_REQUEST, id
    end
  end

  class EndRequestRecord < Record
    # uint32_t appStatus; (big endian)
    # uint8_t  protocolStatus;
    # uint8_t  reserved[3];
    BODY_FORMAT = 'NCC3'

    def self::parse(id, body)
      appstatus, protostatus, *reserved = *body.unpack(BODY_FORMAT)
      new(id, appstatus, protostatus)
    end

    def initialize(id, appstatus, protostatus)
      super FCGI_END_REQUEST, id
      @application_status = appstatus
      @protocol_status = protostatus
    end

    attr_reader :application_status
    attr_reader :protocol_status

    private

    def make_body
      [@application_status, @protocol_status, 0, 0, 0].pack(BODY_FORMAT)
    end
  end

  class UnknownTypeRecord < Record
    # uint8_t type;
    # uint8_t reserved[7];
    BODY_FORMAT = 'CC7'

    def self::parse(id, body)
      type, *reserved = *body.unpack(BODY_FORMAT)
      new(id, type)
    end

    def initialize(id, t)
      super FCGI_UNKNOWN_TYPE, id
      @unknown_type = t
    end

    attr_reader :unknown_type

    private

    def make_body
      [@unknown_type, 0, 0, 0, 0, 0, 0, 0].pack(BODY_FORMAT)
    end
  end

  class ValuesRecord < Record
    attr_reader :values

    def initialize( type, id, body )
      super type, id

      @offset = 0
      @buf = body

      @values = parse_values
    end


    def read_next( length )
      piece = @buf[ @offset, length ] # TODO: String#[] is slow!
      @offset += length

      piece
    end


    def available?
      ( @buf.size - @offset - 1 ) > 0
    end


    def self::parse( id, body )
      new( id, body )
    end


    def parse_values
      result = {}
      while available?
        name, value = *read_pair
        result[ name ] = value
      end

      result
    end


    def read_pair
      nlen = read_length
      vlen = read_length

      n = read_next( nlen )
      v = read_next( vlen )

      return n, v
    end

    # TODO: 3% of the time!
    PAD = ( ( 1 << 31 ) - 1 )
    def read_length
      byte = @buf[ @offset ].ord # TODO: String#[] is slow!
      if 0 == ( byte >> 7 ) # TODO: Fixnum#>> is slow!
        result = byte
        @offset += 1
      else
        result = read_next( 4 ).unpack( 'N' )[ 0 ].ord & PAD
      end

      result
    end


  private

    def make_body
      buf = ''
      @values.each do |name, value|
        buf << serialize_length(name.length)
        buf << serialize_length(value.length)
        buf << name
        buf << value
      end
      buf
    end

    def serialize_length(len)
      if len < 0x80
      then len.chr
      else [len | (1<<31)].pack('N')
      end
    end
  end

  class GetValuesRecord < ValuesRecord
    def initialize(id, body)
      super FCGI_GET_VALUES, id, body
    end
  end

  class ParamsRecord < ValuesRecord
    def initialize(id, body)
      super FCGI_PARAMS, id, body
    end

    def empty?
      @values.empty?
    end
  end

  class GenericDataRecord < Record
    def self::parse(id, body)
      new(id, body)
    end

    def initialize(type, id, flagment)
      super type, id
      @flagment = flagment
    end

    attr_reader :flagment

    def empty?
      @flagment.empty?
    end

    private

    def make_body
      @flagment
    end
  end

  class StdinDataRecord < GenericDataRecord
    def initialize(id, flagment)
      super FCGI_STDIN, id, flagment
    end
  end

  class StdoutDataRecord < GenericDataRecord
    def initialize(id, flagment)
      super FCGI_STDOUT, id, flagment
    end
  end

  class DataRecord < GenericDataRecord
    def initialize(id, flagment)
      super FCGI_DATA, id, flagment
    end
  end

  class Record   # redefine
    RECORD_CLASS = {
      FCGI_GET_VALUES    => GetValuesRecord,

      FCGI_BEGIN_REQUEST => BeginRequestRecord,
      FCGI_ABORT_REQUEST => AbortRequestRecord,
      FCGI_PARAMS        => ParamsRecord,
      FCGI_STDIN         => StdinDataRecord,
      FCGI_DATA          => DataRecord,
      FCGI_STDOUT        => StdoutDataRecord,
      FCGI_END_REQUEST   => EndRequestRecord
    }.freeze
  end
  
end