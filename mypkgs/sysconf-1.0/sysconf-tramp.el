(require 'tramp)

(tramp-set-completion-function
 "ssh"
 `((tramp-parse-sconfig
    ,(join-path
      (file-name-directory load-file-name)
      "dotfiles"
      "ssh"
      "config"))
   (tramp-parse-sconfg "/etc/ssh_config")
   (tramp-parse-sconfig "~/.ssh/config")))

;;; These functions does not work for me.

(provide 'sysconf-tramp)
