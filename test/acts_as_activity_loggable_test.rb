require File.dirname(__FILE__) + '/test_helper.rb'

class Thingybob < ActiveRecord::Base
  attr_reader :activity_log_stack

  def foo
    update_attribute(:name, name + " foo")
  end
  
  def bar
    transaction do
      foo
      raise "Barrr!"
    end
  end
  
  def bzz!
    update_attribute(:name, "Bzz!")
  end

  acts_as_activity_loggable [:create, :update, :foo, :bar, :'bzz!']
end

class ActsAsActivityLoggableTest < Test::Unit::TestCase
  load_schema
  
  def test_thingybob_logged_activities
    assert_equal [:create, :update, :foo, :bar, :'bzz!'], Thingybob.loggable_activities
  end
  
  def test_thingybob_logs_activity
    bob = Thingybob.create(:name => 'Foo')
    
    activity_log = bob.activity_log
    assert_equal 1, activity_log.size
    assert_equal 'create', activity_log[0].action
    assert_equal bob, activity_log[0].entity
  end
  
  def test_thingybob_custom_method_log_without_stacking
    bob = Thingybob.create(:name => 'Foo') # activity create
    bob.foo
    
    activity_log = bob.activity_log
    assert_equal %w(create foo), activity_log.map{|a| a.action}
  end
  
  def test_no_log_with_exception
    bob = Thingybob.create(:name => 'Foo') # activity create
    begin
      bob.bar
    rescue
      bob.reload
    end
    
    assert_equal 'Foo', bob.name
    activity_log = bob.activity_log
    assert_equal %w(create), activity_log.map{|a| a.action}
  end
  
  def test_stack_cleared_after_exception
    bob = Thingybob.create(:name => 'Foo') # activity create
    begin
      bob.bar
    rescue
    end
    assert bob.activity_log_stack.empty?, 'Stack was emptied after exception'
  end
  
  def test_method_with_exclamation_mark
    bob = Thingybob.create(:name => 'Foo') # activity create
    bob.bzz!
    
    activity_log = bob.activity_log
    assert_equal %w(create bzz), activity_log.map{|a| a.action}
  end
end