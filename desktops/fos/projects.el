;; -*- mode: emacs-lisp; coding: emacs-mule; -*-

(add-project "scratchpad" "/media/XENO/Dropbox/Projects/Foundations of Software/Scratchpad/src" "scratchpad" "scratchpad")
(add-project "nb" "/media/XENO/Dropbox/Projects/Foundations of Software/P1 - Numbers and Booleans/src" "nb" "nb")
(add-project "desktop" "/media/XENO/Dropbox/Software/Emacs/desktops/fos" nil)
(add-project ".emacs" "/media/XENO/Dropbox/Software/Emacs" nil)

(setq tool-buffers-autofollow nil)
(setq tool-buffers-display-in-bottom-window t)
(setq tool-buffers-display-in-right-window nil)
                                                                                        
(defun my-repl-project (name-or-path)
  (if (eq major-mode 'scala-mode)
    (let ((sbt-name (car (project-metadata name-or-path))))
    (let ((sbt-path (sbt-project-root (project-path name-or-path))))
      (save-buffer)
      ;; todo. find out why this hangs emacs
      ;; the trouble is definitely inside comint, since:
      ;; 1) turning off callbacks does not work
      ;; 2) calling "console" only does not work
      ;; 3) invoking "sbt console" instead of "sbt" and echo console also does not work
      ;;(sbt-invoke sbt-name sbt-path "compile" "console")))))
      (sbt-invoke-repl sbt-name sbt-path)))))

(defun my-compile-project (name-or-path)
  (if (eq major-mode 'scala-mode)
    (let ((sbt-name (car (project-metadata name-or-path))))
    (let ((sbt-path (sbt-project-root (project-path name-or-path))))
      (save-buffer)
      (sbt-invoke sbt-name sbt-path "compile")))))

(defun my-compile-master-project (name-or-path)
  (if (eq major-mode 'scala-mode)
    (let ((sbt-master-name (cadr (project-metadata name-or-path))))
    (let ((sbt-path (sbt-project-root (project-path name-or-path))))
      (save-buffer)
      (sbt-invoke sbt-master-name sbt-path "compile")))))

(defun my-run-project (name-or-path)
  (if (eq major-mode 'scala-mode)
    (let ((sbt-name (car (project-metadata name-or-path))))
    (let ((sbt-path (sbt-project-root (project-path name-or-path))))
      (save-buffer)
      (sbt-invoke sbt-name sbt-path "run")))))

(defun my-test-project (name-or-path)
  (if (eq major-mode 'scala-mode)
    (let ((sbt-name (car (project-metadata name-or-path))))
    (let ((sbt-path (sbt-project-root (project-path name-or-path))))
      (save-buffer)
      (sbt-invoke sbt-name sbt-path "test")))))
