<?php

class <%= @model.resource_model_klass_name %> extends Mage_Core_Model_Mysql4_Abstract
{
  public function _construct()
  {   
    $this->_init('<%= name.downcase %>/<%= @model.name_lower %>', 'id');
  }
    
}    
