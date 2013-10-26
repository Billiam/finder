require 'csv'

class SpreadsheetImporter
  include Logging

  def initialize(path)
    @path = path
  end

  def run
    points = []
    CSV.foreach(@path, headers: true) do |row|
      if row['username'].empty?
        loggy.debug "Missing username: #{row}"
        next
      end

      location = row.values_at(*%w(city county state country)).reject { |i| i.nil? || i.empty? }

      if location.empty?
        loggy.warn "#{row['username']} has no location"
        next
      end

      if Point.where(name: row['username']).exists?
        loggy.warn "#{row['username']} already exists"
        next
      end


      loggy.debug "Importing: #{row['username']}"

      point = Request.new(
        name:    row['username'],
        search:  location.join(', '),
        pm:      false,
      )

      if point.valid?
        points << point.as_document
      else
        loggy.warn "Invalid row: #{point}" unless point.valid?
      end
    end

    Request.collection.insert(points) unless points.empty?
  end
end