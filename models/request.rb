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
    present: true

  validates :status,
    inclusion: STATUSES

  # You can define indexes on documents using the index macro:
  # index :field <, :unique => true>

  # You can create a composite key in mongoid to replace the default id using the key macro:
  # key :field <, :another_field, :one_more ....>
end
