require 'thor'
require 'saruman'
require "highline/import"
require 'saruman/generators/saruman'
module Saruman
  class CLI < Thor
    
    desc "extension", "Creates a new magento extension"
    def extension
      options = Hash.new
      options[:command] = __method__
      options[:namespace] = ask("Enter extension namespace:") { |q| q.default = "Saruman" }
      options[:name] = ask("Enter extension name:") { |q| q.default = "Wizard" }
      options[:author] = ask("Author of extension:") { |q| q.default = "Jason Ayre www.bravenewwebdesign.com" }
      options[:version] = ask("Version number (Format - 0.0.1):") { |q| q.default = "0.0.1" }
      
      say("Would you like me to create an observer?")
      choose do |menu|
        menu.choice(:yes) { options[:observer] = true }
        menu.choice(:no) { options[:observer] = false }
      end
      
      if(options[:observer])
        
        say("Choose the events you would like to observe")
        begin
          
          choose do |menu|
            if(options[:observer_events]).nil?
              options[:observer_events] = Array.new
            end
            if @observer_menu_builder.nil?
              @observer_menu_builder = Saruman::ObserverMenuBuilder.new(menu)
            else
              @observer_menu_builder.display_choices(menu)
            end
            
          end
        end while agree("Observe another event?")
        
        options[:observer_events] = @observer_menu_builder.decisions
        
      end
      
      say("Would you like me to create a model?")
      choose do |menu|
        menu.choice(:yes) { options[:model] = true }
        menu.choice(:no) { options[:model] = false }
      end
      
      if(options[:model])
        
        if(options[:models]).nil?
          options[:models] = Array.new
        end
        
        begin
          question = Saruman::ModelBuilder.new
          options[:models] << question.output
        end while agree("Create another model?")
        
      end
      
      say("Would you like me to create a helper?")
      choose do |menu|
        menu.choice(:yes) { options[:helper] = true }
        menu.choice(:no) { options[:helper] = false }
      end
      
      Saruman::Generators::Extension.start([options])
      
      if options[:model]
        Saruman::Generators::Model.start([options])
      end  
      
    end
    
    desc "model", "Creates a new magento model"
    def model
      options = Hash.new
      options[:command] = __method__
      options[:namespace] = ask("Enter extension namespace:") { |q| q.default = "Saruman" }
      options[:name] = ask("Enter extension name:") { |q| q.default = "Wizard" }
      
      if(options[:models]).nil?
        options[:models] = Array.new
      end
      
      begin
        question = Saruman::ModelBuilder.new
        options[:models] << question.output
      end while agree("Create another model?")

      Saruman::Generators::Model.start([options])
      
    end
    
    desc "observer", "Creates a new observer for an extension"
    def observer
      options = Hash.new
      options[:command] = __method__
      options[:namespace] = ask("Enter extension namespace:") { |q| q.default = "Saruman" }
      options[:name] = ask("Enter extension name:") { |q| q.default = "Wizard" }
      
      say("Choose the events you would like to observe")
      begin
        
        choose do |menu|
          if(options[:observer_events]).nil?
            options[:observer_events] = Array.new
          end
          if @observer_menu_builder.nil?
            @observer_menu_builder = Saruman::ObserverMenuBuilder.new(menu)
          else
            @observer_menu_builder.display_choices(menu)
          end
          
        end
      end while agree("Observe another event?")
      
      options[:observer_events] = @observer_menu_builder.decisions

      Saruman::Generators::Observer.start([options])
      
    end
    
  end
  
end
