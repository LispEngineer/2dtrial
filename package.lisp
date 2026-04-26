(defpackage #:2dtrial
  (:use #:cl+trial)
  (:shadow #:main #:launch)
  (:local-nicknames
   (#:v #:org.shirakumo.verbose)
   (#:sequences #:org.shirakumo.trivial-extensible-sequences)
   (#:trial #:org.shirakumo.fraf.trial)
   (#:alloy #:org.shirakumo.alloy)
   (#:simple #:org.shirakumo.alloy.renderers.simple)
   (#:chroma #:org.shirakumo.alloy.chroma)
   (#:colors #:org.shirakumo.alloy.chroma.colors)
   (#:presentations #:org.shirakumo.alloy.renderers.simple.presentations)
   (#:trial-alloy #:org.shirakumo.fraf.trial.alloy))
  (:export #:main #:launch))
