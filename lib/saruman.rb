require "saruman/version"
require "highline"
require "virtus"
require "saruman"
require "nokogiri"
require 'active_support'
module Saruman
  
  module Base
    
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
    
    def command
      arguments[:command]
    end
    
    def version
      arguments[:version]
    end
    
    def author
      arguments[:author]
    end  
    
    def observer?
      if arguments[:observer] == true
        return true
      else
        return false
      end
    end
    
    def observers
      arguments[:observer_events]
    end
    
    def helper?
      if arguments[:helper] == true
        return true
      else
        return false
      end
    end
    
    def extension_config_file_path
      "#{extension_config_path}config.xml"
    end  
    
    def read_extension_config
      config = File.open(extension_config_file_path, "r+")
      @config = Nokogiri::XML(config)
      config.close
      @config
    end
    
    def write_extension_config
      file = File.open(extension_config_file_path,'w')
      file.puts @config.to_xml
      file.close
    end  
    
    def extension_current_version
      @extension_current_version = @config.css("version").first.content
    end
    
    def extension_upgrade_version
      digits = extension_current_version.to_s.split(".")
      current_version_float = "#{digits[0]}.#{digits[1]}#{digits[2]}".to_f
      @extension_upgrade_version = (current_version_float + 0.01).to_s.sub(".", "").chars.to_a.join(".")
    end  
    
    def config_has_tag?(tag_lookup)
      target = @config.css(tag_lookup).first
      if target.nil?
        return false
      else
        return true
      end
    end
    
    def insert_tag_at_node(tag, tag_lookup)
      target_tag = @config.css(tag_lookup).first
      puts "inserting #{tag} from looku #{tag_lookup}"
      unless target_tag.nil?
        new_tag = "<#{tag}></#{tag}>"
        target_tag.add_child(new_tag)
      end
    end
    
    def insert_xml_at_node(xml, tag_lookup)
      target_tag = @config.css(tag_lookup).first
      unless target_tag.nil?
        target_tag.add_child(xml)
      end
    end  
    
  end  
  
  
  module MenuBuilder
    include Virtus
    attribute :decisions, Array, :default => []

    # def decisions
    #   return decisions_made
    # end  
    
  end
  
  class ObserverMenuBuilder
    
    # include Virtus
    include MenuBuilder
    # attribute :chosen_events, Array
    attribute :observer_events, Array, :default => []
    # attribute :decisions, Array, :default => []
    BASE_DIR = File.dirname(__FILE__)
    OBSERVER_EVENTS_FILE_PATH = BASE_DIR+"/saruman/generators/observer/observer_events.csv"
    
    def initialize(menu)
      @events_file = File.open(OBSERVER_EVENTS_FILE_PATH, 'r')
      @observer_events = []
      @events_file.readlines.each do |row|
        cells = row.strip().split(",")
        @observer_events.push({:event_name => cells[2], :file => cells[0], :line => cells[1]})
      end
      @events_file.close
      display_choices(menu)
    end
    
    #make the choices pretty, longest string length minus offset, and take into account number of base digits of the choice
    def pad_command_line(string, offset, index)
      padding = ""
      l = ((offset - string.length) - index.to_s.length)
      l.times do
        padding << " "
      end
      padding
    end
    
    def display_choices(menu)
      observer_events.each_with_index do |event,index|
        menu.choice("#{event[:event_name]} #{pad_command_line(event[:event_name],67,index+1)} File: #{event[:file]} #{pad_command_line(event[:file],96,index+1)} Line: #{event[:line]}") { decisions.push(event[:event_name])}
      end
      menu
    end  
    
  end
  
  class ModelBuilder
    def initialize
      ask_question
    end
    
    def ask_question
      model_name = ask("Enter Name of model") { |q| q.default = "Post" }
      model_table_name = ask("Enter Table Name of model") { |q| q.default = "blog_post" }
      model_fields_input = ask("Enter Model Fields") { |q| q.default = "title:string active:boolean blog_id:integer:index" }
      model_sql = parse_model_fields(model_fields_input, model_table_name)
      @question_answer = {:model_name => model_name, :model_name_lower => model_name.downcase, :model_table_name => model_table_name, :sql => model_sql}
      @question_answer
    end
    
    def output
      return @question_answer
    end
    
    def parse_model_fields(model_fields, model_table_name)
      sql = ""
      index_sql = ""
      model_fields.split(" ").each do |field|
        field = Saruman::ModelBuilderField.new(field, model_table_name)
        sql << field.sql + ",\n"
        index_sql << field.index_sql if field.index?
      end
      sql << index_sql 
      sql << "  PRIMARY KEY (`id`) \n"
      sql
    end
    
  end
  
  class ModelBuilderField
    
    SQL_TYPE_MAPPINGS = {:string => "varchar(255)", :text => "text NOT NULL", :boolean => "tinyint(1) NOT NULL default 0", :date => "DATETIME default NULL", :int => "int(10)", :integer => "int(10)" }
    attr_accessor :sql, :sql_type, :index, :segs, :index_sql
    SQL_LINE_PADDING = "  "
    
    def initialize(field, model_table_name)
      @segs = field.split(":")

      case segs.length
      when 1
        @sql_type = :string
      when 2
        @sql_type = segs[1].to_sym
      when 3
        @sql_type = segs[1].to_sym
      end
      
      @sql = "#{SQL_LINE_PADDING}`#{segs[0]}` #{SQL_TYPE_MAPPINGS[sql_type]}"
      if index?
        @index = true
        @index_sql = "#{SQL_LINE_PADDING}KEY `IDX_#{model_table_name.upcase}_#{segs[0].upcase}` (`#{segs[0]}`),\n"
      end
    end
    
    def index?
      if(@segs.length==3)
        return true
      else
        return false
      end    
    end  
    
  end
  
  module XmlBuilderBase
    def method_missing(meth, *args, &block)
      if(@generator.respond_to?(meth.to_sym, true))
        @generator.send(meth.to_sym, *args)
      else
        super
      end
    end    
  end  
  
  class ModelXmlConfigBuilder
    include Virtus
    include XmlBuilderBase
    attribute :models, Array
    attribute :config_models_resource_entities_xml, String
    attribute :config_models_resource_xml, String
    attribute :config_global_models_model_xml, String
    attribute :config_global_resources_xml, String
    
    def initialize(models, generator)
      @models = models
      @generator = generator
      @config_models_resource_entities_xml = set_config_models_resource_entities_xml
      @config_models_resource_xml = set_config_models_resource_xml
      @config_global_models_model_xml = set_config_global_models_model_xml
      @config_global_resources_xml = set_config_global_resources_xml
    end
    
    def set_config_models_resource_entities_xml
      xml = ""
      models.each do |model|
        xml << "<#{model[:model_name_lower]}><table>#{model[:model_table_name]}</table></#{model[:model_name_lower]}>\n"
      end
      return xml
    end
    
    def set_config_models_resource_xml
      xml = "
      <#{resource_model_name}>
        <class>#{resource_model_klass_name}</class>
        <entities>
          #{config_models_resource_entities_xml}
        </entities>
      </#{resource_model_name}>
    "
      return xml
    end
    
    def set_config_global_models_model_xml
      xml = "
      <#{extension_name_lower}>
        <class>#{model_klass_name}</class>
        <resourceModel>#{resource_model_name}</resourceModel>
      </#{extension_name_lower}>
    "
      return xml
    end
    
    def set_config_global_resources_xml
      xml = "
      <resources>
        <#{extension_name_lower}_setup>
          <setup>
            <module>#{combined_namespace}</module>
          </setup>
          <connection>
            <use>core_setup</use>
          </connection>
        </#{extension_name_lower}_setup>
        <#{extension_name_lower}_write>
          <connection>
            <use>core_write</use>
          </connection>
        </#{extension_name_lower}_write>
        <#{extension_name_lower}_read>
          <connection>
            <use>core_read</use>
          </connection>
        </#{extension_name_lower}_read>
      </resources>
    "
      return xml
    end
    
  end
  
  class ObserverXmlConfigBuilder
    include Virtus
    include XmlBuilderBase
    attribute :observers, Array
    attribute :config_frontend_events_observers_xml, String
    
    def initialize(observers, generator)
      @observers = observers
      @generator = generator
      @config_frontend_events_observers_xml = set_config_frontend_events_observers_xml
    end
    
    def set_config_frontend_events_observers_xml
      xml=""
      observers.each do |event|
      xml << "
      <#{event}>
        <observers>
          <#{combined_namespace}_Model_Observer>
            <type>singleton</type>
            <class>#{combined_namespace}_Model_Observer</class>
            <method>#{event}</method>
          </#{combined_namespace}_Model_Observer>
        </observers>
      </#{event}>
    "
      end
      return xml
    end
    
  end  
  
end
