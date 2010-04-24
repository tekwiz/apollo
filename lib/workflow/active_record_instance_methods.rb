module Workflow
  module ActiveRecordInstanceMethods
    def load_workflow_state
      read_attribute(self.class.workflow_column)
    end

    # On transition the new workflow state is immediately saved in the
    # database.
    def persist_workflow_state(new_value)
      update_attribute self.class.workflow_column, new_value
    end

    private

    # Motivation: even if NULL is stored in the workflow_state database column,
    # the current_state is correctly recognized in the Ruby code. The problem
    # arises when you want to SELECT records filtering by the value of initial
    # state. That's why it is important to save the string with the name of the
    # initial state in all the new records.
    def write_initial_state
      write_attribute self.class.workflow_column, current_state.to_s
    end
  end
end
