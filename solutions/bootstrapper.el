(load-all-files-from-dir (file-name-directory load-file-name) :exclude '("bootstrapper.el"))

(when (file-exists-p (concat emacs-root "/" "desktops" "/" "current.el"))
    (load-file (concat emacs-root "/" "desktops" "/" "current.el")))
(unless (boundp 'my-current-desktop)
  (setq my-current-desktop nil))
(setq desktop-root (concat emacs-root "/" "desktops" "/"
			   (or (getenv "EMACS_DESKTOP") my-current-desktop)))
(load-all-files-from-dir desktop-root)
(load-file (concat emacs-root "/" "desktops" "/" "desktop.el"))
(load-file (concat emacs-root "/" "desktops" "/" "bookmarks.el"))


