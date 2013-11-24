class Request
  STATUSES = %w(new processing success fail)

  include Mongoid::Document
  include Mongoid::Timestamps # adds created_at and updated_at fields
  include MongoidBatch::Upsert # adds bulk_upsert methods

  # field <name>, :type => <type>, :default => <value>
  field :name, :type => String
  field :lname, :type => String
  field :pm, :type => Boolean
  field :search, :type => String
  field :status, :type => String, default: 'new'

  validates :name,
    length: { minimum: 3 }

  validates :lname,
    uniqueness: true

  validates :search,
    presence: true

  validates :status,
    inclusion: STATUSES

  scope :ready, where(status: 'new')

  index status: 1, created_at: -1

  # Callbacks
  before_validation :set_case_insensitive

  def self.by_name(name)
    self.in(lname: Array(name).map(&:downcase))
  end

  def set_case_insensitive
    self.lname = self.name.downcase if self.name_changed?
  end
end
