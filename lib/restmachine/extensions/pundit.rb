module Pundit
  # Returns a dry-validations validation of the given record
  #
  # @param record [Object] The object we're validating against the policy of the schema
  # @param action [Symbol, String] the name of the action being performed (e.g. `:update`).
  #  If ommitted then this defaults tot he rails controller action name.
  # @return [Object] A validation object that will include error messages, and be sanitized 
  #  to remove unexpected parameters (avoiding mass-assignment vulnerabilities). If `schema`
  #  or `schema_for_action` are not defined on the policy, this will return the original record
  def validated_attributes(record, model, action)
    policy = policy(model)
    method_name = if policy.respond_to?("schema_for_#{action}")
      "schema_for_#{action}"
    else
      "schema"
    end
    if policy.respond_to? method_name
      validator = policy.public_send(method_name)
      validator ? validator.call(record) : nil
    else
      nil
    end
  end

  # Returns a scope that automatically adds a 'select' clause to limit the fields
  # returned to only those listed. This allows you to limit what attributes are
  # available to the user based on their authorizations, and optionally the action itself.
  #
  # @param scope [Object] The current query scope
  # @param action [Symbol, String] the name of the action being performed (e.g. `:update`).
  #  If ommitted then this defaults tot he rails controller action name.
  # @return [Object] A new scope object with a select chained on, or the original scope if
  #  visible_attributes are not defined for the policy
  def visible_attributes(resource, action)
    policy = policy(resource)
    method_name = if policy.respond_to?("visible_attributes_for_#{action}")
      "visible_attributes_for_#{action}"
    else
      "visible_attributes"
    end
    policy.public_send(method_name)
  end
end
