module Apollo
  class State
    attr_accessor :name, :events, :meta, :on_entry, :on_exit

    def initialize(name, meta = {})
      @name, @events, @meta = name, Hash.new, meta
    end

    def to_s
      "#{name}"
    end

    def to_sym
      name.to_sym
    end
  end
end