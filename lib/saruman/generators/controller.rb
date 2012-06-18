require 'thor/group'
require 'nokogiri'
module Saruman
  module Generators
    class Controller < Thor::Group

      include Thor::Actions
      include Saruman::Base
      
      argument :arguments, :type => :hash
      
      def self.source_root
        File.dirname(__FILE__) + "/controller/templates"
      end
      
      def validate_extension
        unless File.directory?("#{extension_base_path}")
          @error = "error"
        end

        unless File.exist?("#{extension_config_path}/config.xml")
          @error = "error"
        end
      end
      
      def load_builders
        @controller_xml_config_builder = Saruman::ControllerXmlConfigBuilder.new(controllers, self)
      end
      
      def create_controller_directory
        empty_directory(controller_path) unless File.directory?(controller_path)
      end
      
      def modify_config
        
        @config = read_extension_config
        
        unless config_has_tag?("config frontend")
          insert_tag_at_node("frontend", "config")
        end
        
        unless config_has_tag?("config frontend routers")
          insert_tag_at_node("routers", "config frontend")
        end
        
        unless config_has_tag?("config frontend routers #{name_lower}")
          insert_xml_at_node(@controller_xml_config_builder.config_frontend_routers_name_xml, "config frontend routers")
        end
        
        write_extension_config
        
      end
      
      def create_controllers
        controllers.each do |controller|
          @controller_name = controller[:controller_name].capitalize
          @controller_klass_name = "#{namespace}_#{name}_#{@controller_name}Controller"
          @controller_name_lower = controller[:controller_name].downcase
          @controller_actions = controller[:controller_actions]
          template("Controller.php", "#{controller_path}#{@controller_name}Controller.php")
        end       
      end
      
      private
      
    end
  end
end