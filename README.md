# What is Saruman?

A ruby gem developed by jasonayre of bravenewwebdesign.com (site down currently), to make super complicated, ridiculous, time consuming things in Magento, e.g. creating a new extension, easy.

## NOTE: NOT EVERYTHING HAS BEEN TESTED, USE AT YOUR OWN RISK

### IF YOUR COMPUTER BLOWS UP, NOT MY FAULT. Probably make a new branch before attempting to use, ESPECIALLY if not creating a new extension.

## Installing

    gem install saruman
    
Creating a new extension should be working. To do so, navigate to the root directory of your magento installation and call

    saruman extension
    
The wizard should take you through the rest of it. I would recommend adding an observer, choose event #3 (checkout_cart_update), and then after it's finished, add an item to your cart and watch the system log, to verify everything is working correctly (well not EVERYTHING, just the observer and general installation of the extension really)

### A picture is worth a thousand words (or is it a million?)

However the phrase goes, its a lot of words, so here is an example of what my terminal looks like after creating a new extension via saruman, along with tailing the magento system log in bottom portion of terminal screen. Oh and I didnt see my itunes open in back when I took screenshot, and too lazy to take a new one, so I would like to state for the record that I have no idea how Katy Perry got into my itunes library, though I suspect it was the work of gremlins, or George W Bush and is part of some 9/11 cover up conspiracy...

![Saruman Image example](/jasonayre/saruman/raw/master/doc_assets/saruman_extension_example.jpg)

### Creating the models

You are able to create an unlimited number of models for your extension, and it is done in rails fashion. E.g, when you get to models part of wizard:

    title:string content:text active:boolean

Will create the magento installer sql using the rails friendly syntax.

### Future stuff

Technically I believe the model command is working, honestly haven't really tested it so I dont recommend using it. The idea behind this whole library is you will be able to do things like

    saruman model
    
And then the wizard will let you create any number of models, using a railsish syntax, which will create magento models for a specific extension. It will also create a new version upgrade, along with the resource models and what not.

The coolest part and hardest part to get right, is I'm actually reading the config files of the magento extension, and appending the new data declarations for the models and what not, in an attempt to really simplify the creation of magento extensions. (work in progress, you can try it for now but no promises nothing will break)



