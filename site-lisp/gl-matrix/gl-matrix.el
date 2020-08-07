;;; gl-matrix.el --- OpenGL matrix APIs implemented in Elisp   -*- lexical-binding: t; -*-

;; Author: Saltb0rn <asche34@outlook.com>

;; This file is not part of GNU Emacs.

;;; Commentary:
;;;     This library represents all matricies in row-major format:

;;;     [ 1, 0, 0, x
;;;       0, 1, 0, y,
;;;       0, 0, 1, z,
;;;       0, 0, 0, 1 ]

;;; Code:

(require 'gl-matrix-vec2)
(require 'gl-matrix-vec3)
(require 'gl-matrix-vec4)

;; (defvar gl-matrix-epsilon 0.000001
;;   ""
;;   )

(defun gl-matrix-ref-index (size row col)
  "Calculates index of matrix according index of row and index of col.

Returns a index."
  (unless (and (integerp size) (integerp row) (integerp col))
    (error "gl-matrix-ref-index: All arguments must be integral!"))
  (unless (and
           (> size 0)
           (>= row 0) (>= col 0)
           (< row size) (< col size))
    (error "gl-matrix-ref-index: Arguments should satisfy 0 <= row, col < size"))
  (+ (* row size) col))

(defun gl-matrix-ref (size row col)
  "Calculates index of matrix according row and col.

Returns a index."
  (gl-matrix-ref-index size (- row 1) (- col 1)))

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
