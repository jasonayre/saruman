<?php

class <%= @controller_klass_name %> extends Mage_Core_Controller_Front_Action 
{
  <% @controller_actions.each do |action| %>
  <%= action.visibility %> function <%= action.method_name %>()
  {
    $params = $this->getRequest()->getParams();
    echo "Hello world.";
    print_r($params);
  }
  <% end %>
  
}