module Apollo
  class Specification
    attr_accessor :states, :initial_state, :meta, :on_transition_proc, :state_sets

    def initialize(meta = {}, &specification)
      @states = Hash.new
      @state_sets = Hash.new
      @meta = meta
      instance_eval(&specification)
    end

    private

    def state(name, meta = {:meta => {}}, &events_and_etc)
      validate_state_name(name)
      
      # meta[:meta] to keep the API consistent..., gah
      new_state = State.new(name, meta[:meta])
      @initial_state = new_state if @states.empty?
      @states[name.to_sym] = new_state
      @scoped_state = new_state
      instance_eval(&events_and_etc) if events_and_etc
    end
    
    def state_set(set_name, *state_names)
      validate_state_set_name(set_name)
      
      state_names.flatten!
      state_names.collect! {|n| n.to_sym}
      state_names.uniq!
      
      set = StateSet.new
      state_names.each do |state_name|
        if state = @states[state_name]
          set << state
          state.set_names << set_name.to_sym
        else
          raise ApolloDefinitionError, "Unknown state: #{state_name}"
        end
      end
      @state_sets[set_name] = set
    end

    def event(name, args = {}, &action)
      target = args[:to] || args[:to]
      raise ApolloDefinitionError.new(
        "missing ':to' in apollo event definition for '#{name}'") \
        if target.nil?
      @scoped_state.events[name.to_sym] =
        Event.new(name, target, (args[:meta] or {}), &action)
    end

    def on_entry(&proc)
      @scoped_state.on_entry = proc
    end

    def on_exit(&proc)
      @scoped_state.on_exit = proc
    end

    def on_transition(&proc)
      @on_transition_proc = proc
    end
    
    def validate_state_name(name)
      if @state_sets[name]
        raise ApolloDefinitionError, "State name conflicts with state set name: #{name}"
      end
    end
    
    def validate_state_set_name(name)
      if @states[name]
        raise ApolloDefinitionError, "State set name conflicts with state name: #{name}"
      end
    end
  end
end
