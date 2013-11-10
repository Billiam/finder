class JobLock
  include Mongoid::Document
  include Mongoid::Timestamps # adds created_at and updated_at fields

  field :expire, :type => Time

  index({expire: 1}, {expire_after_seconds: 0})
  index({_type: 1}, {unique: true})

  before_create :set_expire

  def self.expiration
    0
  end

  def set_expire
    self.expire = Time.now + self.class.expiration
    true
  end
end
