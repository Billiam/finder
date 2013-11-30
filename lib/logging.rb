module Logging
  def loggy
    Logging.loggy
  end

  def self.loggy
    @logger ||= begin
      logger = ::Logger.new STDOUT
      logger.level = ::Logger.const_get(Configuration::LOG_LEVEL.to_sym)
      logger.formatter = nil
      logger
    end
  end
end