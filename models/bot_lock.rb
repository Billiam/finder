class BotLock < JobLock
  def self.expiration
    4.minutes
  end
end
