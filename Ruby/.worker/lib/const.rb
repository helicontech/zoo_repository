module ZooRack
  # Stolen from Thin (and they stole it from Mongrel).
  HTTP_STATUS_CODES = {
    100  => 'Continue',
    101  => 'Switching Protocols',
    200  => 'OK',
    201  => 'Created',
    202  => 'Accepted',
    203  => 'Non-Authoritative Information',
    204  => 'No Content',
    205  => 'Reset Content',
    206  => 'Partial Content',
    300  => 'Multiple Choices',
    301  => 'Moved Permanently',
    302  => 'Moved Temporarily',
    303  => 'See Other',
    304  => 'Not Modified',
    305  => 'Use Proxy',
    400  => 'Bad Request',
    401  => 'Unauthorized',
    402  => 'Payment Required',
    403  => 'Forbidden',
    404  => 'Not Found',
    405  => 'Method Not Allowed',
    406  => 'Not Acceptable',
    407  => 'Proxy Authentication Required',
    408  => 'Request Time-out',
    409  => 'Conflict',
    410  => 'Gone',
    411  => 'Length Required',
    412  => 'Precondition Failed',
    413  => 'Request Entity Too Large',
    414  => 'Request-URI Too Large',
    415  => 'Unsupported Media Type',
    500  => 'Internal Server Error',
    501  => 'Not Implemented',
    502  => 'Bad Gateway',
    503  => 'Service Unavailable',
    504  => 'Gateway Time-out',
    505  => 'HTTP Version not supported'
  }.freeze

  FCGI_PROTOCOL_VERSION = 1

  # Record types
  FCGI_BEGIN_REQUEST = 1
  FCGI_ABORT_REQUEST = 2
  FCGI_END_REQUEST = 3
  FCGI_PARAMS = 4
  FCGI_STDIN = 5
  FCGI_STDOUT = 6
  FCGI_STDERR = 7
  FCGI_DATA = 8
  FCGI_GET_VALUES = 9
  FCGI_GET_VALUES_RESULT = 10
  FCGI_UNKNOWN_TYPE = 11
  FCGI_MAXTYPE = FCGI_UNKNOWN_TYPE

  FCGI_NULL_REQUEST_ID = 0

  # FCGI_BEGIN_REQUSET.role
  FCGI_RESPONDER = 1
  FCGI_AUTHORIZER = 2
  FCGI_FILTER = 3

  # FCGI_BEGIN_REQUEST.flags
  FCGI_KEEP_CONN = 1

  # FCGI_END_REQUEST.protocolStatus
  FCGI_REQUEST_COMPLETE = 0
  FCGI_CANT_MPX_CONN = 1
  FCGI_OVERLOADED = 2
  FCGI_UNKNOWN_ROLE = 3

  FCGI_DEFAULT_PARAMS = {
    'FCGI_MAX_CONNS' => 1,
    'FCGI_MAX_REQS'  => 1,
    'FCGI_MPX_CONNS' => true
  }.freeze
end