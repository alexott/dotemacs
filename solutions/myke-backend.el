;; todo. this does not work. why?!
;;(set (make-local-variable 'sbt-invoke-XXX) YYY)
(if (not (boundp 'myke-command)) (setq myke-command (make-hash-table)))
(defun myke-command () (gethash (buffer-name) myke-command))
(defun set-myke-command (value) (puthash (buffer-name) value myke-command))
(if (not (boundp 'myke-buffer)) (setq myke-buffer (make-hash-table)))
(defun myke-buffer () (gethash (buffer-name) myke-buffer))
(defun set-myke-buffer (value) (puthash (buffer-name) value myke-buffer))

(defun myke-invoke (command buffer)
  (let ((buffer (if (myke-buffer) (myke-buffer) buffer)))
  (if (buffer-file-name buffer) (with-current-buffer buffer (save-buffer)))
  (let ((target (if (buffer-file-name buffer) (buffer-file-name buffer) nil)))

  (when target
    (let ((target-buffer (get-buffer (concat "*" command "*"))))
    (if target-buffer (kill-buffer target-buffer))
    (setq target-buffer (get-buffer-create (concat "*" command "*")))
    (set-buffer target-buffer)

    ;; todo. this does not work. why?!
    ;;(set (make-local-variable 'myke-command) command)
    ;;(set (make-local-variable 'myke-buffer) buffer)
    (set-myke-command command)
    (set-myke-buffer buffer)

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
         '(("^\\[error\\] \\([_.a-zA-Z0-9 :\\\\/-]+[.]scala\\):\\([0-9]+\\):"
            1 2 nil 2 nil)))
    (set (make-local-variable 'compilation-mode-font-lock-keywords)
         '(("^\\[error\\] Error running compile:"
            (0 compilation-error-face))
           ("^.*\\*\\*\\* FAILED \\*\\*\\*"
            (0 compilation-error-face))
           ("^\\[warn\\][^\n]*"
            (0 compilation-warning-face))
           ("^\\(\\[info\\]\\)\\([^\n]*\\)"
            (0 compilation-info-face)
            (1 compilation-line-face))
           ("^\\[success\\][^\n]*"
            (0 compilation-info-face))))
    (compilation-shell-minor-mode t)

    (defvar myke-minor-mode-map (make-keymap) "myke-minor-mode keymap.")
    (define-key myke-minor-mode-map (kbd "<tab>") 'compilation-next-error)
    (define-key myke-minor-mode-map (kbd "<backtab>") 'compilation-previous-error)
    (define-key myke-minor-mode-map (kbd "<return>") (lambda ()
      (interactive)
      (if (and (get-buffer-process (current-buffer)) (eq (point) (point-max)))
        (comint-send-input)
        (compile-goto-error))))
    (define-key myke-minor-mode-map (kbd "C-S-b") (lambda () (interactive) (my-compile-project (current-buffer))))
    (define-prefix-command 'myke-minor-mode-compile-map)
    (define-key myke-minor-mode-map (kbd "M-b") 'myke-minor-mode-compile-map)
    (define-key myke-minor-mode-compile-map (kbd "r") (lambda () (interactive) (my-rebuild-project (current-buffer))))
    (define-key myke-minor-mode-compile-map (kbd "M-r") (lambda () (interactive) (my-rebuild-project (current-buffer))))
    (define-key myke-minor-mode-map (kbd "<C-S-return>") (lambda () (interactive) (my-run-project (current-buffer))))
    (define-key myke-minor-mode-map (kbd "C-S-r") (lambda () (interactive) (my-repl-project (current-buffer))))
    (define-key myke-minor-mode-map (kbd "<s-S-return>") (lambda () (interactive) (my-test-project (current-buffer))))
    (define-key myke-minor-mode-map (kbd "q") (lambda ()
      (interactive)
      (if (and (get-buffer-process (current-buffer)) (eq (point) (point-max)))
        (insert "q")
        (bury-buffer))))
    (define-key myke-minor-mode-map (kbd "g") (lambda ()
      (interactive)
      (if (and (get-buffer-process (current-buffer)) (eq (point) (point-max)))
        (insert "g")
        (myke-invoke (myke-command) (myke-buffer)))))
    (define-minor-mode myke-minor-mode "Hosts keybindings for myke interactions" nil " sbt" 'myke-minor-mode-map :global nil)
    (myke-minor-mode 1)
    (defun my-minibuffer-setup-hook () (myke-minor-mode 0))
    (add-hook 'minibuffer-setup-hook 'my-minibuffer-setup-hook)

    (set (make-local-variable 'after-change-functions) '((lambda (start stop prev-length)
      (let ((content (buffer-substring-no-properties (point-min) (point-max))))
      (when (and (string-match "Process myke finished" content)
                 (not (string-match "\\[error\\]" content)))
        (cond
          ((string= (myke-command) "compile") (bury-buffer))
          ((string= (myke-command) "rebuild") (bury-buffer))
          ((string= (myke-command) "run") ())
          ((string= (myke-command) "repl") (bury-buffer))
          ((string= (myke-command) "test") (bury-buffer))
          ((string= (myke-command) "commit") (bury-buffer))
          ((string= (myke-command) "logall") (bury-buffer))
          ((string= (myke-command) "logthis") (bury-buffer))
          ((string= (myke-command) "pull") ())
          ((string= (myke-command) "push") ())
          (t (error (concat "unsupported command " (myke-command))))))))))

    (comint-exec (current-buffer) (myke-command) "myke" nil (list "/v" (myke-command) target))))))

(defadvice recompile (around override-recompile-for-sbt activate)
  (if (myke-command)
    (myke-invoke (myke-command) (myke-buffer))
    ad-do-it))

(defadvice revert-buffer (around override-revert-for-sbt activate)
  (if (myke-command)
    (myke-invoke (myke-command) (myke-buffer))
    ad-do-it))

;; no need to advice kill-buffer since it calls bury-buffer internally
(defadvice bury-buffer (around auto-kill-dedicated-sbt-window-on-bury activate)
  (let ((myke-command (myke-command)))
  (let ((sole-window (sole-window)))
    (when myke-command
      (when (not sole-window)
        (delete-window))
      (when sole-window
        ad-do-it))
    (when (not myke-command)
      ad-do-it))))
