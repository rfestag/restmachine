class Restmachine::UnauthorizedError < StandardError; end
class Restmachine::InvalidRequestError < StandardError
  attr_reader :object
  def initialize object
    @object = object
  end
end
