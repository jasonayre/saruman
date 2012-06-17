require 'thor/group'
require 'nokogiri'
module Saruman
  module Generators
    class Model < Thor::Group

      include Thor::Actions
      include Saruman::Base
      
      argument :arguments, :type => :hash
      
      def self.source_root
        File.dirname(__FILE__) + "/model/templates"
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
        @model_xml_config_builder = Saruman::ModelXmlConfigBuilder.new(models, self)
      end
      
      def create_model_directory
        empty_directory(model_path) unless File.directory?(model_path)
      end
      
      def modify_config
        
        @config = read_extension_config
        
        unless config_has_tag?("config global")
          insert_tag_at_node("global", "config")
        end
        
        unless config_has_tag?("config global models")
          insert_tag_at_node("models", "config global")
        end
        
        unless config_has_tag?("models #{name_lower}")
          insert_xml_at_node(@model_xml_config_builder.config_global_models_model_xml, "config models")
          insert_xml_at_node(@model_xml_config_builder.config_models_resource_xml, "config models")
        else
          insert_xml_at_node(@model_xml_config_builder.config_models_resource_entities_xml, "#{name_lower}_mysql4 entities")
        end
        
        unless config_has_tag?("resources")
          insert_xml_at_node(@model_xml_config_builder.config_global_resources_xml, "config global resources")
        end
        
        write_extension_config
        
      end
      
      def create_models
        models.each do |model|
          @model_name = model[:model_name]
          @model_klass_name = "#{namespace}_#{name}_Model_#{@model_name}"
          @model_name_lower = model[:model_name_lower]

          @resource_model_klass_name = "#{namespace}_#{name}_Model_Mysql4_#{@model_name}"
          @table_name = model[:model_table_name]
          template("Model.php", "#{model_path}#{@model_name}.php")
          template("Resource_Model.php", "#{resource_model_path}#{@model_name}.php")
        end       
      end  
      
      def create_installer_upgrade
        if command.to_s == "extension"
          template("mysql4-install.php", "#{setup_base_path}/mysql4-install-#{version}.php")
        elsif command.to_s == "model"
          template("mysql4-install.php", "#{setup_base_path}/mysql4-upgrade-#{extension_current_version}-#{extension_upgrade_version}.php")
        else

        end
      end
      
      private
      
    end
  end
end