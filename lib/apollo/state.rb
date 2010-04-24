module Apollo
  class State
    attr_accessor :name, :events, :meta, :on_entry, :on_exit, :sets

    def initialize(name, meta = {})
      @name, @events, @meta, @sets = name, Hash.new, meta, Set.new
    end

    def to_s
      "#{name}"
    end

    def to_sym
      name.to_sym
    end
  end
end
