task "geocode" => :environment do
  require 'init_requests_job'
  InitRequestsJob.new.work
end
