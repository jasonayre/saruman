<?php

class <%= @model.collection_model_klass_name %> extends Mage_Core_Model_Mysql4_Collection_Abstract
{
    public function _construct()
    {
        parent::_construct();
        $this->_init('<%= name_lower %>/<%= @model.name_lower %>');
    }
}