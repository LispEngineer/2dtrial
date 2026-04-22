# Roguelike Trial

This is a proof of concept to see if I can build a simple 
roguelike game in Common Lisp using the Trial game engine.

Authors:
* Douglas P. Fields, Jr.

Copyright:
* Copyright 2026 Douglas P. Fields, Jr.

Date began:
* 2026-04-19

References:
* [Trial Game Engine](https://shirakumo.org/docs/trial/index.html)
* [Alive VS Code](https://marketplace.visualstudio.com/items?itemName=rheller.alive)

# Instructions

To load the game:
* Set up SBCL
* Set up ASDF & QuickLisp
* Use `rlwrap` if desired, or `icl`
  * To use `icl` you need an SBCL compiled with `zstd` support.
  * I got that from Roswell, as the official Linux binary does not have it.
* Launch SBCL
  * `rlwrap sbcl --dynamic-space-size 5Gb` (anything ≥ 4)
  * ICL will need a configuration file to set the dynamic space size
    * `~/.config/icl/config.lisp`
    * ```lisp
      (icl:configure-lisp :sbcl
        :program "/home/dfields/.roswell/impls/x86-64/linux/sbcl-bin/2.6.3/bin/sbcl"
        :args '("--dynamic-space-size" "5Gb"))
      ```
    * `icl -v --no-cache` 
      * I can't seem to figure out how to get it to create the image with higher DSS
* Test Trial if desired
  * `(ql:quickload "trial-examples")`
  * `(trial-examples:launch)`
* Run the game:
  * `(push '*default-pathname-defaults* asdf:*central-registry*)`
    * This adds the current directory to the ASDF / QuickLisp search path
  * `(ql:quickload :2dtrial)`
  * `(2dtrial:launch)`