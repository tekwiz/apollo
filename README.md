What is apollo?
===============

> In Greek and Roman mythology, Apollo (in Greek, Ἀπόλλων—Apóllōn or Ἀπέλλων—Apellōn), 
> is one of the most important and diverse of the Olympian deities. The ideal of the 
> kouros (a beardless youth), Apollo has been variously recognized as a god of light 
> and the sun; truth and prophecy; archery; medicine, healing and plague; music, 
> poetry, and the arts; and more. Apollo is the son of Zeus and Leto, and has a twin 
> sister, the chaste huntress Artemis. [Wikipedia: Dionysus (2010/04/23)](http://en.wikipedia.org/wiki/Apollo)

Apollo is an fork of [Workflow](http://github.com/geekq/workflow).

Resources
---------

* [Github Project](http://github.com/tekwiz/apollo)
* [Rdocs on Rdoc.info](http://rdoc.info/projects/tekwiz/apollo)
* [Wiki on Github](http://wiki.github.com/tekwiz/apollo/)
* [Issues Tracker on Github](http://github.com/tekwiz/apollo/issues)
* [Metrics on Caliper](http://getcaliper.com/caliper/project?repo=http%3A%2F%2Frubygems.org%2Fgems%2Fapollo)

Features & Issues
-----------------

This is a brand new project, so if you find bugs or use cases that would helpful to satisfy, post an [Issue](http://github.com/tekwiz/apollo/issues) on Github.

This project is intended to be a **very** eclectic mix of helpful tools, so please feel free to send pull requests.  That said, make **absolutely sure** your modifications are well tested.  The hodge-podge nature of this project may make it prone to issues, so no code will be pulled-in that is not __fully_tested__.

Note on Patches/Pull Requests
-----------------------------

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

### Documentation Warning

Beware that the below documentation has NOT been validated for the changes from Workflow to Apollo.

What is workflow?
-----------------

Workflow is a finite-state-machine-inspired API for modeling and
interacting with what we tend to refer to as 'apollo'.

A lot of business modeling tends to involve apollo-like concepts, and
the aim of this library is to make the expression of these concepts as
clear as possible, using similar terminology as found in state machine
theory.

So, a workflow has a state. It can only be in one state at a time. When
a workflow changes state, we call that a transition. Transitions occur
on an event, so events cause transitions to occur. Additionally, when an
event fires, other arbitrary code can be executed, we call those actions.
So any given state has a bunch of events, any event in a state causes a
transition to another state and potentially causes code to be executed
(an action). We can hook into states when they are entered, and exited
from, and we can cause transitions to fail (guards), and we can hook in
to every transition that occurs ever for whatever reason we can come up
with.

Now, all that's a mouthful, but we'll demonstrate the API bit by bit
with a real-ish world example.

Let's say we're modeling article submission from journalists. An article
is written, then submitted. When it's submitted, it's awaiting review.
Someone reviews the article, and then either accepts or rejects it.
Here is the expression of this apollo using the API:

    class Article
      include Apollo
      apollo do
        state :new do
          event :submit, :to => :awaiting_review
        end
        state :awaiting_review do
          event :review, :to => :being_reviewed
        end
        state :being_reviewed do
          event :accept, :to => :accepted
          event :reject, :to => :rejected
        end
        state :accepted
        state :rejected
      end
    end

Nice, isn't it!

Let's create an article instance and check in which state it is:

    article = Article.new
    article.accepted? # => false
    article.new? # => true

You can also access the whole `current_state` object including the list
of possible events and other meta information:

    article.current_state 
    => #<Apollo::State:0x7f1e3d6731f0 @events={
      :submit=>#<Apollo::Event:0x7f1e3d6730d8 @action=nil, 
        @to=:awaiting_review, @name=:submit, @meta={}>}, 
      name:new, meta{}

Now we can call the submit event, which transitions to the
<tt>:awaiting_review</tt> state:

    article.submit!
    article.awaiting_review? # => true
  
Events are actually instance methods on a apollo, and depending on the
state you're in, you'll have a different set of events used to
transition to other states.


Installation
------------

    gem install apollo

Alternatively you can just download the lib/apollo.rb and put it in
the lib folder of your Rails or Ruby application.


Examples
--------

After installation or downloading of the library you can easily try out
all the example code from this README in irb.

    $ irb
    require 'rubygems'
    require 'apollo'

Now just copy and paste the source code from the beginning of this README
file snippet by snippet and observe the output.


Transition event handler
------------------------

The best way is to use convention over configuration and to define a
method with the same name as the event. Then it is automatically invoked
when event is raised. For the Article apollo defined earlier it would
be:

    class Article
      def reject
        puts 'sending email to the author explaining the reason...'
      end
    end

`article.review!; article.reject!` will cause a state transition, persist the new state
(if integrated with ActiveRecord) and invoke this user defined reject
method.

You can also define event handler accepting/requiring additional
arguments:

    class Article
      def review(reviewer = '')
        puts "[#{reviewer}] is now reviewing the article"
      end
    end

    article2 = Article.new
    article2.submit!
    article2.review!('Homer Simpson') # => [Homer Simpson] is now reviewing the article


### The old, deprecated way

The old way, using a block is still supported but deprecated:

    event :review, :to => :being_reviewed do |reviewer|
      # store the reviewer
    end

We've noticed, that mixing the list of events and states with the blocks
invoked for particular transitions leads to a bumpy and poorly readable code
due to a deep nesting. We tried (and dismissed) lambdas for this. Eventually
we decided to invoke an optional user defined callback method with the same
name as the event (convention over configuration) as explained before.
      

Integration with ActiveRecord
-----------------------------

Apollo library can handle the state persistence fully automatically. You
only need to define a string field on the table called `apollo_state`
and include the apollo mixin in your model class as usual:

    class Order < ActiveRecord::Base
      include Apollo
      apollo do
        # list states and transitions here
      end
    end

On a database record loading all the state check methods e.g.
`article.state`, `article.awaiting_review?` are immediately available.
For new records or if the apollo_state field is not set the state
defaults to the first state declared in the apollo specification. In
our example it is `:new`, so `Article.new.new?` returns true and
`Article.new.approved?` returns false.

At the end of a successful state transition like `article.approve!` the
new state is immediately saved in the database.

You can change this behaviour by overriding `persist_apollo_state`
method.


### Custom apollo database column

[meuble](http://imeuble.info/) contributed a solution for using
custom persistence column easily, e.g. for a legacy database schema:

    class LegacyOrder < ActiveRecord::Base
      include Apollo
      
      apollo_column :foo_bar # use this legacy database column for
                               # persistence
    end



### Single table inheritance

Single table inheritance is also supported. Descendant classes can either
inherit the apollo definition from the parent or override with its own
definition.

Custom apollo state persistence
---------------------------------

If you do not use a relational database and ActiveRecord, you can still
integrate the apollo very easily. To implement persistence you just
need to override `load_apollo_state` and
`persist_apollo_state(new_value)` methods. Lets see an example for
using CouchDB, a document oriented database.

Integration with CouchDB
------------------------

We are using the compact [couchtiny library](http://github.com/geekq/couchtiny)
here. But the implementation would look similar for the popular
couchrest library.

    require 'couchtiny'
    require 'couchtiny/document'
    require 'apollo'

    class User < CouchTiny::Document
      include Apollo
      apollo do
        state :submitted do
          event :activate_via_link, :to => :proved_email
        end
        state :proved_email
      end

      def load_apollo_state
        self[:apollo_state]
      end

      def persist_apollo_state(new_value)
        self[:apollo_state] = new_value
        save!
      end
    end

Please also have a look at 
[the full source code](http://github.com/geekq/apollo/blob/master/test/couchtiny_example.rb).

Accessing your apollo specification
-------------------------------------

You can easily reflect on apollo specification programmatically - for
the whole class or for the current object. Examples:

    article2.current_state.events # lists possible events from here
    article2.current_state.events[:reject].to # => :rejected

    Article.apollo_spec.states.keys
    #=> [:rejected, :awaiting_review, :being_reviewed, :accepted, :new]

    # list all events for all states
    Article.apollo_spec.states.values.collect &:events


You can also store and later retrieve additional meta data for every
state and every event:

    class MyProcess
      include Apollo
      apollo do
        state :main, :meta => {:importance => 8}
        state :supplemental, :meta => {:importance => 1}
      end
    end
    puts MyProcess.apollo_spec.states[:supplemental].meta[:importance] # => 1

The apollo library itself uses this feature to tweak the graphical
representation of the apollo. See below.
 

Advanced transition hooks
-------------------------

### on_entry/on_exit

We already had a look at the declaring callbacks for particular apollo
events. If you would like to react to all transitions to/from the same state
in the same way you can use the on_entry/on_exit hooks. You can either define it
with a block inside the apollo definition or through naming
convention, e.g. for the state :pending just define the method
`on_pending_exit(new_state, event, *args)` somewhere in your class.

### on_transition

If you want to be informed about everything happening everywhere, e.g. for
logging then you can use the universal `on_transition` hook:

    apollo do
      state :one do
        event :increment, :to => :two
      end
      state :two
      on_transition do |from, to, triggering_event, *event_args|
        Log.info "#{from} -> #{to}"
      end
    end


### Guards

If you want to halt the transition conditionally, you can just raise an
exception. There is a helper called `halt!`, which raises the
Apollo::TransitionHalted exception. You can provide an additional
`halted_because` parameter.

    def reject(reason)
      halt! 'We do not reject articles unless the reason is important' \
        unless reason =~ /important/i
    end

The traditional `halt` (without the exclamation mark) is still supported
too. This just prevents the state change without raising an
exception.

### Hook order

The whole event sequence is as follows:

    * event specific action
    * on_transition (if action did not halt)
    * on_exit
    * PERSIST WORKFLOW STATE, i.e. transition
    * on_entry

Documenting with diagrams
-------------------------

You can generate a graphical representation of your apollo for
documentation purposes. S. Apollo::create_apollo_diagram.

Copyright
---------

    Copyright 2010 Travis D. Warlick, Jr.
    
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    
       http://www.apache.org/licenses/LICENSE-2.0
    
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

The original work from [Workflow](http://github.com/geekq/workflow)

    Author: Vladimir Dobriakov, http://www.innoq.com/blog/vd, http://blog.geekq.net/

    Copyright (c) 2008-2009 Vodafone

    Copyright (c) 2007-2008 Ryan Allen, FlashDen Pty Ltd

    Based on the work of Ryan Allen and Scott Barron

    Licensed under MIT license, see the MIT-LICENSE file.

Earlier versions
----------------

The `workflow` library was originally written by Ryan Allen.

The version 0.3 was almost completely (including ActiveRecord
integration, API for accessing apollo specification, 
method_missing free implementation) rewritten by Vladimir Dobriakov
keeping the original apollo DSL spirit.
