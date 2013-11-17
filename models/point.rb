class Point
  STATUSES = %w(pending approved denied)

  include Mongoid::Document
  include Mongoid::Timestamps # adds created_at and updated_at fields
  include Mongoid::Geospatial

  attr_accessible :status, as: :moderator
  attr_accessible :name, :status, :location, :country, :county, :city, :state, :search, as: [:default, :admin]

  # Field Definitions
  field :name, type: String
  field :lname, type: String

  geo_field :location, delegate: true

  field :status, type: String, default: 'pending'

  field :country, type: String
  field :county, type: String
  field :city, type: String
  field :state, type: String
  field :search, type: String

  # Indices
  index({lname: 1}, {unique: true})
  index status: 1, created_at: -1

  # Validation
  validates :name,
    length: { minimum: 3 }

  validates :lname,
    uniqueness: true

  validates :status,
    inclusion: STATUSES

  # Scopes
  scope :enabled, where(status: 'approved')
  scope :unmoderated, where(status: 'pending')
  scope :disabled, where(status: 'denied')

  # Callbacks
  before_validation :set_case_insensitive

  def self.valid_filter?(type)
    %w(enabled unmoderated disabled).include? type.to_s
  end

  def self.get_filter(type)
    return type.to_sym if valid_filter? type

    :enabled
  end

  def self.by_name(name)
    self.in(lname: Array(name).map(&:downcase))
  end

  def self.filter(type)
    public_send get_filter(type)
  end

  def self.approve
    unmoderated.update_all status: 'approved'
  end

  def self.cluster(zoom=nil)

    map = %q(
      function() {
        var lat = this.location[1];
        var lng = this.location[0];
        emit([lat, lng].toString(), { names: [this.name], lat: lat, lng: lng });
      }
    )

    reduce = %q(
      function(key, values) {
        var result = { names: [], lat: 0, lng: 0 };
        values.forEach(function(value) {
          result.names = result.names.concat(value.names);
          result.lat = value.lat;
          result.lng = value.lng;
        });

        return result;
      }
    )
    map_reduce(map, reduce).out(inline: true).map { |i| i['value'] }
  end

  def self.to_csv
    require 'csv'

    CSV.generate do |csv|
      csv << csv_columns

      each do |i|
        csv << i.as_csv.values
      end
    end
  end

  def self.bulk_upsert(rows)
    update, insert = rows.partition(&:persisted?)
    insert.each { |i| i.created_at ||= Time.now }
    collection.insert(insert.map(&:as_document)) unless insert.empty?
    update.each(&:save)
  end

  def active?
    status == 'approved'
  end

  def disabled?
    status == 'denied'
  end

  def location_name
    @location_name ||= [city, county, state, country].reject(&:nil?).join(', ')
  end

  def to_s
    location_name
  end

  def self.csv_columns
    [:name, :latitude, :longitude, :city, :county, :state, :country]
  end

  def as_csv
    export_attributes
  end

  def export_attributes
    {
      name: name,
      latitude: location.y,
      longitude: location.x,
      city: city,
      county: county,
      state: state,
      country: country,
    }
  end

  def set_case_insensitive
    self.lname = self.name.downcase if self.name_changed?
  end
end
