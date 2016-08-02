class UserActionLogger < Logger
  def format_message(severity, timestamp, progname, msg)
    date_format = timestamp.strftime("%Y-%m-%d %H:%M:%S")
    "[#{date_format}] #{severity.ljust(5)} : #{msg}\n"
  end
end

UserActionLogger = UserActionLogger.new('log/user_action.log')
UserActionLogger.level = Logger::INFO
