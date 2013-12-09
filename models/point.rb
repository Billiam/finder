class Point
  STATUSES = %w(pending approved denied)

  include Mongoid::Document
  include Mongoid::Timestamps # adds created_at and updated_at fields
  include Mongoid::Geospatial
  include MongoidBatch::Upsert

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

  def self.filter(type)
    public_send get_filter(type)
  end

  def self.by_name(name)
    self.in(lname: Array(name).map(&:downcase))
  end

  def self.approve
    unmoderated.update_all status: 'approved'
  end

  def self.location_csv
    require 'csv'

    group_points = enabled.order_by(created_at: :desc).group_by_location

    CSV.generate do |csv|
      column_names = csv_columns.map(&:to_s)
      csv << csv_columns

      group_points.each do |i|
        i['names'] = i['names'].join(',')
        row = i.values_at(*column_names)
        csv << row
      end
    end
  end

  def self.group_by_location
    map = %q(
      function() {
        var key =  {
          latitude: this.location[1],
          longitude: this.location[0],
          city: this.city,
          county: this.county,
          state: this.state,
          country: this.country
        };
        emit(key, { names: [this.name] });
      }
    )

    reduce = %q(
      function(key, values) {
        var result = { names: [] };
        values.forEach(function(value) {
          result.names = result.names.concat(value.names);
        });

        return result;
      }
    )

    map_reduce(map, reduce).out(inline: true).map do |point|
      item = point['_id'].merge point['value']
      item
    end
  end

  def self.csv_columns
    [:latitude, :longitude, :city, :county, :state, :country, :names]
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

  def set_case_insensitive
    self.lname = self.name.downcase if self.name_changed?
  end
end
