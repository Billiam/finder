class JobLock
  include Mongoid::Document
  include Mongoid::Timestamps # adds created_at and updated_at fields

  field :expire, type: Time
  field :type, type: String

  index({expire: 1}, {expire_after_seconds: 0})
  index({type: 1}, {unique: true})

  before_create :set_expire
  before_create :set_type

  def self.expiration
    0
  end

  def set_type
    self.type = self.class.name
  end

  def set_expire
    self.expire = Time.now + self.class.expiration
    true
  end
end
