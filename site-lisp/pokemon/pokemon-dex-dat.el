(require 'pokemon-utils)

(defun pokemon--get-library-path ()
  (file-name-directory (locate-library "pokemon")))

(defcustom pokemon-pokedex-rby-dat
  (concat (pokemon--get-library-path) "assets/pokedex-rby.json")
  "Path to pokedex data file of Pokemon Red, Blue & Yellow (Gen 1)"
  :type 'string)

(defcustom pokemon-pokedex-gsc-dat
  (concat (pokemon--get-library-path) "assets/pokedex-gsc.json")
  "Path to pokedex data file of Pokemon Gold, Silver & Crystal (Gen 2)"
  :type 'string)

(defcustom pokemon-pokedex-rse-dat
  (concat (pokemon--get-library-path) "assets/pokedex-rse.json")
  "Path to pokedex data file of Pokemon Ruby, Sapphire & Emerald (Gen 3)"
  :type 'string)

(defcustom pokemon-pokedex-dpp-dat
  (concat (pokemon--get-library-path) "assets/pokedex-dpp.json")
  "Path to pokedex data file of Pokemon Diamond, Pearl & Platinum (Gen 4)"
  :type 'string)

(defcustom pokemon-pokedex-bw-dat
  (concat (pokemon--get-library-path) "assets/pokedex-bw.json")
  "Path to pokedex data file of Pokemon Black & White (Gen 5)"
  :type 'string)

(defcustom pokemon-pokedex-xy-dat
  (concat (pokemon--get-library-path) "assets/pokedex-xy.json")
  "Path to pokedex data file of Pokemon X & Y (Gen 6)"
  :type 'string)

(defcustom pokemon-pokedex-sm-dat
  (concat (pokemon--get-library-path) "assets/pokedex-sm.json")
  "Path to pokedex data file of Pokemon Sun & Month (Gen 7)"
  :type 'string)

(defcustom pokemon-pokedex-ss-dat
  (concat (pokemon--get-library-path) "assets/pokedex-ss.json")
  "Path to pokedex data file of Pokemon Sword & Shield (Gen 8)"
  :type 'string)

(defmacro pokemon-dex-gen-update (gen)
  `(pokemon-load-data-from-json
    (symbol-value (intern (format "pokemon-pokedex-%s-dat" (symbol-name (quote ,gen)))))))

(defun pokemon-dex-rby ()
  (pokemon-dex-gen-update rby))

(defun pokemon-dex-gsc ()
  (pokemon-data-update
   (pokemon-dex-rby)
   (pokemon-dex-gen-update gsc)))

(defun pokemon-dex-rse ()
  (pokemon-data-update
   (pokemon-dex-gsc)
   (pokemon-dex-gen-update rse)))

(defun pokemon-dex-dpp ()
  (let ((dex (pokemon-data-update
              (pokemon-dex-rse)
              (pokemon-dex-gen-update dpp)))
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
   (pokemon-dex-gen-update bw)))

(defun pokemon-dex-xy ()
  (let ((dex
         (pokemon-data-update
          (pokemon-dex-bw)
          (pokemon-dex-gen-update xy)))
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
   (pokemon-dex-gen-update sm)))

(defun pokemon-dex-ss ()
  (let ((dex (pokemon-data-update
              (pokemon-dex-sm)
              (pokemon-dex-gen-update ss)))
        (pokemons-to-delete-abs (list "Gengar" "Raikou" "Entei" "Suicune")))
    (dolist (pokemon pokemons-to-delete-abs)
      (pokemon-data-rem "ab" (pokemon-data-get dex pokemon)))
    dex))

(provide 'pokemon-dex-dat)
