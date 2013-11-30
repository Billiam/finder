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

    results = bot.run

    results.removal.each { |user| self.class.remove(user) }
    results.registration.each { |user| self.class.register(user) }
  end

  add_transaction_tracer :run, :category => :task
end