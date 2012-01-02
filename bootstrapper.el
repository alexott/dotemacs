;; todo. implement include and exclude
(defun load-all-files-from-dir (dir &optional include exclude) 
  (dolist (f (directory-files dir))
    (when (and 
      (file-directory-p (concat dir "/" f))
      (not (string= "." f))
      (not (string= ".." f)))
    (load-all-files-from-dir (concat dir "/" f)))
    (when (and 
      (not (file-directory-p (concat dir "/" f)))
      (not (string= "bootstrapper.el" f))
      (string= ".el" (substring f (- (length f) 3))))
    (load-file (concat dir "/" f)))))

;; http://stackoverflow.com/questions/1817257/how-to-determine-operating-system-in-elisp
;; it's better to store platform as symbol, not as several symbols
(setq windows nil mac nil linux nil)
(cond
 ((eq system-type 'windows-nt) (setq windows t))
 ((eq system-type 'darwin) (setq mac t))
 (t (setq linux t)))

(setq platform (cond
		((eq system-type 'windows-nt) 'windows) ;; should also handle 'cygwin?
		((eq system-type 'darwin) 'mac)
		(t 'linux)))

;; TODO: it's better to use path-manipulating routines
(load-file (concat (file-name-directory load-file-name) ;; use emacs-root here?
		   "/" "xplatform" "/" (symbol-name platform) "/" "bootstrapper.el"))

(load-all-files-from-dir (concat emacs-root "/" "utils")) ;; this is okay for performance, nothing top-level here
(load-all-files-from-dir (concat emacs-root "/" "editor")) ;; this is okay for performance, i only had to disable linum-mode
(load-all-files-from-dir (concat emacs-root "/" "other")) ;; scala-mode lags, but only once per buffer. i believe, this has to do with syntax coloring
(load-file (concat emacs-root "/" "solutions" "/" "bootstrapper.el"))

