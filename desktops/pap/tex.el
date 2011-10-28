(defun my-latex-result (filename)
  (if filename
    (let ((raw (substring filename 0 (- (length filename) (length (file-name-extension filename))))))
    (let ((pdf (concat raw "pdf")))
    (let ((pdf-modtime (if (file-exists-p pdf) (nth 5 (file-attributes pdf)) nil)))
    (let ((dvi (concat raw "dvi")))
    (let ((dvi-modtime (if (file-exists-p dvi) (nth 5 (file-attributes pdf)) nil)))
    (let ((filename (cond
      ((and pdf-modtime dvi-modtime) pdf) ;; todo. pick the newest file
      ((and pdf-modtime (not dvi-modtime)) pdf)
      ((and (not pdf-modtime) dvi-modtime) dvi)
      (t nil))))

    (when (not filename)
      (let ((master-filename nil))
        (dolist (file (directory-files (file-name-directory raw)))
           (if (or (string-match "HW\\([[:digit:]][[:digit:]]\\).*\\.tex" file)
                   (string-match "Test\\([[:digit:]][[:digit:]]\\).*\\.tex" file))
               (setq master-filename (concat (file-name-directory raw) file))))
        (when (and master-filename (not (string= filename master-filename)))
          (setq filename (my-latex-result master-filename)))))

    filename))))))
   nil))

