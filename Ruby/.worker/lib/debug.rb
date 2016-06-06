module Kernel
  def __error__( error )
    message = ''

    if error.respond_to? :message
      message << error.message.to_s
    else
      message << error.to_s
    end

    message << " (#{error.class})\n"

    if error.respond_to? :backtrace
      if error.backtrace.respond_to? :each
        error.backtrace.each do |line|
          message << "\t#{line}\n"
        end
      else
        message << error.backtrace.to_s
      end
    end

    tid = "[tid-#{Thread.current.object_id}]"
    self.OutputDebugString "[ZooRack]#{tid} ERROR! #{message}"
  ensure
    $stderr.puts "#{tid} #{message}"
  end


  def __debug__( message )
    self.OutputDebugString "[ZooRack][tid-#{Thread.current.object_id}] #{message}"
  end


  def OutputDebugString( lp_output_string )
    @output_debug_string ||= Win32API.new( 'kernel32', 'OutputDebugString', 'P', 'V' )
    @output_debug_string.call( lp_output_string )
  end
end