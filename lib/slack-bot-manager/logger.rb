module SlackBotManager
  module Logger

    def info(msg)
      logger.info(@id) { msg }
    end

    def debug(msg)
      logger.debug(@id) { msg }
    end

    def warning(msg)
      logger.warn(@id) { msg }
    end

    def error(msg)
      logger.error(@id) { msg }
    end


    class Formatter
      SEVERITY_TO_COLOR_MAP   = {'DEBUG'=>'0;37', 'INFO'=>'32', 'WARN'=>'33', 'ERROR'=>'31', 'FATAL'=>'31', 'UNKNOWN'=>'37'}

      def call(severity, timeat, progname, message)
        formatted_severity = sprintf("%-5s",severity).strip
        formatted_time = timeat.strftime("%Y-%m-%d %H:%M:%S.") << timeat.usec.to_s[0..2].rjust(3)
        color = SEVERITY_TO_COLOR_MAP[severity]

        # Handle backtrace, if any
        msg = message.to_s
        message.backtrace.each{|n| msg << "\n   #{n}"} if message.respond_to?(:backtrace)

        [
          "\033[0;37m#{formatted_time}\033[0m",               # Formatted time
          "[\033[#{color}m#{formatted_severity}\033[0m]",     # Level
          "[PID:#{$$}]",                                      # PID
          progname && progname != '' && "(#{progname})",      # Progname (team ID), if exists
          msg.strip                                           # Message
        ].compact.join(' ') + "\n"
      end
    end

  end
end
