(require 'pokemon-utils)

(defconst pokemon-natures
  (pokemon-load-data-from-json (expand-file-name "assets/nature-data.json")))

(provide 'pokemon-nature-dat)
