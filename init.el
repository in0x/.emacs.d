;; Visual tweaks
(setq inhibit-startup-message t)

(scroll-bar-mode -1)
(tool-bar-mode -1)
(set-fringe-mode 10) ; width of bars on the left and right
(menu-bar-mode -1)
(set-face-attribute 'default nil :height 130) ; font size
(global-display-line-numbers-mode) ; Turn on line number bar
(setq-default show-trailing-whitespace t); highlight trailing whitespace https://stackoverflow.com/questions/34531831/highlighting-trailing-whitespace-in-emacs-without-changing-character
(dolist (hook '(special-mode-hook ; but not in these modes.
                     term-mode-hook
                     comint-mode-hook
                     compilation-mode-hook
                     minibuffer-setup-hook))
       (add-hook hook
                 (lambda () (setq show-trailing-whitespace nil))))

; Maximize on launch
(defun maximize-frame ()
  "Maximizes the active frame in Windows"
  (interactive)
  ;; Send a `WM_SYSCOMMAND' message to the active frame with the
  ;; `SC_MAXIMIZE' parameter.
  (when (eq system-type 'windows-nt)
    (w32-send-sys-command 61488)))
(add-hook 'window-setup-hook 'maximize-frame t)

(setq backup-inhibited t) ; disable backup
(setq auto-save-default nil) ; disable auto save
(setq create-lockfiles nil) ; disable lock file
(setq ring-bell-function 'ignore) ; disable bell sound

;; open multiple files as a horizontal split by default
(setq split-width-threshold 1)

;; cx-p: copy path to shortcut method, useful when I have something open in emacs but want to open it in another program
(defun to-clipboard (x)
    "Copy the given argument to the clipboard"
    (when x
        (with-temp-buffer
            (insert x)
            (clipboard-kill-region (point-min) (point-max)))
         (message x)))

(defun show-file-path ()
  "Show the full file path in the minibuffer."
  (interactive)
  (message (buffer-file-name)))

(defun full-path-to-clipboard ()
    "Copy the absolute path of the currently open file to the clipboard."
    (interactive)
    (to-clipboard (buffer-file-name)))

(global-set-key "\C-xp" 'full-path-to-clipboard)

;; unbind right option on mac so we can use it to modify character
(when (eq system-type 'darwin)
  (setq mac-right-option-modifier 'none))

;; Set up some reasonable file extension to mode mappings
(setq auto-mode-alist
      (append
       '(("\\.cpp$"  . c++-mode)
         ("\\.mm"    . objc-mode)
         ("\\.inl$"  . c++-mode)
         ("\\.h$"    . c++-mode)
         ("\\.c$"    . c++-mode)
         ("\\.cc$"   . c++-mode)
         ("\\.txt$" . indented-text-mode)
         ("\\.emacs$" . emacs-lisp-mode)
         ("\\.rs$" . rust-mode)
         ) auto-mode-alist))

;; Use 4 spaces for indentation
(setq-default indent-tabs-mode nil)
(setq c-basic-offset 4)
(setq-default tab-width 4)

;; Disable inserting a newline EOF, otherwise pollutes all files opened in emacs for the first time.
;; https://www.reddit.com/r/emacs/comments/ap78wi/remove_newline_at_end_of_file_in_specific/
;; TODO: learn how to apply this to all our auto modes
(add-hook 'c++-mode-hook 'cpp-nl-hook)
(defun cpp-nl-hook ()
  "explenation."
  (setq-local require-final-newline nil))

;; Fix default indentation of curly braces in c++ mode
;; https://stackoverflow.com/questions/663588/emacs-c-mode-incorrect-indentation
(defun my-c++-mode-hook ()
  (setq c-basic-offset 4)
  (c-set-offset 'substatement-open 0))
(add-hook 'c++-mode-hook 'my-c++-mode-hook)

;; Delete words without using kill-ring, to preserve my sanity when ctrl-deleting to yank over
;; http://ergoemacs.org/emacs/emacs_kill-ring.html
(defun my-delete-word (arg)
  "Delete characters forward until encountering the end of a word.
With argument, do this that many times.
This command does not push text to `kill-ring'."
  (interactive "p")
  (delete-region
   (point)
   (progn
     (forward-word arg)
     (point))))

(defun my-backward-delete-word (arg)
  "Delete characters backward until encountering the beginning of a word.
With argument, do this that many times.
This command does not push text to `kill-ring'."
  (interactive "p")
  (my-delete-word (- arg)))

(defun my-delete-line ()
  "Delete text from current position to end of line char.
This command does not push text to `kill-ring'."
  (interactive)
  (delete-region
   (point)
   (progn (end-of-line 1) (point)))
  (delete-char 1))

(defun my-delete-line-backward ()
  "Delete text between the beginning of the line to the cursor position.
This command does not push text to `kill-ring'."
  (interactive)
  (let (p1 p2)
    (setq p1 (point))
    (beginning-of-line 1)
    (setq p2 (point))
    (delete-region p1 p2)))

; bind them to emacs's default shortcut keys:
(global-set-key (kbd "C-S-k") 'my-delete-line-backward) ; Ctrl+Shift+k
(global-set-key (kbd "C-k") 'my-delete-line)
(global-set-key (kbd "M-d") 'my-delete-word)
(global-set-key (kbd "<C-backspace>") 'my-backward-delete-word)

;; configure package management
(require 'package)

;; package sources
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
             ("org" . "https://orgmode.org/elpa/")
             ("elpa" . "https://elpa.gnu.org/packages/")))

;; initialize package managment and load packages sources if necessary
(package-initialize)
(unless package-archive-contents
 (package-refresh-contents))

;; install use-package if we dont have it
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t) ; make use package download packages if we dont have

(use-package ivy
  :diminish
  :bind (("C-s" . swiper))
  :config
  (ivy-mode 1))

(use-package counsel
  :custom (counsel-alias-expand t))

(setq ivy-use-virtual-buffers t) ; shows useful extra stuff in switch-buffer
(setq ivy-on-del-error-function 'ignore) ; dont fall out of completion when buffer is empty, so we dont accidentally delete stuff

;; helper to check if a font is installed so we can run all-the-fonts install only once
(defun font-installed-p (font-name)
  "Check if font with FONT-NAME is available."
  (if (find-font (font-spec :name font-name))
      t
    nil))

(use-package all-the-icons
  :config
  (when (and (not (font-installed-p "all-the-icons"))
             (window-system))
    (all-the-icons-install-fonts t)))

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 10)
           (doom-modeline-buffer-modification-icon nil)))

;; override how font height is calculated so we can make the modeline less thicc
;; https://github.com/seagle0128/doom-modeline/issues/187
(defun my-doom-modeline--font-height ()
  "Calculate the actual char height of the mode-line."
  (+ (frame-char-height) 5))
(advice-add #'doom-modeline--font-height :override #'my-doom-modeline--font-height)

(use-package doom-themes
  :ensure t
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-monokai-pro t)
  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Enable custom neotree theme (all-the-icons must be installed!)
  (doom-themes-neotree-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

;; https://fanpengkong.com/post/emacs-ccpp/emacs-ccpp/
(use-package lsp-mode
  :hook (c++-mode . lsp)
  :commands lsp)

(use-package company
  :bind ("M-/" . company-complete-common-or-cycle) ;; overwritten by flyspell
  :init (add-hook 'after-init-hook 'global-company-mode)
  :config
  (setq company-show-numbers t
        company-minimum-prefix-length 1
        company-idle-delay 0.5))

(use-package lsp-ui
  :commands (lsp-ui-mode))

(use-package lsp-ivy
  :ensure t
  :commands lsp-ivy-workspace-symbol)

;; (use-package ccls
;;  :hook ((c-mode c++-mode objc-mode cuda-mode) .
;;         (lambda () (require 'ccls) (lsp))))

(use-package lsp-treemacs
 ;; :commands lsp-treemacs-errors-list
 )

(use-package org-superstar)
(add-hook 'org-mode-hook (lambda () (org-superstar-mode 1)))

(use-package rust-mode)

(use-package magit)
