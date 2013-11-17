task "poll_bot" => :environment do
  require 'poll_bot_job'
  PollBotJob.new.perform
end