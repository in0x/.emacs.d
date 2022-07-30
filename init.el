(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(##)))
 
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

; Make themes path available for loading
(add-to-list 'load-path "~/.emacs.d/pconfig")
(add-to-list 'custom-theme-load-path "~/.emacs.d/pconfig")

; Load up machine local settings
(load-file "~/.emacs.d/pconfig/machine-local.el")
 
 ; Turn tool and scroll bar
(menu-bar-mode -1)
(tool-bar-mode -1)
(toggle-scroll-bar 0)

; Maximize on launch
(defun maximize-frame ()
  "Maximizes the active frame in Windows"
  (interactive)
  ;; Send a `WM_SYSCOMMAND' message to the active frame with the
  ;; `SC_MAXIMIZE' parameter.
  (when (eq system-type 'windows-nt)
    (w32-send-sys-command 61488)))
(add-hook 'window-setup-hook 'maximize-frame t)

; Everything integration for windows cause we got crappy commandline tools
(require 'everything)

; Turn on line number bar
(global-display-line-numbers-mode)

; set up rainbow parens and highlighting matching parens
(load "rainbow-delimiters")
(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)
(show-paren-mode 1)

; yeet away the startup message so default-directory setting can work
(setq inhibit-startup-message t)

; open multiple files as a horizontal split by default
(setq split-width-threshold 1)

(autoload 'rust-mode "rust-mode" nil t)

;; store all backup and autosave files in a single dir so we dont polute our workspaces
; (setq backup-directory-alist `((".*" . ,"~/emacs_saves/")))
      
;disable backup
(setq backup-inhibited t)
;disable auto save
(setq auto-save-default nil)
;disable lock file
(setq create-lockfiles nil)

;;(setq auto-save-file-name-transforms
;;  `((".*" "~/emacs_saves/" t)))

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
    
; load our themes
; (load-theme 'naysayer t)
(load-theme 'solarized-selenized-dark t)

; set the global default font
(if (not (equal system-type 'darwin))
    set-face-attribute 'default nil :font "Consolas" )

; Set font-lock-defaults for text-mode, otherwise fixme-mode doesnt correctly apply to text-mode
; https://emacs.stackexchange.com/questions/66220/why-does-font-lock-mode-work-with-various-programming-languages-but-it-does-not
(add-hook 'text-mode-hook (lambda () (setq font-lock-defaults '(nil))))

; map dynamic abbrev to C-tab
(global-set-key (kbd "C-<tab>") 'dabbrev-expand)
(define-key minibuffer-local-map (kbd "C-<tab>") 'dabbrev-expand)

; Color todos in red so they stand out
(setq fixme-modes '(c++-mode c-mode emacs-lisp-mode text-mode indented-text-mode))
(make-face 'font-lock-fixme-face)
(make-face 'font-lock-note-face)
(make-face 'font-lock-date-face)
(make-face 'font-lock-done-face)
(mapc (lambda (mode)
   (font-lock-add-keywords
    mode
    '(("\\<\\(TODO\\|todo\\|ToDo\\||to-do\\|To-Do\\)" 1 'font-lock-fixme-face t)
      ("\\<\\(NOTE\\|Note\\|note\\)" 1 'font-lock-note-face t)
      ("\\<\\(DATE\\)" 1 'font-lock-date-face t)
      ("\\<\\(DONE\\)" 1 'font-lock-done-face t)
      )))
    fixme-modes)
(modify-face 'font-lock-fixme-face "red" nil nil t nil t nil nil)
(modify-face 'font-lock-note-face "yellow" nil nil t nil t nil nil)
(modify-face 'font-lock-done-face "light green" nil nil t nil t nil nil)
(modify-face 'font-lock-date-face "pink" nil nil t nil t nil nil)
 
; Set up some reasonable file extension to mode mappings
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
         
; Use 4 spaces for indentation
(setq-default indent-tabs-mode nil)
(setq c-basic-offset 4)
(setq-default tab-width 4)

; Disable inserting a newline EOF, otherwise pollutes all files opened in emacs for the first time.
; https://www.reddit.com/r/emacs/comments/ap78wi/remove_newline_at_end_of_file_in_specific/
; TODO: learn how to apply this to all our auto modes
(add-hook 'c++-mode-hook 'cpp-nl-hook)
(defun cpp-nl-hook ()
  "explenation."
  (setq-local require-final-newline nil))  

; Fix default indentation of curly braces in c++ mode
; https://stackoverflow.com/questions/663588/emacs-c-mode-incorrect-indentation
(defun my-c++-mode-hook ()
  (setq c-basic-offset 4)
  (c-set-offset 'substatement-open 0))
(add-hook 'c++-mode-hook 'my-c++-mode-hook)
  
; Delete words without using kill-ring, to preserve my sanity when ctrl-deleting to yank over
; http://ergoemacs.org/emacs/emacs_kill-ring.html
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