;; todo. this does not work. why?!
;;(set (make-local-variable 'tex-compileXXX) YYY)
(if (not (boundp 'tex-compile-project)) (setq tex-compile-project (make-hash-table)))
(defun tex-compile-project () (gethash (buffer-name) tex-compile-project))
(defun set-tex-compile-project (value) (puthash (buffer-name) value tex-compile-project))
(if (not (boundp 'tex-compile-filename)) (setq tex-compile-filename (make-hash-table)))
(defun tex-compile-filename () (gethash (buffer-name) tex-compile-filename))
(defun set-tex-compile-filename (value) (puthash (buffer-name) value tex-compile-filename))

(defun my-tex-compile (project filename)
  ;; todo. this does not work. why?!
  ;;(set (make-local-variable 'tex-compile-project) project)
  ;;(set (make-local-variable 'tex-compile-filename) filename)
  (set-tex-compile-project project)
  (set-tex-compile-filename filename)

  (let ((buffer-name "*tex*"))
  (when (and buffer-name project)
    (let ((target-buffer (get-buffer buffer-name)))
    (if target-buffer (kill-buffer target-buffer))
    (setq target-buffer (get-buffer-create buffer-name))
    (set-buffer target-buffer)
    
    ;; todo. this does not work. why?!
    ;;(set (make-local-variable 'tex-compile-project) project)
    ;;(set (make-local-variable 'tex-compile-filename) filename)
    (set-tex-compile-project project)
    (set-tex-compile-filename filename)

    (let ((target-window 
      (cond 
        ((and (boundp 'tool-buffers-display-in-bottom-window) tool-buffers-display-in-bottom-window)
         (if (top-window) (active-window)
         (if (bottom-window) (bottom-window) 
         (split-window-vertically))))
        ((and (boundp 'tool-buffers-display-in-right-window) tool-buffers-display-in-right-window)
         (if (left-window) (left-window)
         (if (right-window) (right-window) 
         (split-window-horizontally))))
        (t
         (active-window)))))
    (let ((pop-up-windows t)) (set-window-buffer target-window target-buffer))
    (select-window target-window)))

    (comint-mode)
    (set (make-local-variable 'comint-process-echoes) t)
    (set (make-local-variable 'comint-scroll-to-bottom-on-output) t)
    (set (make-local-variable 'comint-prompt-read-only) t)
    (set (make-local-variable 'ansi-color-for-comint-mode) t)
    (set (make-local-variable 'comint-output-index) 0)
    (set (make-local-variable 'comint-output-history) "")

    (set (make-local-variable 'compilation-error-regexp-alist)
         '(("^\\([_.a-zA-Z0-9 :\\\\/-]+[.]n\\):\\([0-9]+\\):\\([0-9]+\\):\\([0-9]+\\):\\([0-9]+\\):"
            1 2 nil 2 nil)))
    (compilation-shell-minor-mode t)

    (defvar tex-compile-minor-mode-map (make-keymap) "tex-compile-minor-mode keymap.")
    (define-key tex-compile-minor-mode-map (kbd "<tab>") 'compilation-next-error)
    (define-key tex-compile-minor-mode-map (kbd "<backtab>") 'compilation-previous-error)
    (define-key tex-compile-minor-mode-map (kbd "<return>") (lambda ()
      (interactive)
      (if (and (get-buffer-process (current-buffer)) (eq (point) (point-max)))
        (comint-send-input)
        (compile-goto-error))))
    (define-key tex-compile-minor-mode-map (kbd "C-S-r") (lambda () (interactive) (my-repl-project (tex-compile-project) (tex-compile-filename))))
    (define-key tex-compile-minor-mode-map (kbd "C-S-b") (lambda () (interactive) (my-compile-project (tex-compile-project) (tex-compile-filename))))
    (define-prefix-command 'tex-compile-minor-mode-compile-map)
    (define-key tex-compile-minor-mode-map (kbd "M-b") 'tex-compile-minor-mode-compile-map)
    (define-key tex-compile-minor-mode-compile-map (kbd "r") (lambda () (interactive) (my-rebuild-project (tex-compile-project) (tex-compile-filename))))
    (define-key tex-compile-minor-mode-compile-map (kbd "M-r") (lambda () (interactive) (my-rebuild-project (tex-compile-project) (tex-compile-filename))))
    (define-key tex-compile-minor-mode-map (kbd "<C-S-return>") (lambda () (interactive) (my-run-project (tex-compile-project) (tex-compile-filename))))
    (define-key tex-compile-minor-mode-map (kbd "<s-S-return>") (lambda () (interactive) (my-test-project (tex-compile-project) (tex-compile-filename))))
    (define-key tex-compile-minor-mode-map (kbd "q") (lambda () 
      (interactive)
      (if (and (get-buffer-process (current-buffer)) (eq (point) (point-max)))
        (insert "q")
        (bury-buffer))))
    (define-key tex-compile-minor-mode-map (kbd "g") (lambda () 
      (interactive)
      (if (and (get-buffer-process (current-buffer)) (eq (point) (point-max)))
        (insert "g")
        (tex-compile (buffer-name) (tex-compile-project) (tex-compile-command)))))
    (define-minor-mode tex-compile-minor-mode "Hosts keybindings for tex compilation interactions" nil " tex-compile" 'tex-compile-minor-mode-map :global nil)
    (tex-compile-minor-mode 1)
    (defun my-minibuffer-setup-hook () (tex-compile-minor-mode 0))
    (add-hook 'minibuffer-setup-hook 'my-minibuffer-setup-hook)

    (set (make-local-variable 'after-change-functions) '((lambda (start stop prev-length) 
      (let ((content (buffer-substring-no-properties (point-min) (point-max))))
      (when (and (string-match "Process pdflatex\\(<[[:digit:]]+>\\)? finished" content)
                 (not (string-match "LaTeX Error" content)))
        (let ((raw (substring (tex-compile-filename) 0 (- (length (tex-compile-filename)) (length (file-name-extension (tex-compile-filename)))))))
        (let ((pdf (concat raw "pdf")))
        (let ((dvi (concat raw "dvi")))
        (dolist (buffer (buffer-list)) 
          (with-current-buffer buffer
            (if (or 
                 (equal (buffer-file-name) pdf)
                 (equal (buffer-file-name) dvi))
              (revert-buffer t t))))
        (run-at-time 0.1 nil (lambda () (bury-buffer)))))))))))

    (let ((master-file nil))
      (dolist (file (directory-files (file-name-directory (tex-compile-filename))))
         (if (or (string-match "HW\\([[:digit:]][[:digit:]]\\).*\\.tex" file)
                 (string-match "Test\\([[:digit:]][[:digit:]]\\).*\\.tex" file))
             (setq master-file file)))
      (when master-file 
        (set-tex-compile-filename (concat (file-name-directory (tex-compile-filename)) master-file))))

    (cd (project-path (tex-compile-project)))
    (comint-exec (current-buffer) "pdflatex" "pdflatex" nil (list (tex-compile-filename))))))

(defadvice recompile (around override-recompile-for-console activate)
  (if (tex-compile-project)
    (tex-compile (buffer-name) (tex-compile-project) (tex-compile-command))
    ad-do-it))

(defadvice revert-buffer (around override-revert-for-sbt activate)
  (if (tex-compile-project)
    (tex-compile (buffer-name) (tex-compile-project) (tex-compile-command))
    ad-do-it))

;; no need to advice kill-buffer since it calls bury-buffer internally
(defadvice bury-buffer (around auto-kill-dedicated-tex-compile-window-on-bury activate)
  (let ((tex-compile-project (tex-compile-project)))
  (let ((sole-window (sole-window)))
    (when tex-compile-project
      (when (not sole-window)
        (delete-window))
      (when sole-window 
        ad-do-it))
    (when (not tex-compile-project)
      ad-do-it))))