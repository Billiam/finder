class PollBotJob
  include SuckerPunch::Job
  include Lockable
  include Logging

  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation

  lock_with :bot_lock

  def perform
    success = lock { run }
    unless success
      loggy.warn "Bot poll already in progress"
    end
  end

  def self.remove users
    return unless users.present?

    Request.by_name(users).delete
    Point.by_name(users).delete
  end

  def self.register data
    Request.create(data, without_protection: true)
  end

  def self.gong data
  end

  protected
  def run
    bot = GongBot::Base.new

    bot.run do |action, results|
      if [:remove, :gong, :register].include?(action)
        self.class.public_send action, results
      end
    end
  end

  add_transaction_tracer :run, :category => :task
end