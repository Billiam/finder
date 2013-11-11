class PollBotJob
  include Lockable
  include Logging

  lock_with :bot_lock

  def work
    success = lock do
      bot = GongBot::Base.new

      bot.run do |action, results|
        if [:remove, :gong, :register].include?(action)
          self.class.public_send action, results
        end
      end
    end

    unless success
      loggy.warn "Bot poll already in progress"
    end
  end

  def self.remove users
    return unless users.present?

    Request.in(name: users).delete
    Point.in(name: users).delete
  end

  def self.register data
    Request.create(data, without_protection: true)
  end

  def self.gong data
  end
end