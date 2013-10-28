require 'process_requests_job'

class InitRequestsJob
  include Logging

  def work
    tasks = (Request.ready.length / 100.0).ceil
    loggy.info "Spawning #{tasks} jobs"
    tasks.times do
      job = ProcessRequestsJob.new
      job.work
    end
  end
end