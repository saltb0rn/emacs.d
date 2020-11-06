(require 'pokemon-utils)

(defcustom pokemon-pokedex-rby-dat
  (expand-file-name "assets/pokedex-rby.json")
  "Path to pokedex data file of Pokemon Red, Blue & Yellow (Gen 1)"
  :type 'string)

(defcustom pokemon-pokedex-gsc-dat
  (expand-file-name "assets/pokedex-gsc.json")
  "Path to pokedex data file of Pokemon Gold, Silver & Crystal (Gen 2)"
  :type 'string)

(defcustom pokemon-pokedex-rse-dat
  (expand-file-name "assets/pokedex-rse.json")
  "Path to pokedex data file of Pokemon Ruby, Sapphire & Emerald (Gen 3)"
  :type 'string)

(defcustom pokemon-pokedex-dpp-dat
  (expand-file-name "assets/pokedex-dpp.json")
  "Path to pokedex data file of Pokemon Diamond, Pearl & Platinum (Gen 4)"
  :type 'string)

(defcustom pokemon-pokedex-bw-dat
  (expand-file-name "assets/pokedex-bw.json")
  "Path to pokedex data file of Pokemon Black & White (Gen 5)"
  :type 'string)

(defcustom pokemon-pokedex-xy-dat
  (expand-file-name "assets/pokedex-xy.json")
  "Path to pokedex data file of Pokemon X & Y (Gen 6)"
  :type 'string)

(defcustom pokemon-pokedex-sm-dat
  (expand-file-name "assets/pokedex-sm.json")
  "Path to pokedex data file of Pokemon Sun & Month (Gen 7)"
  :type 'string)

(defcustom pokemon-pokedex-ss-dat
  (expand-file-name "assets/pokedex-ss.json")
  "Path to pokedex data file of Pokemon Sword & Shield (Gen 8)"
  :type 'string)

;; Pokemon Ruby
(defun pokemon-dex-rby-update ()
  (pokemon-load-data-from-json pokemon-pokedex-rby-dat))

(defun pokemon-dex-gsc-update ()
  (pokemon-load-data-from-json pokemon-pokedex-gsc-dat))

(defun pokemon-dex-rse-update ()
  (pokemon-load-data-from-json pokemon-pokedex-rse-dat))

(defun pokemon-dex-dpp-update ()
  (pokemon-load-data-from-json pokemon-pokedex-dpp-dat))

(defun pokemon-dex-bw-update ()
  (pokemon-load-data-from-json pokemon-pokedex-bw-dat))

(defun pokemon-dex-xy-update ()
  (pokemon-load-data-from-json pokemon-pokedex-xy-dat))

(defun pokemon-dex-sm-update ()
  (pokemon-load-data-from-json pokemon-pokedex-sm-dat))

(defun pokemon-dex-ss-update ()
  (pokemon-load-data-from-json pokemon-pokedex-ss-dat))

(defun pokemon-dex-rby ()
  (pokemon-dex-rby-update))

(defun pokemon-dex-gsc ()
  (pokemon-data-update
   (pokemon-dex-rby-update)
   (pokemon-dex-gsc-update)))

(defun pokemon-dex-rse ()
  (pokemon-data-update
   (pokemon-dex-gsc)
   (pokemon-dex-rse-update)))

(defun pokemon-dex-dpp ()
  (let ((dex (pokemon-data-update
              (pokemon-dex-rse)
              (pokemon-dex-dpp-update)))
        (pokemons-to-delete-abs
         (list
          "Machop"
          "Machoke"
          "Machamp"
          "Seel"
          "Dewgong"
          "Shellder"
          "Cloyster"
          "Tangela"
          "Horsea"
          "Mr. Mime"
          "Scyther"
          "Pinsir"
          "Tauros"
          "Hoppip"
          "Skiploom"
          "Jumpluff"
          "Sunkern"
          "Sunflora"
          "Granbull"
          "Scizor"
          "Ursaring"
          "Kingdra"
          "Stantler"
          "Tyrogue"
          "Hitmontop"
          "Miltank"
          "Mightyena"
          "Tropius"
          "Spheal"
          "Sealeo"
          "Walrein"
          )))
    (dolist (pokemon pokemons-to-delete-abs)
      (pokemon-data-rem "ab" (pokemon-data-get dex pokemon)))
    dex))

(defun pokemon-dex-bw ()
  (pokemon-data-update
   (pokemon-dex-dpp)
   (pokemon-dex-bw-update)))

(defun pokemon-dex-xy ()
  (let ((dex
         (pokemon-data-update
          (pokemon-dex-bw)
          (pokemon-dex-xy-update)))
        (pokemons-to-delete-abs
         (list
          "Duskull"
          "Snivy"
          "Servine"
          "Serperior"
          "Tepig"
          "Pignite"
          "Emboar"
          "Oshawott"
          "Dewott"
          "Samurott")))
    (dolist (pokemon pokemons-to-delete-abs)
      (pokemon-data-rem "ab" (pokemon-data-get dex pokemon)))
    dex))

(defun pokemon-dex-sm ()
  (pokemon-data-update
   (pokemon-dex-xy)
   (pokemon-dex-sm-update)))

(defun pokemon-dex-ss ()
  (let ((dex (pokemon-data-update
              (pokemon-dex-sm)
              (pokemon-dex-ss-update)))
        (pokemons-to-delete-abs (list "Gengar" "Raikou" "Entei" "Suicune")))
    (dolist (pokemon pokemons-to-delete-abs)
      (pokemon-data-rem "ab" (pokemon-data-get dex pokemon)))
    dex))

(provide 'pokemon-dex-dat)
