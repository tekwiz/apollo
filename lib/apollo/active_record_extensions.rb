module Apollo
  module ActiveRecordExtensions
    module InstanceMethods
      def load_current_state
        result = if self.class.persist_string_state_name?
          read_attribute(self.class.current_state_column)
        else
          id = read_attribute(self.class.current_state_id_column)
          self.class.state_id_to_name(id) if id
        end

        result || self.default_state
      end

      def current_state=(new_value)
        if self.class.persist_string_state_name?
          self[self.class.current_state_column] = new_value
        else
          self[self.class.current_state_id_column] = self.class.state_name_to_id(new_value)
       end
       self.save! unless self.new_record?
      end

      private

      # Motivation: even if NULL is stored in the current_state database column,
      # the current_state is correctly recognized in the Ruby code. The problem
      # arises when you want to SELECT records filtering by the value of initial
      # state. That's why it is important to save the string with the name of the
      # initial state in all the new records.
      def write_initial_state
        if self.class.persist_string_state_name?
          write_attribute self.class.current_state_column, current_state.to_s
        else
          write_attribute self.class.current_state_id_column,
                          self.class.state_name_to_id(current_state.to_s)
        end
      end
    end
    
    module ClassMethods
      def state_set_sql( set_name, options = {} )
        quotes    = (options[:quotes]    or %('))
        join      = (options[:join]      or %(,))
        surround  = (options[:surround]  or ['(',')'])
      
        str = state_machine.state_sets[set_name.to_sym].state_names
        if persist_string_state_name?
          str = str.collect { |state_name| quotes + state_name + quotes }.join(join)
        else
          str = str.collect { |state_name| state_name_to_id(state_name) }.join(join)
        end
        surround.first + str + surround.last
      end
      
      def persist_string_state_name?
        self.column_names.include?(self.current_state_column)
      end
      
      def state_id_to_name(state_id)
        result = ActiveRecord::Base.connection.query "SELECT name FROM states WHERE klass = '#{self.to_s}' AND id = #{state_id}"
        raise "Cannot find state." if result.empty?
        result[0][0]
      end
      
      def state_name_to_id(state_name)
        result = ActiveRecord::Base.connection.query "SELECT id FROM states WHERE klass = '#{self.to_s}' AND name = '#{state_name}'"
        raise "Cannot find state" if result.empty?
        result[0][0]
      end
      
      def current_state_id_column
        self.current_state_column.to_s+"_id"
      end
    end
  end
end
