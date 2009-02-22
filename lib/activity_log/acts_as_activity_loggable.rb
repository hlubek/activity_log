module ActivityLog
  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
    # Automatically log calls to the methods and
    # create an +ActivityEntry+ with record id and type.
    #
    # Note: acts_as_activity_loggable has to be called *after* defining the methods.
    def acts_as_activity_loggable(methods, options = {})
      send :include, InstanceMethods

      options = {
        :user => nil
      }.merge(options)
      
      cattr_accessor :loggable_activities
      self.loggable_activities = methods.to_a
      
      loggable_activities.each do |a|
        method, symbol = a.to_s.split /(\!|\?)/
        symbol = '' if symbol.nil?
        define_method((method + '_with_log' + symbol).to_sym) do
          @activity_log_stack ||= []
          @activity_log_stack.push method
          begin
            send (method + '_without_log' + symbol)
          ensure
            @activity_log_stack.pop
          end
          if @activity_log_stack.empty?
            user = options[:load_user].call if options[:load_user]
            user_id = user.id unless user.nil?
            ActivityEntry.create!(:action => method, :entity_id => self.id, :entity_type => self.class.to_s, :account_id => user_id)
          end
        end
        alias_method_chain (method + symbol), :log # ??? works only after defining the method to be chained
      end
            
      has_many :activity_entries, :as => :entity
    end
  end

  module InstanceMethods
    # Get the activity entries
    def activity_log
      activity_entries
    end
  end
end

ActiveRecord::Base.send :include, ActivityLog
