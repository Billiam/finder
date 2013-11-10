class BotLock < JobLock
  def self.expiration
    5.minutes
  end
end
