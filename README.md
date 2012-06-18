# What is Saruman?

A ruby gem developed by jasonayre of bravenewwebdesign.com (site down currently), to make super complicated, ridiculous, time consuming things in Magento, e.g. creating a new extension, easy.

## NOTE: NOT EVERYTHING HAS BEEN THOROUGHLY TESTED, USE AT YOUR OWN RISK

### IF YOUR COMPUTER BLOWS UP, NOT MY FAULT. Probably make a new branch before attempting to use!

## Installing

    gem install saruman
    
Creating a new extension should be working. To do so, MAKE SURE YOU ARE IN THE ROOT DIRECTORY (containing app folder) of your magento installation and call

    saruman extension
    
The wizard should take you through the rest of it. I would recommend adding an observer, choose event #145 (checkout_cart_update), and then after it's finished, add an item to your cart and watch the system log, to verify everything is working correctly (well not EVERYTHING, just the observer and general installation of the extension really)

If you created a model, check your db for the new tables, along with the extension version in core_resource table

### A picture is worth a thousand words (or is it a million?)

However the phrase goes, its a lot of words, so here is an example of what my terminal looks like after creating a new extension via saruman, along with tailing the magento system log in bottom portion of terminal screen. Oh and I didnt see my itunes open in back when I took screenshot, and too lazy to take a new one, so I would like to state for the record that I have no idea how Katy Perry got into my itunes library, though I suspect it was the work of gremlins, or George W Bush and is part of some 9/11 cover up conspiracy...

![Saruman Image example](/jasonayre/saruman/raw/master/doc_assets/saruman_extension_example.jpg)

## Commands

### saruman extension

    saruman extension
    
Will guide you through the wizard process and help you build an extension. Will let you create an observer, model, helper for your new extension along with an installer.

### saruman model

    saruman model
    
Will let you create any number of models for the specified magento extension. You must type the fields using same syntax rails uses. e.x.

    title:string content:text active:boolean
    
When creating models, it is assumed that you will be creating a new version of the extension. Therefore, a upgrade file is created with the SQL for all of your new models, along with the appropriately named new version.
NOTE: I couldn't remember whether Magento even allows anything but 0.0.1 (3 digits sep by period) syntax, so things will probably break if that is not the case, and you don't have the 3 digit version syntax on your extension (writing this super fast so dont have time to check.)    

### saruman observer

    saruman observer
  
Will create a new observer file with an unlimited amount of events you wish to observe. I also parsed a document containing most of the observer events in magento version 1.5ish I believe, so there are about 300 events to choose from, no guarantees that they all work or are up to date. Just type the number of the observer event youd like to observer, rinse and repeat until you are finished (note that it will create all the observer events into one observer.php file so it will overwrite if you have an observer already.)

### Future stuff

Controllers, helpers, more stuff. I'll post a screencast of how to use it as well, sometime in near future.
