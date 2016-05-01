module RestmachinePath
  class Path < Treetop::Runtime::SyntaxNode
    def to_spec
      self.elements.map(&:to_spec).flatten
    end
  end
  class Component < Treetop::Runtime::SyntaxNode
    def to_spec
      if (self.elements.length == 1)
        self.elements.first.to_spec
      else
        regex = self.elements.each_with_index.reduce('') do |regex, (e, i)|
          case e
          when SymbolComponent
            next_e = self.elements[i+1]
            case next_e
            when StringComponent
              "#{regex}(?<#{e.text_value}>[^#{next_e.to_spec[0]}]+)"
            else
              "#{regex}(?<#{e.text_value}>.+)"
            end
          when StringComponent
            "#{regex}#{Regexp.escape e.to_spec}"
          when OptionalComponent
            "#{regex}?"
          else
            raise "Unexpected path component"
          end
        end
        Regexp.new regex
      end
    end
  end
  class StringComponent < Treetop::Runtime::SyntaxNode
    def to_spec
      self.text_value
    end
  end
  class SymbolComponent < Treetop::Runtime::SyntaxNode
    def to_spec
      self.text_value.to_sym
    end
  end
  class OptionalComponent < Treetop::Runtime::SyntaxNode
  end
end
