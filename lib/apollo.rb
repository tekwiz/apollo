# Copyright 2010 Travis D. Warlick, Jr.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Original work from Workflow:
#     Copyright (c) 2008-2009 Vodafone
#     Copyright (c) 2007-2008 Ryan Allen, FlashDen Pty Ltd
module Apollo
  autoload :Event,                        'apollo/event'
  autoload :State,                        'apollo/state'
  autoload :Specification,                'apollo/specification'
  autoload :ActiveRecordInstanceMethods,  'apollo/active_record_instance_methods'
  
  # The current version
  VERSION = File.read(File.join(File.expand_path(File.dirname(__FILE__)), '..', 'VERSION')).strip
  
  class TransitionHalted < Exception
    attr_reader :halted_because

    def initialize(msg = nil)
      @halted_because = msg
      super msg
    end
  end

  class NoTransitionAllowed < Exception; end

  class ApolloError < Exception; end

  class ApolloDefinitionError < Exception; end
  
  module ClassMethods
    def current_state_column(column_name=nil)
      if column_name
        @current_state_column_name = column_name.to_sym
      else
        @current_state_column_name ||= :current_state
      end
      @current_state_column_name
    end

    def state_machine(&specification)
      return @apollo_spec unless block_given?
      
      @apollo_spec = Specification.new(Hash.new, &specification)
      @apollo_spec.states.values.each do |state|
        state_name = state.name
        module_eval do
          define_method "#{state_name}?" do
            state_name == current_state.name
          end
        end

        state.events.values.each do |event|
          event_name = event.name
          module_eval do
            define_method "#{event_name}!".to_sym do |*args|
              process_event!(event_name, *args)
            end
          end
        end
      end
      
      @apollo_spec.state_sets.keys.each do |set_name|
        module_eval do
          define_method "#{set_name}?" do
            current_state.sets.include?(set_name)
          end
        end
      end
    end
  end

  module InstanceMethods
    def current_state
      loaded_state = load_current_state
      res = spec.states[loaded_state.to_sym] if loaded_state
      res || spec.initial_state
    end

    def halted?
      @halted
    end

    def halted_because
      @halted_because
    end

    def process_event!(name, *args)
      event = current_state.events[name.to_sym]
      raise NoTransitionAllowed.new(
        "There is no event #{name.to_sym} defined for the #{current_state} state") \
        if event.nil?
      # This three member variables are a relict from the old workflow library
      # TODO: refactor some day
      @halted_because = nil
      @halted = false
      @raise_exception_on_halt = false
      return_value = run_action(event.action, *args) || run_action_callback(event.name, *args)
      if @halted
        if @raise_exception_on_halt
          raise @raise_exception_on_halt
        else
          false
        end
      else
        check_transition(event)
        run_on_transition(current_state, spec.states[event.to], name, *args)
        transition(current_state, spec.states[event.to], name, *args)
        return_value
      end
    end

    private

    def check_transition(event)
      # Create a meaningful error message instead of
      # "undefined method `on_entry' for nil:NilClass"
      # Reported by Kyle Burton
      if !spec.states[event.to]
        raise ApolloError.new("Event[#{event.name}]'s " +
            "to[#{event.to}] is not a declared state.")
      end
    end

    def spec
      c = self.class
      # using a simple loop instead of class_inheritable_accessor to avoid
      # dependency on Rails' ActiveSupport
      until c.state_machine || !(c.include? Apollo)
        c = c.superclass
      end
      c.state_machine
    end

    def halt(reason)
      @halted_because = reason
      @halted = true
      @raise_exception_on_halt = false
    end

    def halt!(reason, exception_klass = TransitionHalted)
      @halted_because = reason
      @halted = true
      if exception_klass.class == Class
        @raise_exception_on_halt = exception_klass.new(reason)
      else
        @raise_exception_on_halt = exception_klass
      end
      @raise_exception_on_halt.set_backtrace(caller)
    end

    def transition(from, to, name, *args)
      run_on_exit(from, to, name, *args)
      persist_current_state to.to_s
      run_on_entry(to, from, name, *args)
    end

    def run_on_transition(from, to, event, *args)
      instance_exec(from.name, to.name, event, *args, &spec.on_transition_proc) if spec.on_transition_proc
    end

    def run_action(action, *args)
      instance_exec(*args, &action) if action
    end

    def run_action_callback(action_name, *args)
      self.send action_name.to_sym, *args if self.respond_to?(action_name.to_sym)
    end

    def run_on_entry(state, prior_state, triggering_event, *args)
      if state.on_entry
        instance_exec(prior_state.name, triggering_event, *args, &state.on_entry)
      else
        hook_name = "on_#{state}_entry"
        self.send hook_name, prior_state, triggering_event, *args if self.respond_to? hook_name
      end
    end

    def run_on_exit(state, new_state, triggering_event, *args)
      if state
        if state.on_exit
          instance_exec(new_state.name, triggering_event, *args, &state.on_exit)
        else
          hook_name = "on_#{state}_exit"
          self.send hook_name, new_state, triggering_event, *args if self.respond_to? hook_name
        end
      end
    end

    # load_current_state and persist_current_state
    # can be overriden to handle the persistence of the current state.
    #
    # Default (non ActiveRecord) implementation stores the current state
    # in a variable.
    #
    # Default ActiveRecord implementation uses a 'current_state' database column.
    def load_current_state
      @current_state if instance_variable_defined? :@current_state
    end

    def persist_current_state(new_value)
      @current_state = new_value
    end
  end

  def self.included(klass)
    klass.send :include, InstanceMethods
    klass.extend ClassMethods
    if Object.const_defined?(:ActiveRecord)
      if klass < ActiveRecord::Base
      klass.send :include, ActiveRecordInstanceMethods
      klass.before_validation :write_initial_state
      end
    end
  end

  # Generates a `dot` graph of the state machine.
  # Prerequisite: the `dot` binary.
  # You can use it in your own Rakefile like this:
  #
  #     namespace :doc do
  #       desc "Generate a graph of the state machine."
  #       task :state_machine do
  #         Apollo::create_state_diagram(Order.new)
  #       end
  #     end
  #
  # You can influence the placement of nodes by specifying
  # additional meta information in your states and transition descriptions.
  # You can assign higher `doc_weight` value to the typical transitions
  # in your state machine. All other states and transitions will be arranged
  # around that main line. See also `weight` in the graphviz documentation.
  # Example:
  #
  #     state :new do
  #       event :approve, :to => :approved, :meta => {:doc_weight => 8}
  #     end
  #
  #
  # @param klass A class with the Apollo mixin, for which you wish the graphical state machine representation
  # @param [String] target_dir Directory, where to save the dot and the pdf files
  # @param [String] graph_options You can change graph orientation, size etc. See graphviz documentation
  def self.create_state_diagram(klass, target_dir, graph_options='rankdir="LR", size="7,11.6", ratio="fill"')
    state_machine_name = "#{klass.name.tableize}_state_machine"
    fname = File.join(target_dir, "generated_#{state_machine_name}")
    File.open("#{fname}.dot", 'w') do |file|
      file.puts %Q|
digraph #{state_machine_name} {
  graph [#{graph_options}];
  node [shape=box];
  edge [len=1];
      |

      klass.state_machine.states.each do |state_name, state|
        file.puts %Q{  #{state.name} [label="#{state.name}"];}
        state.events.each do |event_name, event|
          meta_info = event.meta
          if meta_info[:doc_weight]
            weight_prop = ", weight=#{meta_info[:doc_weight]}"
          else
            weight_prop = ''
          end
          file.puts %Q{  #{state.name} -> #{event.to} [label="#{event_name.to_s.humanize}" #{weight_prop}];}
        end
      end
      file.puts "}"
      file.puts
    end
    `dot -Tpdf -o#{fname}.pdf #{fname}.dot`
    puts "
Please run the following to open the generated file:

open #{fname}.pdf

"
  end
end
