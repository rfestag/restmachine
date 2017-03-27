require 'bcrypt'
module Restmachine
  module User
    def self.included receiver
      receiver.send :include BCrypt
    end
    def password
      @password ||= Password.new(password_hash)
    end

    def password=(new_password)
      @password = Password.create(new_password)
      self.password_hash = @password
    end
  end
end
