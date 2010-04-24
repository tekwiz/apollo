Apollo Changelog
================

1.1

* Added state sets. (7498cf0)
* Unbranded methods. E.g. `Apollo::apollo` -> `Apollo::state_machine` (f8b42b8)

1.0
---
This is an initial release of the Apollo fork from [Workflow](http://github.com/geekq/workflow).  The reason I decided to fork Workflow, and in particular change the name, is because I feel that Workflow is an excellent starting point for my needs; however, my desire for Apollo is somewhat different from the desires of the creators of Workflow.  **In no way is my fork (and renaming) intended to be any kind of insult or intellectual rights infringement.**  I chose Workflow for the basis of Apollo because I feel it is the **best** state machine gem available.  I will most certainly maintain the original MIT-LICENSE as apart of Apollo so long as *any* portion of the code is derived from Workflow (which I suspect will always be the case).

* Rebranded modules from "workflow" to "apollo".
* Using [Jeweler](http://github.com/technicalpickles/jeweler).
* Removed unnecessary workflow.rb "initializer" file from root of project. (f2ac52a)
* Extracted Workflow submodules and classes into separated files. (6d4e90f)
* Changed default "column" name from `workflow_state` to `current_state`. (f562e71)
* Require reason for `halt` and allow arbitrary exception for `halt!`. (0f903d7)

Original Workflow Changelog
===========================

### New in the version 0.4.0

* completely rewritten the documentation to match my branch. Every
  described feature is backed up by an automated test.

### New in the version 0.3.0

Intermixing of transition graph definition (states, transitions)
on the one side and implementation of the actions on the other side
for a bigger state machine can introduce clutter.

To reduce this clutter it is now possible to use state entry- and 
exit- hooks defined through a naming convention. For example, if there
is a state :pending, then instead of using a
block:

    state :pending do
      on_entry do
        # your implementation here
      end
    end

you can hook in by defining method 

    def on_pending_exit(new_state, event, *args)
      # your implementation here
    end

anywhere in your class. You can also use a simpler function signature
like `def on_pending_exit(*args)` if your are not interested in
arguments.  Please note: `def on_pending_exit()` with an empty list
would not work.

If both a function with a name according to naming convention and the 
on_entry/on_exit block are given, then only on_entry/on_exit block is used.
