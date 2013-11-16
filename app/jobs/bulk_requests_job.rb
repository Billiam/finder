require 'process_requests_job'

class BulkRequestsJob
  include Logging

  def work
    tasks = (Request.ready.length / 100.0).ceil
    loggy.info "Spawning #{tasks} jobs"
    tasks.times do
      ProcessRequestsJob.new.perform
    end
  end
end