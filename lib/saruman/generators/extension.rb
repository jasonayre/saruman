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
      
    end
  end
end