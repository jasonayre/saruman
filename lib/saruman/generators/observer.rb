require 'thor/group'
require 'nokogiri'
module Saruman
  module Generators
    class Observer < Thor::Group

      include Thor::Actions
      include Saruman::Base
      
      argument :arguments, :type => :hash
      
      def self.source_root
        File.dirname(__FILE__) + "/observer/templates"
      end

      def load_builders
        @observer_xml_config_builder = Saruman::ObserverXmlConfigBuilder.new(observers, self)
      end
      
      def modify_config
        
        @config = read_extension_config
        
        unless config_has_tag?("config frontend")
          insert_tag_at_node("frontend", "config")
        end
        
        unless config_has_tag?("config frontend events")
          insert_tag_at_node("events", "config frontend")
        end
        
        insert_xml_at_node(@observer_xml_config_builder.config_frontend_events_observers_xml, "config frontend events")
        
        write_extension_config
        
      end
      
      def create_observers
        template("Observer.php", "#{model_path}Observer.php")
      end
      
      private
      
    end  

  end
end