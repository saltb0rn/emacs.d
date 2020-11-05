(require 'pokemon-utils)

(defcustom pokemon-nature-dat-file
  (expand-file-name "assets/nature-data.json" (file-name-directory load-file-name))
  "Path to nature data file"
  :type 'string)

(defun pokemon-natures ()
  (pokemon-load-data-from-json pokemon-nature-dat-file))

(provide 'pokemon-nature-dat)
