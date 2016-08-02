class UserActionLogger < Logger
  def format_message(severity, timestamp, progname, msg)
    date_format = timestamp.strftime("%Y-%m-%d %H:%M:%S")
    "[#{date_format}] #{severity.ljust(5)} : #{msg}\n"
  end
end

USER_ACTION_LOGGER = UserActionLogger.new('log/user_action.log')
USER_ACTION_LOGGER.level = Logger::INFO
