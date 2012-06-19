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
        
        @controllers_with_views = controllers.select { |controller| controller.create_views == true }

        if @controllers_with_views.length > 0
          unless config_has_tag?("config frontend layout")
            insert_xml_at_node(@controller_xml_config_builder.config_frontend_layout_xml, "config frontend")
          end
          
          unless config_has_tag?("config global blocks")
            insert_xml_at_node(@controller_xml_config_builder.config_global_blocks_xml, "config global")            
          end
          
          template("local.xml", app_design_frontend_base_layout_local_xml_path)
          
        end
        
      end
      
      def create_controllers
        controllers.each do |controller|
          @controller = controller
          template("Controller.php", "#{controller_path}#{@controller.name}Controller.php")
          
          if controller.create_views
            empty_directory(controller_view_path(@controller.name_lower)) unless File.directory?(controller_view_path(@controller.name_lower))
            empty_directory(controller_block_path) unless File.directory?(controller_block_path)
            @controller_block_klass_name = "#{combined_namespace}_Block_#{@controller.name.capitalize}"
            template("Block.php", controller_block_file_path(@controller.name))
            controller.actions.each do |action|
              @action = action
              @kontroller_front_name = controller_front_name
              template("view.phtml", controller_view_action_path(@controller.name_lower, @action.name))
            end
            app_design_frontend_base_template_namespace_path
          end  
        end       
      end
      
      def write_changes
        write_extension_config
      end  
      
      private
      
      def controller_view_path(controller_name)
        "#{app_design_frontend_base_template_namespace_path}#{controller_name}/"
      end
      
      def controller_view_action_path(controller_name, action_name)
        "#{controller_view_path(controller_name)}#{action_name}.phtml"
      end  
      
    end
  end
end