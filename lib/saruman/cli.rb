require 'thor'
require 'saruman'
require "highline/import"
require 'saruman/generators/saruman'
module Saruman
  class CLI < Thor
    
    desc "extension", "Creates a new magento extension"
    def extension
      options = Hash.new
      
      options[:namespace] = ask("Enter extension namespace:") { |q| q.default = "Saruman" }
      options[:name] = ask("Enter extension name:") { |q| q.default = "Wizard" }
      options[:author] = ask("Author of extension:") { |q| q.default = "Jason Ayre www.bravenewwebdesign.com" }
      options[:version] = ask("Version number (default - 0.0.1):") { |q| q.default = "0.0.1" }
      
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
            menu.choice(:catalogrule_before_apply) { options[:observer_events].push(:catalog_before_apply) }
            menu.choice(:catalogrule_after_apply) { options[:observer_events].push(:catalog_after_apply) }
            menu.choice(:checkout_cart_save_after) { options[:observer_events].push(:checkout_cart_save_after) }
          end
        end while agree("Observe another event?")
        
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

    end
    
    desc "model", "Creates a new magento model"
    def model
      options = Hash.new
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
    
  end
  
end
