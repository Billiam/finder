class PollBotJob
  include Lockable

  lock_with :bot_lock

  def work
    lock do
      bot = GongBot::Base.new

      bot.run do |action, results|
        if [:remove, :gong, :register].include?(action)
          public_send action, results
        end
      end
    end
  end

  def self.remove users
    return unless users.present?

    Request.in(name: users).each(&:delete)
    Point.in(name: users).each(&:delete)
  end

  def self.register data
    Request.create(data)
  end

  def self.gong data
  end
end