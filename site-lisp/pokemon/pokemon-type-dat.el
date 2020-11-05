(require 'pokemon-utils)

(defcustom pokemon-type-rby-dat
  (expand-file-name "assets/pokedex-type-rby.json")
  "Path to data file of pokedex types since Gen 1"
  :type 'string)

(defcustom pokemon-type-gsc-dat
  (expand-file-name "assets/pokedex-type-gsc.json")
  "Path to data file of pokedex types since Gen 2"
  :type 'string)

(defcustom pokemon-type-gsc-dat
  (expand-file-name "assets/pokedex-type-xy.json")
  "Path to data file of pokedex types since Gen 6"
  :type 'string)

(defun pokemon-type-rby-update ()
  (pokemon-load-data-from-json pokemon-type-rby-dat))

(defun pokemon-type-gsc-update ()
  (pokemon-load-data-from-json pokemon-type-gsc-dat))

(defun pokemon-type-xy-update ()
  (pokemon-load-data-from-json pokemon-type-xy-dat))

(defun pokemon-type-rby ()
  (pokemon-type-rby-update))

(defun pokemon-type-gsc ()
  (pokemon-data-update
   (pokemon-type-rby)
   (pokemon-type-gsc-update)))

(defun pokemon-type-xy ()
  (pokemon-data-update
   (pokemon-type-gsc)
   (pokemon-type-xy-update)))

(provide 'pokemon-type-dat)
