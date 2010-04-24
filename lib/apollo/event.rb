module Apollo
  class Event
    attr_accessor :name, :to, :meta, :action

    def initialize(name, to, meta = {}, &action)
      @name, @to, @meta, @action = name, to.to_sym, meta, action
    end
  end
end