class GeocodeLock < JobLock
  def self.expiration
    20.minutes
  end
end
