class Point
  STATUSES = %w(pending approved denied)

  include Mongoid::Document
  include Mongoid::Timestamps # adds created_at and updated_at fields
  include Mongoid::Geospatial

  # field <name>, :type => <type>, :default => <value>
  field :name, type: String

  geo_field :location, delegate: true

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

  def location_name
    @location_name ||= [city, county, state, country].reject(&:nil?).join(', ')
  end

  def to_s
    location_name
  end

  def as_json(*args)
    #if args.first == :markers
      {
        name: name,
        lat: location.y,
        long: location.x,
        location: location_name,
      }
    #else
    #  super
    #end
  end

  def self.bulk_upsert(rows)
    update, insert = rows.partition(&:persisted?)
    collection.insert(insert.map(&:as_document)) unless insert.empty?
    update.each(&:save)
  end

  # You can define indexes on documents using the index macro:
  # index :field <, :unique => true>

  # You can create a composite key in mongoid to replace the default id using the key macro:
  # key :field <, :another_field, :one_more ....>
end
