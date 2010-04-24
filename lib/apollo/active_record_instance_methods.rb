module Apollo
  module ActiveRecordInstanceMethods
    def load_current_state
      read_attribute(self.class.current_state_column)
    end

    # On transition the new current state is immediately saved in the
    # database.
    def persist_current_state(new_value)
      update_attribute self.class.current_state_column, new_value
    end

    private

    # Motivation: even if NULL is stored in the current_state database column,
    # the current_state is correctly recognized in the Ruby code. The problem
    # arises when you want to SELECT records filtering by the value of initial
    # state. That's why it is important to save the string with the name of the
    # initial state in all the new records.
    def write_initial_state
      write_attribute self.class.current_state_column, current_state.to_s
    end
  end
end
