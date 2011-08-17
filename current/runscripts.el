(setq my-run-scripts-testapp (concat (file-name-directory load-file-name) "helloworld.scala"))

(defun my-run-scripts ()
  (interactive)
  (let ((home (make-temp-file "my-run-scripts.")))
  (let ((testapp (concat home "/" (file-name-nondirectory my-run-scripts-testapp))))
  (let ((command (concat "cd " home "; delitec " (file-name-nondirectory testapp) "; delite")))
    (delete-file home)
    (make-directory home)
    (copy-file my-run-scripts-testapp testapp)
    (compilation-start command nil (lambda (mode-name) "*delite*"))))))

(add-to-list 'special-display-buffer-names '("*delite*" my-display-delite))
(defun my-display-delite (target-buffer)
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
  (select-window target-window)
  target-window))

;; no need to advice kill-buffer since it calls bury-buffer internally
(defadvice bury-buffer (around auto-kill-dedicated-delite-window-on-bury activate)
  (let ((buffer-being-buried (buffer-name)))
  (let ((sole-window (sole-window)))
    (when (string= buffer-being-buried "*delite*")
      (when (not sole-window)
        (message (buffer-name (current-buffer)))
        (delete-window))
      (when sole-window 
        ad-do-it))
    (when (not (string= buffer-being-buried "*delite*"))
      ad-do-it))))

;; this is an extra case, since "q" is bound directly to kill-window
;; and that cannot be handled by advicing bury-buffer
(defadvice quit-window (around auto-kill-dedicated-delite-window-on-quit activate)
  (let ((buffer-being-buried (buffer-name)))
    (when (string= buffer-being-buried "*delite*")
      (when (not (sole-window)) 
        (delete-window)))
      (when (not (string= buffer-being-buried "*delite*"))
        ad-do-it)))