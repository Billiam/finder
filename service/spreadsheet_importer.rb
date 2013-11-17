require 'csv'

class SpreadsheetImporter
  include Logging

  def initialize(path)
    @path = path
  end

  def run
    points = []
    CSV.foreach(@path, headers: true) do |row|
      row['username'].strip!
      if row['username'].empty?
        loggy.debug "Missing username: #{row}"
        next
      end

      location = row.values_at(*%w(city state country)).reject { |i| i.nil? || i.empty? }

      if location.empty?
        loggy.warn "#{row['username']} has no location"
        next
      end

      loggy.debug "Importing: #{row['username']}"

      point = Request.find_or_initialize_by(lname: row['username'].downcase)
      point.assign_attributes(
        name:    row['username'],
        search:  location.join(', '),
        pm:      false,
        status:  'new',
      )

      if point.valid?
        points << point
      else
        loggy.warn "Invalid row: #{point.errors.full_messages}"
      end
    end

    update, insert = Request.bulk_upsert points
    loggy.debug "New Requests: (#{insert.length}), Updated Requests: (#{update.length})"
  end
end