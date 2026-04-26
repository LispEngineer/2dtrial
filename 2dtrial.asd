(asdf:defsystem 2dtrial
  :components ((:file "package")
               (:file "main"))
  ;; We require the core trial system, the GLFW windowing backend 
  ;; (highly recommended for Linux/KDE), and the PNG loader for our cat sprite.
  :depends-on (:trial
               :trial-glfw
               :trial-png
               :trial-alloy))
