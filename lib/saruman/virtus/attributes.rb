class Capitalize < Virtus::Attribute::Object
  primitive String
  coercion_method :capitalize
end

class Downcase < Virtus::Attribute::Object
  primitive String
  coercion_method :downcase
end

module Virtus
  class Coercion
    class String < Virtus::Coercion::Object
      
      def self.capitalize(value)
        value.capitalize
      end
      
      def self.downcase(value)
        value.downcase
      end
      
    end
  end
end
