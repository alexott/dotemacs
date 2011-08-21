(setq inhibit-startup-screen t)
(setq initial-scratch-message nil)

(menu-bar-mode -1)
(tool-bar-mode -1)
(global-set-key (kbd "<f10>") (lambda ()
  (interactive)
  (if (window-system)
    (menu-bar-mode (if menu-bar-mode -1 1))
    (menu-bar-open))))
(set-scroll-bar-mode 'right)
;;(scroll-bar-mode -1)

(if (not (fboundp 'maximize-frame)) (error "unsupported operating system"))
(maximize-frame)

(defun chomp (str)
  (let ((s (if (symbolp str) (symbol-name str) str)))
    (if (string-match "[ \t\r\n\v\f]+$" s) (replace-match "" nil t s) s)))

(defun slurp (file)
   (let ((lines ()))
   (when (file-readable-p file)
     (with-temp-buffer
       (insert-file-contents file)
       (goto-char (point-min))
       (while (not (eobp))
         (setq lines (append lines (list (chomp (thing-at-point 'line)))))
         (forward-line))))
   lines))

(add-to-list 'load-path (concat emacs-root "/libraries/framemove-0.9"))
(require 'framemove)
(framemove-default-keybindings 'super)
(global-set-key (kbd "<s-tab>") 'other-frame)
(global-set-key (kbd "s-`") 'move-buffer-to-other-frame)
(defun move-buffer-to-other-frame ()
  (interactive) 
  (if (<= (length (frame-list)) 2)
    (let ((current-frame (window-configuration-frame (current-window-configuration))))
    (let ((current-frame-index (position current-frame (frame-list))))
    (let ((current-window (frame-selected-window current-frame)))
    (let ((current-buffer (window-buffer current-window)))
    (let ((other-frame-existed (= (length (frame-list)) 2)))
    (let ((other-frame-index (- 1 current-frame-index)))
    (let ((other-frame (if (= (length (frame-list)) 1)
      (progn
        (let ((fresh-frame (make-frame)))
          (bury-buffer) ;; arguable decision, though, possibly useful
          (other-frame 1)
          (maximize-frame)
          (if (not (fboundp 'swap-monitor)) (error "unsupported operating system"))
          (swap-monitor)
          fresh-frame))
        (nth other-frame-index (frame-list)))))
      (let ((other-window (frame-selected-window other-frame)))
        (set-window-buffer other-window current-buffer)
        (when other-frame-existed 
          (bury-buffer)
          (other-frame 1))))))))))))

(defun my-on-delete-frame (current-frame)
  (interactive)
  (let ((current-frame-index (position current-frame (frame-list))))
    (when (and (= current-frame-index 1) ;; 1 is the index of main frame
               (= (length (frame-list)) 2))
;;      (delete-frame (nth 0 (frame-list)))))) ;; 0 is the index of auxiliary frame
      (save-buffers-kill-emacs))))
(add-hook 'delete-frame-functions 'my-on-delete-frame)
