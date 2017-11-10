(require 'tramp)

(defgroup tramp-conf nil
  "Configurations that are not provided for tramp-mode"
  :group 'sysconf)

(defcustom
  additional-ssh-login-args
  '(())
  "Add additional args you want for ssh command.
The value should be an alist which stands for the option list
"
  :safe 'consp
  :group 'tramp-conf)

(setf (cadr (assoc 'tramp-login-args (assoc "ssh" tramp-methods)))
      (append
       additional-ssh-login-args
       (cadr (assoc 'tramp-login-args (assoc "ssh" tramp-methods)))))

;;; These functions does not work for me.

(provide 'sysconf-tramp)
