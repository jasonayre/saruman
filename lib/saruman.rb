require "saruman/version"
require "highline"
require "virtus"
require "saruman/virtus/attributes"
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
      "#{Dir.pwd}/app/etc/modules/"
    end
    
    def extension_base_path
      "#{Dir.pwd}/app/code/local/#{namespace}/#{name}/"
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
    
    def controller_path
      "#{extension_base_path}controllers/"
    end    
    
    def helper_path
      "#{extension_base_path}Helper/"
    end
    
    def resource_model_path
      "#{model_path}Mysql4/"
    end
    
    def setup_base_path
      "#{extension_base_path}sql/#{name_lower}_setup/"
    end
    
    def block_klass_name
      "#{combined_namespace}_Block"
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
    
    def app_design_frontend_base_path
      newer_magento_base_path = "#{Dir.pwd}/app/design/frontend/base/default/"
      older_magento_base_path = "#{Dir.pwd}/app/design/frontend/default/default/"
      if File.directory?(newer_magento_base_path)
        return newer_magento_base_path
      else
        return older_magento_base_path
      end
    end
    
    def app_design_frontend_base_layout_path
      "#{app_design_frontend_base_path}layout/"
    end
    
    def app_design_frontend_base_layout_local_xml_path
      "#{app_design_frontend_base_path}layout/#{name_lower}.xml"
    end
    
    def app_design_frontend_base_template_path
      "#{app_design_frontend_base_path}template/"
    end
    
    def app_design_frontend_base_template_namespace_path
      "#{app_design_frontend_base_template_path}#{name_lower}/"
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
    
    def controller?
      if arguments[:controller] == true
        return true
      else
        return false
      end
    end
    
    def controllers
      arguments[:controllers]
    end
    
    def controller_front_name
      arguments[:controller_front_name]
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
  
  module BuilderInstanceBase
    
    def initialize(options)
      @options = options
    end
    
    def method_missing(meth, *args, &block)
      if(@options.has_key?(meth.to_sym))
        @options[meth.to_sym]
      else
        super
      end
    end
  end  
  
  class ObserverMenuBuilder
    
    include Virtus

    attribute :observer_events, Array, :default => []
    attribute :decisions, Array, :default => []

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
  
  class ControllerBuilder
    
    def initialize(options)
      @options = options
      ask_question
    end
    
    def ask_question
      controller = Saruman::Controller.new(@options)
      controller.name = ask("Enter Controller Name (will match www.yourmagentoinstall.com/frontname/controllername)") { |q| q.default = "index" }
      controller_actions_input = ask("Enter list of actions for this controller, I.E., index show add") { |q| q.default = "index show add"}
      controller.actions = parse_controller_actions(controller_actions_input)
      
      say("Would you like to create controller action views?")
      choose do |menu|
        menu.choice(:yes) { controller.create_views = true }
        menu.choice(:no) { controller.create_views  = false }
      end
      
      # @question_answer = {:controller_name => controller_name.capitalize, :controller_actions => controller_actions}
      @question_answer = controller
      @question_answer
    end
    
    def output
      return @question_answer
    end
    
    def parse_controller_actions(controller_actions_input)
      actions = []
      controller_actions_input.split(" ").each do |action|
        actions << Saruman::ControllerBuilderAction.new(action)
      end
      actions
    end
    
  end
  
  class Controller
    include Virtus
    include BuilderInstanceBase
    attribute :actions, Array
    attribute :name, Capitalize
    attribute :create_views, Boolean
    attribute :name_lower, String, :default => lambda { |model,attribute| model.name.downcase }
    
    def klass_name
      "#{combined_namespace}_#{name}Controller"
    end
      
  end  
    
  
  class ControllerBuilderAction
    include Virtus
    
    #designed for future stuff, mostly pointless/overkill for now
    
    attribute :visibility, String
    attribute :respond_to, String
    attribute :name, Downcase
    attribute :method_name, String
    attribute :segs, Array
    
    def initialize(action)
      @segs = action.split(":")
      case segs.length
      when 1
        @visibility = "public"
        @respond_to = "html"
        @name = segs.first
        @method_name = "#{name}Action"
      end
    end
    
    def layout_handle(extension_name, controller_name)
      @extension_name = extension_name
      @controller_name = controller_name
      "#{@extension_name}_#{@controller_name}_#{name}"
    end
    
    def block_name
      "#{@extension_name}#{@controller_name}#{name}"
    end
    
    def block_as
      "#{@extension_name}#{@controller_name}#{name}"
    end
    
    def block_template
      "#{@extension_name}/#{@controller_name}/#{name}.phtml"
    end
    
  end  
  
  class ModelBuilder
    
    def initialize(options)
      @options = options
      ask_questions
    end
    
    def ask_questions
      model = Saruman::Model.new(@options)
      
      model.name = ask("Enter Name of model") { |q| q.default = "Post" }
      model.table_name = ask("Enter Table Name of model") { |q| q.default = "blog_post" }
      model_fields_input = ask("Enter Model Fields") { |q| q.default = "title:string active:boolean blog_id:integer:index" }

      model.sql = parse_model_fields(model_fields_input, model.table_name)
      # @question_answer = {:model_name => model_name, :model_name_lower => model_name.downcase, :model_table_name => model_table_name, :sql => model_sql}
      
      say("Would you like to create a collection model?")
      choose do |menu|
        menu.choice(:yes) { model.collection = true }
        menu.choice(:no) { model.collection  = false }
      end
      
      @question_answer = model
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
  
  class Model
    include Virtus
    include BuilderInstanceBase
    attribute :name, Capitalize
    attribute :name_lower, String, :default => lambda { |model,attribute| model.name.downcase }
    attribute :table_name, Downcase
    attribute :sql, String
    attribute :collection, Boolean
    
    def klass_name
      "#{combined_namespace}_Model_#{name}"
    end
    
    def resource_model_klass_name
      "#{combined_namespace}_Model_Mysql4_#{name}"
    end
    
    def collection_model_klass_name
      "#{combined_namespace}_Model_Mysql4_#{name}_Collection"
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
        xml << "<#{model.name_lower}><table>#{model.table_name}</table></#{model.name_lower}>\n"
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
  
  class ControllerXmlConfigBuilder
    include Virtus
    include XmlBuilderBase
    attribute :controllers, Array
    attribute :config_frontend_routers_name_xml, String
    attribute :config_frontend_layout_xml, String
    attribute :config_global_blocks_xml, String
    
    def initialize(controllers, generator)
      @controllers = controllers
      @generator = generator
      @config_frontend_routers_name_xml = set_config_frontend_routers_name_xml
      @config_frontend_layout_xml = set_config_frontend_layout_xml
      @config_global_blocks_xml = set_config_global_blocks_xml
    end
    
    def set_config_frontend_routers_name_xml
      xml="
      <#{name_lower}>
        <use>standard</use>
        <args>
          <module>#{combined_namespace}</module>
          <frontName>#{controller_front_name}</frontName>
        </args>  
      </#{name_lower}>
    "
      return xml
    end
    
    def set_config_frontend_layout_xml
      xml="
      <layout>
        <updates>
          <#{name_lower}>
            <file>#{name_lower}.xml</file>
          </#{name_lower}>
        </updates>
      </layout>
    "
      return xml
    end
    
    def set_config_global_blocks_xml
      xml="
      <blocks>
          <#{name_lower}>
            <class>#{block_klass_name}</class>
          </#{name_lower}>
      </blocks>
    "
      return xml
    end
    
  end  
  
end
