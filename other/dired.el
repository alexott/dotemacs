(require 'dired-x)
(load-file (concat emacs-root "/libraries/dired-single-1.7/dired-single.el"))
(require 'dired-single)

(setq dired-recursive-deletes 'top)
(setq dired-recursive-copies 'top)
(setq dired-dwim-target t)

(defun my-dired-create-directory () 
  (interactive)
  (let ((dir-name-name (read-from-minibuffer "Directory name: ")))
  (let ((dir-name (concat dired-directory dir-name-name)))
  (let ((ok (progn (if (file-exists-p dir-name) (message (concat "Directory " dir-name " already exists."))) (not (file-exists-p dir-name)))))
    (when ok
      (make-directory dir-name)
      (dired-do-redisplay))))))

(defun my-dired-create-file () 
  (interactive)
  (let ((file-name-name (read-from-minibuffer "File name: ")))
  (let ((file-name (concat dired-directory file-name-name)))
  (let ((ok (progn (if (file-exists-p file-name) (message (concat "File " file-name " already exists."))) (not (file-exists-p file-name)))))
    (when ok
      (find-file file-name)
      (set-buffer-modified-p t)
      (save-buffer))))))

(defun my-dired-open-file ()
  (interactive)
  (unless (file-directory-p (dired-get-file-for-visit))
    (find-file (dired-get-file-for-visit))))

(defun my-dired-init ()
  ;; todo. implement isearch via alt+letters
  (define-key dired-mode-map (kbd "C-r") 'dired-do-redisplay)
  (define-key dired-mode-map (kbd "<M-f5>") 'dired-do-compress)
  (define-key dired-mode-map (kbd "<M-f9>") 'dired-do-compress)
  (define-key dired-mode-map (kbd "<f2>") 'dired-do-rename)
  (define-key dired-mode-map (kbd "<S-f6>") 'dired-do-rename)
  (define-key dired-mode-map (kbd "<f5>") 'dired-do-copy)
  (define-key dired-mode-map (kbd "<f6>") (lambda ())) ; to be implemented
  (define-key dired-mode-map (kbd "<f8>") 'dired-do-delete)
  (define-key dired-mode-map (kbd "<f7>") 'my-dired-create-directory)
  (define-key dired-mode-map (kbd "<f3>") 'my-dired-open-file)
  (define-key dired-mode-map (kbd "<f4>") 'my-dired-open-file)
  (define-key dired-mode-map (kbd "<f7>") 'my-dired-create-directory)
  (define-key dired-mode-map (kbd "+") 'my-dired-create-directory)
  (define-key dired-mode-map (kbd "<S-insert>") 'my-dired-create-directory)
  (define-key dired-mode-map (kbd "<S-f4>") 'my-dired-create-file)
  (define-key dired-mode-map (kbd "=") 'my-dired-create-file)
  (define-key dired-mode-map (kbd "<insert>") 'my-dired-create-file)

  (define-key dired-mode-map (kbd "<return>") 'dired-single-buffer)
  (define-key dired-mode-map [mouse-1] 'dired-single-buffer-mouse)
  (define-key dired-mode-map (kbd "<backspace>") (function (lambda () 
    (interactive) 
    (dired-single-buffer ".."))))
  (define-key dired-mode-map (kbd "^") (function (lambda () 
    (interactive) 
    (dired-single-buffer "..")))))
(if (boundp 'dired-mode-map) (my-dired-init) (add-hook 'dired-load-hook 'my-dired-init))

(global-set-key (kbd "<delete>") 'delete-char)
(defun my-goto-directory-at-point ()
  (interactive)
  (cond
   ((and (boundp 'ecb-directories-buffer-name) (string= (buffer-name) ecb-directories-buffer-name))
    (call-interactively 'ecb-dired-directory))
   ((eq major-mode 'dired-mode)  
    ())
   (t (let ((dir (if (buffer-file-name) (file-name-directory (buffer-file-name)) default-directory)))
    (dired dir)))))

(global-set-key (kbd "C-d") 'my-goto-directory-at-point)
(global-set-key (kbd "C-S-d") 'my-goto-directory-at-point)
