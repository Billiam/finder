class InitRequestsJob
  include Logging

  def work
    tasks = (Request.ready.length / 100.0).ceil
    tasks.times do
      job = ProcessRequestsJob.new
      job.work
    end
  end
end