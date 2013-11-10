class Request
  STATUSES = %w(new processing success fail)

  include Mongoid::Document
  include Mongoid::Timestamps # adds created_at and updated_at fields

  # field <name>, :type => <type>, :default => <value>
  field :name, :type => String
  field :pm, :type => Boolean
  field :search, :type => String
  field :status, :type => String, default: 'new'

  validates :name,
    length: { minimum: 3 },
    uniqueness: true

  validates :search,
    presence: true

  validates :status,
    inclusion: STATUSES

  scope :ready, where(status: 'new')
end
