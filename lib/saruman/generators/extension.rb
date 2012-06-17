# require 'saruman/generators/saruman'
require 'thor/group'

module Saruman
  module Generators
    class Extension < Thor::Group
      include Thor::Actions
      include Saruman::Base
      argument :arguments, :type => :hash
      
      def self.source_root
        File.dirname(__FILE__) + "/extension/templates"
      end
      
      def copy_global_config
        template("module.xml", "#{global_config_basepath}#{arguments[:namespace]}_#{arguments[:name]}.xml")
      end
      
      def copy_extension_config
        template("extension_config.xml", "#{extension_config_path}/config.xml")
      end
      
      def create_model_directory
        empty_directory(model_path)
      end
      
      def create_observers
        if observer?
          template("Observer.php", "#{model_path}Observer.php")
        end
      end
      
      def create_helper
        if helper?
          template("Helper.php", "#{helper_path}Data.php")
        end  
      end
      
      private
      
      # def namespace
      #   arguments[:namespace]
      # end
      # 
      # def name
      #   arguments[:name]
      # end
      # 
      # def combined_namespace
      #   "#{arguments[:namespace]}_#{arguments[:name]}"
      # end
      # 
      # def namespace_lower
      #   namespace.downcase
      # end
      # 
      # def name_lower
      #   name.downcase
      # end
      # 
      # #alias for name
      # def extension_name_lower
      #   name.downcase
      # end
      # 
      # def author
      #   arguments[:author]
      # end
      # 
      # def version
      #   arguments[:version]
      # end  
      # 
      # def global_config_basepath
      #   "app/etc/modules/"
      # end
      # 
      # def extension_base_path
      #   "app/code/local/#{namespace}/#{name}/"
      # end
      # 
      # def extension_config_path
      #   "#{extension_base_path}etc/"
      # end
      # 
      # def model_path
      #   "#{extension_base_path}Model/"
      # end
      # 
      # def resource_model_path
      #   "#{model_path}Mysql4/"
      # end  
      # 
      # def helper_path
      #   "#{extension_base_path}Helper/"
      # end
      # 
      # def setup_base_path
      #   "#{extension_base_path}/sql/"
      # end
      # 
      # def model_klass_name
      #   "#{combined_namespace}_Model"
      # end
      # 
      # def resource_model_name_lower
      #   "#{name_lower}_mysql4"
      # end
      # 
      # def resource_model_klass_name
      #   "#{combined_namespace}_Model_Mysql4"
      # end  
      # 
      # def observer?
      #   if arguments[:observer] == true
      #     return true
      #   else
      #     return false
      #   end
      # end
      # 
      # def observers
      #   arguments[:observer_events]
      # end
      # 
      # def helper?
      #   if arguments[:helper] == true
      #     return true
      #   else
      #     return false
      #   end
      # end
      # 
      # def model?
      #   if arguments[:model] == true
      #     return true
      #   else
      #     return false
      #   end
      # end
      # 
      # def models
      #   arguments[:models]
      # end
      
    end
  end
end