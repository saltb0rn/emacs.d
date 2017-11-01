(require-install 'org-plus-contrib)

;;; Options
(setq

 org-export-with-sub-superscripts nil	; Toggle Tex-like syntax for sub- and superscripts. If you write "^:{}", 'a_{b}' will be interpreted, but simple 'a_b' will be left as it is
 org-export-with-author nil
 org-export-with-broken-links 'mark	; Toggle if Org should continue exporting upon finding a broken internal link. When set to mark, Org clearly marks the problem link in the output
 )


(provide 'init-org)
