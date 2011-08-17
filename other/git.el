(add-to-list 'load-path (concat emacs-root "/libraries/magit-1.0.0"))
(autoload 'magit-status "magit" nil t)
(autoload 'svn-status "psvn" nil t)
(require 'magit)

(defun infer-git-root (dir)
  (let ((filename dir))
    (progn
      (let ((gitroot nil))
        (loop while (not (string= filename "/")) do
          (setq filename (file-name-as-directory filename))
          (let ((dotgit (concat filename ".git/")))
            (if (and (file-exists-p dotgit) (not gitroot)) (setq gitroot filename)))
          (setq filename (file-name-directory (directory-file-name filename))))
        gitroot))))

(global-set-key (kbd "C-S-g") (lambda ()
  (interactive)
  (cond
   ((eq major-mode 'dired-mode)
    (let ((git-root (infer-git-root (dired-directory))))
      (if git-root 
        (magit-status git-root)
        (message "No git repository here"))))
   ((and (boundp 'log-view-vc-fileset) log-view-vc-fileset)
    (let ((git-root (infer-git-root (car log-view-vc-fileset))))
      (if git-root 
        (magit-status git-root)
        (message "No git repository here"))))
   ((buffer-file-name)
    (let ((git-root (infer-git-root (buffer-file-name))))
      (if git-root 
        (magit-status git-root)
        (message "No git repository here"))))
   (t
    (message (concat "Buffer " (buffer-name) " is not associated with a file"))))))

(global-set-key (kbd "C-S-l") (lambda ()
  (interactive)
  (vc-print-log)))