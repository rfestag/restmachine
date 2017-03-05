require 'webmachine'
module Restmachine
  module Resource
    class Model < Webmachine::Resource
      include Endpoint
      
      def self.create model, path: nil, 
                             controller: nil, 
                             authenticator: nil
        Class.new(self) do
          include Controller
          include controller if controller
          def initialize
            super()
          end

          #Before going any further, programmatically determine exposed methods
          #and define an accessor for it
          my_methods = (defined? controller::ClassMethods) ?  controller::ClassMethods.instance_methods(false) : []
          ci = ancestors.index(Controller)
          ancestor_methods = ancestors[ci..-1].reduce(Set.new) do |methods, ancestor|
            methods |= ancestor.instance_methods(false)
          end
          collection_methods = my_methods - ancestor_methods.to_a

          define_method :collection_methods do
            collection_methods
          end

          #Before going any further, programmatically determine exposed methods
          #and define an accessor for it
          my_methods = controller.instance_methods(false)
          ci = ancestors.index(Controller)
          ancestor_methods = ancestors[ci..-1].reduce(Set.new) do |methods, ancestor|
            methods |= ancestor.instance_methods(false)
          end
          item_methods = my_methods - ancestor_methods.to_a

          define_method :item_methods do
            item_methods
          end

          define_method :authenticator do
            authenticator
          end
          if authenticator
            define_method :authenticate do |header,request|
              authenticator.validate_session(header,request)
            end
          end
          define_method :path do
            path
          end
          define_method :model do
            model
          end
        end
      end
    end
  end
end
