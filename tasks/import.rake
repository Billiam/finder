namespace :import do
  task :csv => :environment do
    require 'spreadsheet_importer'
    process = SpreadsheetImporter.new Padrino.root('doc', 'spreadsheet.csv')
    process.run
  end
end