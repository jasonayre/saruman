<?php

class <%= @model.klass_name %> extends Mage_Core_Model_Abstract
{
    public function _construct()
    {
        parent::_construct();
        $this->_init('<%= name_lower %>/<%= @model.name_lower %>');
    }
}
