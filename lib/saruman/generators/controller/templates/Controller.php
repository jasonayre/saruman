<?php

class <%= @controller.klass_name %> extends Mage_Core_Controller_Front_Action 
{
  <% @controller.actions.each do |action| %>
  <%= action.visibility %> function <%= action.method_name %>()
  {
    <% if @controller.create_views %>
    $params = $this->getRequest()->getParams();
    $this->renderLayout();
    $this->loadLayout();
    <% else %>
      echo "Hello world.";
      print_r($params);    
    <% end %>
  }
  <% end %>
  
}