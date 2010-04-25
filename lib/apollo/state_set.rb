module Apollo
  class StateSet < Set
    def state_names
      collect {|state| state.name.to_s}
    end
  end
end
