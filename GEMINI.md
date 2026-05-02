# Gemini CLI Instructions

This document contains instructions to the Gemini CLI agent,
in case we want to interact with it for doing any software
development, asking questions, running tests, etc.

# Language

This code is written in Common Lisp.

The compiler is [SBCL v2.6.3](https://www.sbcl.org/).

[This is the manual for SBCL](https://www.sbcl.org/manual/).

It is running on Ubuntu 24.04 on the x86_64 platform.

There are several places with the Common Lisp Hyperspec in
various formats:
* [HyperSpec](https://www.lispworks.com/documentation/HyperSpec/Front/index.htm)
* [Nova Spec](https://novaspec.org/cl/)
* [GitHub Hyperspec](https://cl-community-spec.github.io/pages/index.html)

Some useful Common Lisp documentation:
* [Practical Common Lisp](https://gigamonkeys.com/book/)
* [Common Lisp Cookbook](https://lispcookbook.github.io/cl-cookbook/)
* [Common Lisp Recipes]() is not available in HTML format online.
* [Common Lisp: The Language](https://www.cs.cmu.edu/Groups/AI/html/cltl/cltl2.html)

# Libraries

The core libraries in use are:
* Package management: [ASDF GitHub](https://github.com/fare/asdf)
  * [ASDF Manual](https://asdf.common-lisp.dev/)
* Packages: [QuickLisp Manual](www.quicklisp.org/beta/)
  * [QuickLisp Libraries](https://www.quicklisp.org/beta/releases.html)

The main game-related libraries in use are:
* [Trial Game Engine](https://shirakumo.org/docs/trial/index.html) Documentation
  * [Trial Source Code](https://codeberg.org/shirakumo/trial)
* [Alloy UI Engine](https://shirakumo.org/docs/alloy/) Documentation
  * [Using Alloy in Trial](https://shirakumo.org/docs/trial/alloy.html)
  * [Alloy Source Code](https://codeberg.org/shirakumo/alloy).

# Launching SBCL

The Trial game engine requires at least 4 GB of dynamic memory to operate.
To launch SBCL with additional dynamic memory, a command line parameter
must be passed. Let's use 8 GB for this, just in case. To launch SBCL,
use this command line:
* `sbcl --dynamic-space-size 8Gb`

To load and execute the game from the top level directory, these three
commands are neeeded:
* `(push '*default-pathname-defaults* asdf:*central-registry*)`
  * This adds the current working directory to the load path for ASDF/QuickLisp.
* `(ql:quickload :2dtrial)`
* `(2dtrial:launch)`

# Game Type

The game being developed is a 2D roguelike game with turn based semantics.

The game board will be presented using Trial engine with an orthographic
2D camera. The game information will be presented using the Alloy UI
framework as an overlay over the 2D camera. The right side of the screen
will be entirely reserved for this UI, covering about 25-33% of the
right side of the screen from top to bottom.

The UI and the game board will be re-sizeable independently.

The order of actions that happens will be maintained in a Priority Queue
of events organized by time, with tie-breakers. The player's action will
be one type of event, and when encountered the game will pause to allow
the player to select their next action.

# General Instructions

* Do include detailed comments with any code written,
  or changes to code made.
