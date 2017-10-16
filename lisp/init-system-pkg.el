;;; 该文件是用来配置系统的软件的,也就是每当换电脑/或者系统的时候,只要运行emacs一次就会自动配置好系统的环境
(call-process "python3"
	      nil
	      t
	      nil
	      "/home/saltb0rn/Software/emacs.d/lisp/install-packages-for-elpy.py")

(shell-command (concat "echo " (shell-quote-argument (read-passwd "Password? "))
		       " | sudo -S apt-get udpate"))

(shell-command "python3 /home/saltb0rn/Software/emacs.d/lisp/install-packages-for-elpy.py")

(shell-command-to-string (concat "echo " (shell-quote-argument (read-passwd "Password? "))
				 " | sudo -S apt-get update"))
