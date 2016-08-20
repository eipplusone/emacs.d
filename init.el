(require 'package)

;; Always load newest byte code
(setq load-prefer-newer t)

;; reduce the frequency of garbage collection by making it happen on
;; each 50MB of allocated data (the default is on every 0.76MB)
(setq gc-cons-threshold 50000000)

;; warn when opening files bigger than 100MB
(setq large-file-warning-threshold 100000000)

(defconst russ-savefile-dir (expand-file-name "savefile" user-emacs-directory))

;; create the savefile dir if it doesn't exist
(unless (file-exists-p russ-savefile-dir)
  (make-directory russ-savefile-dir))

(when (>= emacs-major-version 24)
  (require 'package)
  (add-to-list
   'package-archives
   '("melpa" . "http://melpa.org/packages/")
   t)
  (package-initialize))

(use-package helm
  :ensure t)

(use-package google-this
  :ensure t
  :bind (("s-g" . google-this)))

(defun ash-term-hooks ()
  (define-key term-raw-map (kbd "M-:") 'eval-expression)
  (define-key term-raw-map (kbd "M-x") 'helm-M-x)
  ;; dabbrev-expand in term
  (define-key term-raw-map (kbd "M-/")
    (lambda ()
      (interactive)
      (let ((beg (point)))
	(dabbrev-expand nil)
	(kill-region beg (point)))
      (term-send-raw-string (substring-no-properties (current-kill 0)))))
  ;; yank in term (bound to C-c C-y)
  (define-key term-raw-map "\C-y"
    (lambda ()
      (interactive)
      (term-send-raw-string (current-kill 0)))))

(add-hook 'term-mode-hook 'ash-term-hooks)

(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))

(blink-cursor-mode -1)

(setq ring-bell-function 'ignore)

(setq inhibit-startup-screen t)

(setq scroll-margin 0
      scroll-conservatively 100000
      scroll-preserve-screen-position 1)

(line-number-mode t)
(column-number-mode t)
(size-indication-mode t)

(fset 'yes-or-no-p 'y-or-n-p)

(keyboard-translate ?\C-t ?\C-x)
(keyboard-translate ?\C-x ?\C-t)

(define-key key-translation-map [?\M-x] [?\M-t])
(define-key key-translation-map [?\M-t] [?\M-x])

(defun my-keys-have-priority (_file)
    "Try to ensure that my keybindings retain priority over other minor modes.
Called via the `after-load-functions' special hook."
    (unless (eq (caar minor-mode-map-alist) 'my-keys-minor-mode)
      (let ((mykeys (assq 'my-keys-minor-mode minor-mode-map-alist)))
        (assq-delete-all 'my-keys-minor-mode minor-mode-map-alist)
        (add-to-list 'minor-mode-map-alist mykeys))))

(use-package magit
  :ensure t
  :bind (("C-x g" . magit-status)))

(use-package ido
  :ensure t
  :config
  (setq ido-enable-prefix nil
	ido-enable-flex-matching t
	ido-create-new-buffer 'always
	ido-use-filename-at-point 'guess
	ido-max-prospects 10
	ido-default-file-method 'selected-window
	ido-auto-merge-work-directories-length -1)
  (ido-mode +1))

(use-package super-save
  :ensure t
  :config
  (super-save-mode +1))

;; hippie expand is dabbrev expand on steroids
(setq hippie-expand-try-functions-list '(try-expand-dabbrev
					 try-expand-dabbrev-all-buffers
					 try-expand-dabbrev-from-kill
					 try-complete-file-name-partially
					 try-complete-file-name
					 try-expand-all-abbrevs
					 try-expand-list
					 try-expand-line
					 try-complete-lisp-symbol-partially
					 try-complete-lisp-symbol))

;; use hippie-expand instead of dabbrev
(global-set-key (kbd "M-/") #'hippie-expand)
(global-set-key (kbd "s-/") #'hippie-expand)

(use-package smex
  :ensure t
  :bind ("M-x" . smex))

;; saveplace remembers your location in a file when saving files
(require 'saveplace)
(use-package saveplace
  :config
  (setq save-place-file (expand-file-name "saveplace" russ-savefile-dir))
  ;; activate it for all buffers
  (setq-default save-place t))

(use-package aggressive-indent
  :ensure t
  :config
  (global-aggressive-indent-mode +1))

(use-package company
  :ensure t
  :config
  (global-company-mode))

(use-package recentf
  :ensure t
  :config
  (setq recentf-max-saved-items 500
	recentf-max-menu-items 15
	;; disable recentf-cleanup on Emacs start, because it can cause
	;; problems with remote files
	recentf-auto-cleanup 'never)
  (recentf-mode +1))

(defvar my-keys-minor-mode-map
  (let ((map (make-sparse-keymap)))
    
    map)
  "my-keys-minor-mode keymap. ")

(use-package crux
  :ensure t
  :bind (("C-c o" . crux-open-with)
	 ("M-o" . crux-smart-open-line)
	 ("C-c n" . crux-cleanup-buffer-or-region)
	 ("C-c f" . crux-recentf-ido-find-file)
	 ("C-M-z" . crux-indent-defun)
	 ("C-c u" . crux-view-url)
	 ("C-c e" . crux-eval-and-replace)
	 ("C-c w" . crux-swap-windows)
	 ("C-c D" . crux-delete-file-and-buffer)
	 ("C-c r" . crux-rename-buffer-and-file)
	 ("C-c t" . crux-visit-term-buffer)
	 ("C-c k" . crux-kill-other-buffers)
	 ("C-c TAB" . crux-indent-rigidly-and-copy-to-clipboard)
	 ("C-c I" . crux-find-user-init-file)
	 ("C-c S" . crux-find-shell-init-file)
	 ("s-r" . crux-recentf-ido-find-file)
	 ("s-j" . crux-top-join-line)
	 ("C-^" . crux-top-join-line)
	 ("s-k" . crux-kill-whole-line)
	 ("C-<backspace>" . crux-kill-line-backwards)
	 ("s-o" . crux-smart-open-line-above)
	 ([remap move-beginning-of-line] . crux-move-beginning-of-line)
	 ([(shift return)] . crux-smart-open-line)
	 ([(control shift return)] . crux-smart-open-line-above)
	 ([remap kill-whole-line] . crux-kill-whole-line)
	 ("C-c s" . crux-ispell-word-then-abbrev)))

(define-minor-mode my-keys-minor-mode
  "A minor mode so that my key settings override annoying minor modes"
  :init-value t
  :lighter "my-keys ")

(add-hook 'after-load-functions 'my-keys-have-priority)

(use-package which-key
  :ensure t
  :config
  (which-key-mode +1))

(use-package undo-tree
  :ensure t
  :config
  ;; autosave the undo-tree history
  (setq undo-tree-history-directory-alist
	`((".*" . ,temporary-file-directory)))
  (setq undo-tree-auto-save-history t))

(use-package exec-path-from-shell
  :ensure t
  :config
  (when (memq window-system '(mac ns))
    (exec-path-from-shell-initialize)))

(use-package helm-swoop
  :ensure t
  :bind (("M-s" . helm-swoop)))

(use-package easy-kill
  :ensure t
  :config
  (global-set-key [remap kill-ring-save] 'easy-kill))

(use-package anzu
  :ensure t
  :bind (("M-r" . anzu-query-replace)
	 ("C-M-r" . anzu-query-replace-regexp))
  :config
  (global-anzu-mode))

(use-package windmove
  :config
  ;; use shift + arrow keys to switch between visible buffers
  (define-key my-keys-minor-mode-map (kbd "M-h") 'windmove-left)
  (define-key my-keys-minor-mode-map (kbd "M-n") 'windmove-right)
  (define-key my-keys-minor-mode-map (kbd "M-c") 'windmove-up)
  (define-key my-keys-minor-mode-map (kbd "M-t") 'windmove-down))
