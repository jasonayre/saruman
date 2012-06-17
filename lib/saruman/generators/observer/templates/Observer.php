<?php

class <%= combined_namespace %>_Model_Observer
{
  <% observers.each do |event| %>
  public function <%= event %>($observer)
  {
    $event = $observer->getEvent();
    Mage::log("I put on my robe and wizard hat");
    Mage::log($event->getEventName().' was called. Winning!');
  }
  <% end %>
}