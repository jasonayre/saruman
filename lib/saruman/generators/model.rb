require 'thor/group'
require 'nokogiri'
module Saruman
  module Generators
    class Model < Thor::Group
      include Thor::Actions
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
      
      def create_model_directory
        empty_directory(model_path) unless File.directory?(model_path)
      end
      
      def create_temp_directory
        empty_directory("#{extension_temp_path}")
      end
      
      def read_extension_config

        fp = "#{extension_config_path}/config.xml"
        config = File.open(fp, "r+")
        
        @config = Nokogiri::XML(config)
        config.close
        
        @extension_current_version = @config.css("version").first.content
        
        global_node = @config.css("global")

        models_node = global_node.css("models")
        
        if models_node.empty?
          models_node = Nokogiri::XML::Node.new('models', @config)
          global_node.first.add_child(models_node)
        end
        
        model_declaration_node = @config.css("models #{name_lower}")
        
        if model_declaration_node.empty?
          @resource_model_config_temp_path = "#{extension_temp_path}_config.xml"
          template("resource_model_config_block.xml", @resource_model_config_temp_path)
          resource_model_config_file = File.open(@resource_model_config_temp_path)
          resource_model_config_block = Nokogiri::XML(resource_model_config_file).root
          resource_model_config_file.close
          
          @model_config_temp_path = "#{extension_temp_path}model_config_block.xml"
          template("model_config_block.xml", @model_config_temp_path)
          model_config_file = File.open(@model_config_temp_path)
          model_config_block = Nokogiri::XML(model_config_file).root
          model_config_file.close
          
          models_node = @config.css("models").first
          
          models_node.add_child(model_config_block)
          models_node.add_child(resource_model_config_block)
          
        end

        models_node_find = @config.css('models')

        file = File.open(fp,'w')
        file.puts @config.to_xml
        file.close

      end
      
      def remove_temp_dir
        FileUtils.rm_rf(extension_temp_path)
      end  
      
      def create_installer_upgrade
        template("mysql4-install.php", "#{setup_base_path}/mysql4-upgrade-#{@extension_current_version}-#{extension_upgrade_version}.php")
      end
      
      private
      
      def namespace
        arguments[:namespace]
      end
      
      def name
        arguments[:name]
      end
      
      def combined_namespace
        "#{arguments[:namespace]}_#{arguments[:name]}"
      end
      
      def namespace_lower
        namespace.downcase
      end
      
      def name_lower
        name.downcase
      end
      
      #alias for name
      def extension_name_lower
        name.downcase
      end
      
      def version
        arguments[:version]
      end
      
      def global_config_basepath
        "app/etc/modules/"
      end
      
      def extension_base_path
        "app/code/local/#{namespace}/#{name}/"
      end
      
      def extension_temp_path
        "#{extension_base_path}temp/"
      end  
      
      def extension_config_path
        "#{extension_base_path}etc/"
      end
      
      def model_path
        "#{extension_base_path}Model/"
      end
      
      def resource_model_path
        "#{model_path}Mysql4/"
      end
      
      def setup_base_path
        "#{extension_base_path}sql/#{name_lower}_setup/"
      end
      
      def model_klass_name
        "#{combined_namespace}_Model"
      end  
      
      def resource_model_name
        "#{extension_name_lower}_mysql4"
      end
      
      def resource_model_klass_name
        "#{combined_namespace}_Model_Mysql4"
      end
      
      def global_config_file_path
        "#{global_config_basepath}#{combined_namespace}.xml"
      end
      
      def extension_upgrade_version
        @extension_current_version.to_f + 0.1
      end  
      
      def model?
        if arguments[:model] == true
          return true
        else
          return false
        end
      end
      
      def models
        arguments[:models]
      end
      
    end
  end
end