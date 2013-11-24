RSpec.configure do |config|
  require 'bcrypt'
  Kernel.silence_warnings {
    BCrypt::Engine::DEFAULT_COST = 1
  }
end
