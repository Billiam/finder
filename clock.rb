require 'clockwork'
require './config/boot'

require 'poll_bot_job'
require 'process_requests_job'

module Clockwork
  # handler receives the time when job is prepared to run in the 2nd argument
  handler do |job, time|
     puts "Running #{job}, at #{time}"
  end
  every(5.minutes, 'pollbot.run') { PollBotJob.new.async.perform }
  every(20.minutes, 'request_processor.run') { ProcessRequestsJob.new.async.perform }
end