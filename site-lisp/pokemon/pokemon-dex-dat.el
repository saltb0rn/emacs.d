(require 'pokemon-utils)

(defconst pokemon-dex-rby
  (pokemon-load-data-from-json (expand-file-name "assets/pokedex-rby.json")))

(defconst pokemon-dex-gsc
  (pokemon-load-data-from-json (expand-file-name "assets/pokedex-gsc.json")))

(defconst pokemon-dex-gsc
  (pokemon-load-data-from-json (expand-file-name "assets/pokedex-gsc.json")))

;; (pokemon-getattr pokemon-dex-gsc "Ampharos" "bs" "hp")

(provide 'pokemon-dex-dat)
