class Point
  STATUSES = %w(pending approved denied)

  include Mongoid::Document
  include Mongoid::Timestamps # adds created_at and updated_at fields
  include Mongoid::Geospatial

  # field <name>, :type => <type>, :default => <value>
  field :name, type: String

  geo_field :location

  field :status, type: String, default: 'pending'

  field :country, type: String
  field :county, type: String
  field :city, type: String
  field :state, type: String

  validates :name,
    length: { minimum: 3 },
    uniqueness: true

  validates :status,
    inclusion: STATUSES

  index({name: 1}, {unique: true})

  # You can define indexes on documents using the index macro:
  # index :field <, :unique => true>

  # You can create a composite key in mongoid to replace the default id using the key macro:
  # key :field <, :another_field, :one_more ....>
end
