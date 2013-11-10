module Lockable
  extend ActiveSupport::Concern


  included do
    cattr_accessor :lock_model
  end

  module ClassMethods
    def lock_with(type)
      self.lock_model = type.to_s.camelize.constantize
    end
  end

  def lock
    begin
      self.class.lock_model.with(safe: true).create
      yield
    rescue Moped::Errors::OperationFailure
      false
    end
  end
end