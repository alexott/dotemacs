(global-set-key (kbd "<C-S-return>") (lambda ()
  (interactive)
  (if (fboundp 'my-run-project)
    (my-run-project (current-buffer))
    (message "my-run-project is not implemented"))))
