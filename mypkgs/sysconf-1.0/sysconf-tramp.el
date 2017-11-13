(require 'tramp)

(defgroup sysconf-tramp nil
  "Configurations that are not provided for tramp-mode"
  :prefix "sysconf-tramp-"
  :group 'sysconf)

(defcustom sysconf-tramp-additional-ssh-login-args
  '(())
  "Add additional args you want for ssh command.
The value should be an alist which stands for the option list
"
  :safe 'consp
  :group 'sysconf-tramp)

(setf (cadr (assoc 'tramp-login-args (assoc "ssh" tramp-methods)))
      (append
       sysconf-tramp-additional-ssh-login-args
       (cadr (assoc 'tramp-login-args (assoc "ssh" tramp-methods)))))

;;; These functions does not work for me.

(provide 'sysconf-tramp)
