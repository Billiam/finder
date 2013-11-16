namespace :geocode do
  task :all do
    require 'bulk_requests_job'
    BulkRequestsJob.new.perform
  end
end

task :geocode => :environment do
  require 'process_requests_job'
  ProcessRequestsJob.new.perform
end
