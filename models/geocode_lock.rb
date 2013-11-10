class GeocodeLock < JobLock
  def self.expiration
    19.minutes
  end
end
