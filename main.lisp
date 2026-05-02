;; Douglas P. Fields, Jr.

(in-package #:2dtrial)

;;; ==========================================
;;; ENGINE AND WINDOW SETUP
;;; ==========================================

;; Starting configuration
(defparameter starting-width 1920)
(defparameter starting-height 1080)
(defparameter sprite-size 32)
(defparameter font-size 30)

;; TODO: FIgure out why the width & height are (seemingly?) ignored,
;; and the initial window displayable area is 1536x864.

;; Define our main game class, inheriting from Trial's base `main` class.
;; This class represents our running application and the OS window.
(defclass main (trial:main)
  ()
  (:default-initargs
   ;; 2. Pass the :title property into the :context initarg
   :context '(:title "Cat Game" 
              ;; TODO: Figure out why using starting-width/height here causes a failure
              :width 1920 :height 1080
              :version (3 3) 
              :profile :core)))

;; A convenient wrapper to start our game from the REPL.
(defun launch (&rest args)
  ;; This applies any launch arguments to Trial's internal initialization, targeting our window.
  (apply #'trial:launch 'main args))

;;; =========================================
;;; Window handling
;;; =========================================


;;; =========================================
;;; UI
;;; =========================================

;; Following docs: https://shirakumo.org/docs/trial/alloy.html

(define-shader-pass ui (org.shirakumo.fraf.trial.alloy:base-ui) ())

(defclass hud (org.shirakumo.fraf.trial.alloy:panel listener) ())

(defclass large-label (alloy:label) ())

#|
; This output doesn't really explain much to me
(print (macroexpand-1
'(presentations:define-realization (alloy:ui large-label)
  ((:label simple:text)
   (alloy:margins); (... 0 0 0 font-size) ;; a b c d = d shifts things UP; a = shifts things RIGHT
   alloy:text
   :size (alloy:un font-size) ; Set font size here (40 units)
   :halign :start
   :valign :bottom))))
|#

(presentations:define-realization (alloy:ui large-label)
  ((:label simple:text)
   (alloy:margins); (... 0 0 0 font-size) ;; a b c d = d shifts things UP; a = shifts things RIGHT
   alloy:text
   :size (alloy:un font-size) ; Set font size here (40 units)
   :halign :start
   :valign :bottom))

(defmethod initialize-instance :after ((hud hud) &key)
  (let* ((cat (trial:node :cat (trial:scene trial:+main+)))
         (root (make-instance 'alloy:border-layout))
         (sidebar (make-instance 'alloy:vertical-linear-layout :cell-margins (alloy:margins 0)))
         ;; Use the correct observable slots from the cat-sprite
         (label-x (alloy:represent (cat-x-str cat) 'large-label))
         (label-y (alloy:represent (cat-y-str cat) 'large-label)))
    
    (alloy:enter label-x sidebar)
    (alloy:enter label-y sidebar)
    (alloy:enter sidebar root :place :east :size (alloy:un 400))
    (alloy:finish-structure hud root NIL)))


;;; ==========================================
;;; SPRITE ENTITY SETUP
;;; ==========================================

;; Load the Cat picture from disk
(define-asset (trial cat) image
  #p"cat.png")

;; Define the cat sprite. We combine several "mixin" classes provided by Trial:
;; - vertex-entity: Gives the object geometric shape (a flat square in our case).
;; - textured-entity: Allows the entity to be painted with an image.
;; - transformed-entity: Gives the entity position, scale, and rotation coordinates.
;; - listener: Hooks the entity into Trial's event system to listen for keyboard inputs.
(define-shader-entity cat-sprite (vertex-entity textured-entity transformed-entity listener alloy:observable-object)
  ;; (// 'trial 'cat) pulls the built-in cat.png asset natively shipped with the engine.
  ((texture :initform (// 'trial 'cat))
   ;; We use a 1x1 flat geometric square (`unit-square`) to stretch the texture over.
   (vertex-array :initform (// 'trial 'unit-square))
   ;; A custom slot to keep track of the cat's movement vector.
   ;; We initialize it to a 2D vector of (0.0, 0.0)
   (velocity :initform (vec2 0.0 0.0) :accessor velocity)
   (cat-x-str :initform "X: 0.0" :accessor cat-x-str)
   (cat-y-str :initform "Y: 0.0" :accessor cat-y-str)))

(defmethod (setf cat-x-str) :after (value (sprite cat-sprite))
  (alloy:notify-observers 'cat-x-str sprite value sprite))

(defmethod (setf cat-y-str) :after (value (sprite cat-sprite))
  (alloy:notify-observers 'cat-y-str sprite value sprite))


;;; ==========================================
;;; INPUT HANDLING (WASD)
;;; ==========================================

;; Handle the exact moment a key is pressed down.
(define-handler (cat-sprite key-press) (key)
  ;; 'vy' accesses the Y axis (up/down). 'vx' accesses the X axis (left/right).
  (case key
    (:w (setf (vy (velocity cat-sprite))  1.0))   ;; Move UP
    (:s (setf (vy (velocity cat-sprite)) -1.0))   ;; Move DOWN
    (:a (setf (vx (velocity cat-sprite)) -1.0))   ;; Move LEFT
    (:d (setf (vx (velocity cat-sprite))  1.0)))) ;; Move RIGHT

;; Handle the exact moment a key is released.
(define-handler (cat-sprite key-release) (key)
  ;; We only stop the axis if the released key matches the current direction of the velocity.
  ;; This prevents the sprite from stopping if the player rolls their fingers across opposite keys.
  (case key
    (:w (when (> (vy (velocity cat-sprite)) 0.0) (setf (vy (velocity cat-sprite)) 0.0)))
    (:s (when (< (vy (velocity cat-sprite)) 0.0) (setf (vy (velocity cat-sprite)) 0.0)))
    (:a (when (< (vx (velocity cat-sprite)) 0.0) (setf (vx (velocity cat-sprite)) 0.0)))
    (:d (when (> (vx (velocity cat-sprite)) 0.0) (setf (vx (velocity cat-sprite)) 0.0)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun current-camera ()
  "Returns the active camera for the current scene."
  (trial:camera (trial:scene trial:+main+)))

(defun get-visible-area ()
  "Returns the visible bounds of the 2D camera."
  (let* ((camera (current-camera))
         (loc (trial:location camera))
         (x (vx loc))
         (y (vy loc))

         ;; Get the current screen/window dimensions from the active context
         (w (trial:width trial:*context*))
         (h (trial:height trial:*context*)))
    (list x y (+ x w) (+ y h))))

(defun print-visible-area ()
  "Prints the visible bounds of the 2D camera."
  (destructuring-bind (x y w h) (get-visible-area)
    (format t "x: ~a, y: ~a, w: ~a, h: ~a" x y w h)))


;;; ==========================================
;;; MOVEMENT AND BOUNDARY COLLISION
;;; ==========================================

;; Debugging variables
(defparameter oldx -1100)
(defparameter oldy -1100)

;; The `tick` handler fires every single frame. 
;; `dt` is the "delta time" (fraction of a second) since the last frame.
(define-handler (cat-sprite tick) (dt)
  (let* ((pos (location cat-sprite))       ; The current 3D position vector
         (vel (velocity cat-sprite))       ; The current 2D movement vector
         (cat-speed 100.0)                     ; Movement speed in pixels per second
         (cam-info (get-visible-area))
         (cam-x (first cam-info)) ;; Should just use destructuring-bind
         (cam-y (second cam-info))
         (cam-w (third cam-info))
         (cam-h (fourth cam-info))
         (half-size (/ sprite-size 2))
         (cat-min-x (+ cam-x half-size))
         (cat-max-x (- cam-w half-size))
         (cat-min-y (+ cam-y half-size))
         (cat-max-y (- cam-h half-size)))

    ;; Update position: Add velocity scaled by speed and `dt`. 
    ;; Scaling by `dt` guarantees the sprite moves at the same speed regardless of the monitor's refresh rate.
    (incf (vx pos) (* (vx vel) cat-speed (float dt 0f0)))
    (incf (vy pos) (* (vy vel) cat-speed (float dt 0f0)))

    ;; Clamp the position to the visible area.
    (setf (vx pos) (max cat-min-x (min cat-max-x (vx pos))))
    (setf (vy pos) (max cat-min-y (min cat-max-y (vy pos))))
    ; Print some debugging
    (unless (and (equal (vx pos) oldx) (equal (vy pos) oldy))
      (progn
        ;; Update observable slots
        (setf (cat-x-str cat-sprite) (format nil "X: ~,1f" (vx pos)))
        (setf (cat-y-str cat-sprite) (format nil "Y: ~,1f" (vy pos)))
        (print pos)
        (print-visible-area)))
    (setf oldx (vx pos))
    (setf oldy (vy pos))))


;;; ==========================================
;;; SCENE, CAMERA, AND RENDER PIPELINE SETUP
;;; ==========================================

;; This method is automatically called when Trial has initialized the window and needs to build the game scene.
;; Events are passed to the scene, which propagates it to all the entities within it.
;; So, this controls the order of what happens.
(defmethod setup-scene ((main main) scene)

  ;; 1. SET UP THE CAMERA
  ;; We instantiate a `2d-camera` and `enter` it into the scene.
  ;; The 2d-camera automatically utilizes an orthographic projection matrix instead of a perspective matrix.
  ;; This means there is no 3D depth, vanishing points, or distortion. It maps the coordinate system such that 
  ;; 1 unit of game space perfectly equals 1 pixel on the physical screen.
  ;; The displayed window coordinates will be 0,0 at the bottom left corner, 
  ;; and 1920,1080 minus the window border at the top right corner.
  (enter (make-instance '2d-camera :location (vec 0 0)) scene)

  ;; 2. SET UP THE SPRITE
  ;; We instantiate our `cat-sprite` and enter it into the scene.
  ;; :location - Put it at the (almost) center of the window.
  ;; :scaling - We initialized the sprite geometry with a 1x1 `unit-square`. By setting the `:scaling` vector 
  ;; to (32.0, 32.0, 1.0), we stretch that 1x1 unit square to 32x32 units. Because the 2d-camera maps 1 unit to 1 pixel, 
  ;; our sprite perfectly renders as a 32x32 pixel image.
  ;; The CENTER of the image is at this location, and it extends 16 pixels in all 4 directions.
  (enter (make-instance 'cat-sprite 
                        :name :cat
                        :location (vec (/ starting-width 2) (/ starting-height 2) 0.0)
                        :scaling (vec sprite-size sprite-size 1.0))
         scene)

  ;; 3. SET UP THE RENDER PIPELINE
  (let ((game (make-instance 'render-pass))
        (ui (make-instance 'ui))
        (combine (make-instance 'blend-pass)))
    (enter combine scene)
    (connect (port game 'color) (port combine 'a-pass) scene)
    (connect (port ui 'color) (port combine 'b-pass) scene)
    ;; Show our hud panel and register it as a listener so it moves.
    (org.shirakumo.fraf.trial.alloy:show-panel 'hud)))
;    (enter (org.shirakumo.fraf.trial.alloy:show-panel 'hud) scene)))


;; Debugging:
;; Ask CLOS to list all direct subclasses of trial:event
;; (c2mop:class-direct-subclasses (find-class 'trial:event))