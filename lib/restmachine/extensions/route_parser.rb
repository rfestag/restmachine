require 'treetop'
module Restmachine
  class RouteParser
    def self.parse(data)
      @parser ||= RestmachinePathParser.new
      tree = @parser.parse(data)
      if tree.nil?
        raise Exception, "Parse error at offset:#{@parser.index}"
      end
      self.clean_tree(tree)
      return tree
    end
    private
    def self.clean_tree(root_node)
      return if(root_node.elements.nil?)
      root_node.elements.each {|node| self.clean_tree(node) }
      flatten = false
      root_node.elements.map!{|node| node.class.name == "Treetop::Runtime::SyntaxNode" ? (flatten=true; node.elements) : node}
      root_node.elements.delete_if(&:nil?)
      root_node.elements.flatten! 1 if flatten
      root_node
    end
  end
end
