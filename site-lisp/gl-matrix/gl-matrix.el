;;; gl-matrix.el --- OpenGL matrix APIs implemented in Elisp   -*- lexical-binding: t; -*-

;; Author: Saltb0rn <asche34@outlook.com>

;; This file is not part of GNU Emacs.

;;; Code:

(require 'gl-matrix-vec2)
(require 'gl-matrix-vec3)
(require 'gl-matrix-vec4)

;; (defvar gl-matrix-epsilon 0.000001
;;   ""
;;   )

(defun sin-degrees (deg)
  (sin (degrees-to-radians deg)))

(defun asin-degrees (arg)
  (radians-to-degrees (asin arg)))

(defun cos-degrees (deg)
  (cos (degrees-to-radians deg)))

(defun acos-degrees (arg)
  (radians-to-degrees (acos arg)))

(defun tan-degrees (deg)
  (tan (degrees-to-radians deg)))

(defun atan-degrees (arg)
  (radians-to-degrees (atan arg)))

(provide 'gl-matrix)

;;; gl-matirx.el ends here
