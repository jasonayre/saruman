<?php

$installer = $this;

$installer->startSetup();

$installer->run("
<% models.each do |model| %>
DROP TABLE IF EXISTS {$this->getTable('<%= model.table_name %>')};
CREATE TABLE {$this->getTable('<%= model.table_name %>')} (
  `id` int(11) unsigned NOT NULL auto_increment,
<%= model.sql %>
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
<% end %>
");

$installer->endSetup();
