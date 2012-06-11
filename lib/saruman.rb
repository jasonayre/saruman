require "saruman/version"
require "highline"
module Saruman
  
  class ModelBuilder
    def initialize
      ask_question
    end
    
    def ask_question
      model_name = ask("Enter Name of model") { |q| q.default = "Post" }
      model_table_name = ask("Enter Table Name of model") { |q| q.default = "post" }
      model_fields_input = ask("Enter Model Fields") { |q| q.default = "title:string active:boolean blog_id:integer:index" }
      model_sql = parse_model_fields(model_fields_input)
      @question_answer = {:model_name => model_name, :model_name_lower => model_name.downcase, :model_table_name => model_table_name, :sql => model_sql}
      @question_answer
    end
    
    def output
      return @question_answer
    end
    
    def parse_model_fields(model_fields)
      sql = ""
      model_fields.split(" ").each do |field|
        field = Saruman::ModelBuilderField.new(field)
        sql << field.sql + ",\n"
      end
      sql
    end
    
  end
  
  class ModelBuilderField
    
    SQL_TYPE_MAPPINGS = {:string => "varchar(255)", :text => "text NOT NULL", :boolean => "tinyint(1) NOT NULL default 0", :date => "DATETIME default NULL", :int => "int(10)" }
    attr_accessor :sql, :sql_type, :index
    
    def initialize(field)
      segs = field.split(":")

      case segs.length
      when 1
        @sql_type = :string
      when 2
        @sql_type = segs[1].to_sym
      when 3
        @sql_type = segs[1].to_sym
      end
      
      @sql = "`#{segs[0]}` #{SQL_TYPE_MAPPINGS[sql_type]}"
      @index = true if(segs.length == 3)
      
    end
    
  end
  
end
