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


# Miscellaneous

## Alive VS Code Notes

Add this to `settings.json` for proper DSS:
```json
    "alive.lsp.startCommand": [
        "sbcl",
        "--dynamic-space-size", "5Gb",
        "--eval",
        "(ql:quickload '(:bordeaux-threads :usocket :cl-json :flexi-streams))",
        "--eval",
        "(require :asdf)",
        "--eval",
        "(asdf:load-system :alive-lsp)",
        "--eval",
        "(alive/server:start)"
    ]
```

Then run this command for each working directory:
* `(push "/home/dfields/src/cl/2dtrial/" asdf:*central-registry*)`

Add this for nicer rainbow parens:
```json
    "workbench.colorCustomizations": {
        "editor.background": "#000000",
        // Set up better and six rainbow parens
        "editorBracketHighlight.foreground1": "#FF0000",
        "editorBracketHighlight.foreground2": "#FF7F00",
        "editorBracketHighlight.foreground3": "#FFFF00",
        "editorBracketHighlight.foreground4": "#00FF00",
        "editorBracketHighlight.foreground5": "#007FFF",
        "editorBracketHighlight.foreground6": "#8B00FF"
    },
```