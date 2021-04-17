;; -*- mode: emacs-lisp; lexical-binding: t -*-
;;
;; NOTE: `init.el' is auto-generated from `emacs.org'. Save changes to `emacs.org' to edit this file.

(require 'package)

(setq package-archives '(
			 ("melpa" . "https://melpa.org/packages/")
			 ("melpa stable" . "https://stable.melpa.org/packages/")
			 ("org" . "https://orgmode.org/elpa/")
			 ("elpa" . "https://elpa.gnu.org/packages/")
			 ))

(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

(setq use-package-always-ensure t)
;; (setq use-package-verbose t)

(use-package auto-package-update
  :custom
  (auto-package-update-interval 7)
  (auto-package-update-prompt-before update t)
  (auto-package-update-hide-results t)
  :config
  (auto-package-update-maybe)
  (auto-package-update-at-time "09:00")
)

(scroll-bar-mode -1)            ; disable visible scrollbar
(tool-bar-mode -1)              ; disable the toolbar
(tooltip-mode -1)               ; disable tooltips
(set-fringe-mode 10)            ; give some breathing room
(menu-bar-mode -1)              ; disable the menu bar
(setq frame-resize-pixelwise t) ; maximize frame without gaps
(setq visible-bell t)           ; set up visible bell

(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(defvar rfh/default-font-size 140)
  (defvar rfh/default-variable-font-size 140)

  (defun rfh/set-font-faces ()
    (message "Setting faces!")
    (set-face-attribute 'default nil :font "Fira Code" :height rfh/default-font-size)

    ;; Set the fixed pitch face
    (set-face-attribute 'fixed-pitch nil :font "Fira Code" :height rfh/default-font-size)

    ;; Set the variable pitch face
    (set-face-attribute 'variable-pitch nil :font "Fira Sans" :height rfh/default-variable-font-size :weight 'light)
)

(use-package emojify
  :hook (after-init . global-emojify-mode))

;; (load-theme 'gruvbox-dark-hard t)

(use-package doom-themes
  :init (load-theme 'doom-gruvbox t))

;; (use-package 'modus-vivendi-theme
;; :init (load-theme 'modus-vivendi-theme t)
;; )

;; (use-package 'modus-operandi-theme)

(use-package rainbow-delimiters
:hook (prog-mode . rainbow-delimiters-mode))

(use-package doom-modeline
:ensure t
:init (doom-modeline-mode 1)
;; :custom ((doom-modeline-height 25))
:config
(setq doom-modeline-icon t)
)

(use-package minions
  :config (minions-mode 1))

(use-package alert
  :commands alert
  :config
  (setq alert-default-style 'notifications))

(use-package all-the-icons
  :if (display-graphic-p)
  :commands all-the-icons-install-fonts
  :init
  (unless (find-font (font-spec :name "all-the-icons"))
  (all-the-icons-install-fonts t)))

(use-package all-the-icons-dired
  :if (display-graphic-p)
  :hook (dired-mode . all-the-icons-dired-mode))

(use-package all-the-icons-ivy
  :init (add-hook 'after-init-hook 'all-the-icons-ivy-setup)
  ;; :custom
  ;; (all-the-icons-ivy-file-commands '(counsel-find-file counsel-file-jump counsel-recentf counsel-projectile-find-file counsel-projectile-find-dir))
)

(use-package paren
  :config
  (set-face-attribute 'show-paren-match-expression nil :background "#363e4a")
  (show-paren-mode 1))

(use-package which-key
:init (which-key-mode)
:diminish which-key-mode
:config
(setq which-key-idle-delay 0))

;; (use-package which-key-posframe
;;   :config
;;   (which-key-posframe-mode))

(use-package helpful
:custom
(counsel-describe-function-function #'helpful-callable)
(counsel-describe-variable-function #'helpful-variable)
:bind
([remap describe-function] . counsel-describe-function)
([remap describe-command] . helpful-command)
([remap describe-variable] . counsel-describe-variable)
([remap describe-key] . helpful-key))

(use-package hydra
  :defer 1)

;; (use-package hydra-posframe
;;   :load-path "~/.emacs.d/local/hydra-posframe.el"
;;   :hook (after-init . hydra-posframe-enable))

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
	 :map ivy-minibuffer-map
	 ("TAB" . ivy-alt-done)
	 ("C-l" . ivy-alt-done)
	 ("C-j" . ivy-next-line)
	 ("C-k" . ivy-previous-line)
	 :map ivy-switch-buffer-map
	 ("C-k" . ivy-previous-line)
	 ("C-l" . ivy-done)
	 ("C-d" . ivy-switch-buffer-kill)
	 :map ivy-reverse-i-search-map
	 ("C-k" . ivy-previous-line)
	 ("C-d" . ivy-reverse-i-search-kill)
	 )
  :init
  (ivy-mode 1)
  :config
  (setq ivy-use-virtual-buffers t)
  (setq ivy-wrap t)
  (setq ivy-count-format "(%d/%d) ")
  (setq enable-recursive-minibuffers t)

  ;; Use different regex strategies per completion command
  (push '(completion-at-point . ivy--regex-fuzzy) ivy-re-builders-alist) ;; This doesn't seem to work...
  (push '(swiper . ivy--regex-ignore-order) ivy-re-builders-alist)
  (push '(counsel-M-x . ivy--regex-ignore-order) ivy-re-builders-alist)

  ;; Set minibuffer height for different commands
  (setf (alist-get 'counsel-projectile-ag ivy-height-alist) 15)
  (setf (alist-get 'counsel-projectile-rg ivy-height-alist) 15)
  (setf (alist-get 'swiper ivy-height-alist) 15)
  (setf (alist-get 'counsel-switch-buffer ivy-height-alist) 7)
  )

(use-package ivy-hydra
  :defer t
  :after hydra)

(use-package all-the-icons-ivy-rich
  :ensure t
  :init (all-the-icons-ivy-rich-mode 1))

(use-package ivy-rich
  :init
  (ivy-rich-mode 1)
  :config
  (setq ivy-format-function #'ivy-format-function-line))

;; (use-package ivy-posframe
;; :config
;; ;; display at `ivy-posframe-style'
;; (setq ivy-posframe-display-functions-alist '((t . ivy-posframe-display)))
;; ;; (setq ivy-posframe-display-functions-alist '((t . ivy-posframe-display-at-frame-center)))
;; ;; (setq ivy-posframe-display-functions-alist '((t . ivy-posframe-display-at-window-center)))
;; ;; (setq ivy-posframe-display-functions-alist '((t . ivy-posframe-display-at-frame-bottom-left)))
;; ;; (setq ivy-posframe-display-functions-alist '((t . ivy-posframe-display-at-window-bottom-left)))
;; ;; (setq ivy-posframe-display-functions-alist '((t . ivy-posframe-display-at-frame-top-center)))
;; (ivy-posframe-mode 1))

(use-package ivy-bibtex
 :commands ivy-bibtex
 :config
 (setq bibtex-completion-bibliography '("~/Documents/Library/library.bib"))
 (setq bibtex-completion-library-path '("~/Documents/Library/"))
 ;; (setq bibtex-dialect 'biblatex)
 (setq ivy-bibtex-default-action 'ivy-bibtex-open-pdf)
 (setq bibtex-completion-pdf-field "File")
 )


;; (autoload 'ivy-bibtex "ivy-bibtex" "" t)
(require 'ivy-bibtex)

;; ivy-bibtex requires ivy's `ivy--regex-ignore-order` regex builder, which
;; ignores the order of regexp tokens when searching for matching candidates.
;; Add something like this to your init file:
(setq ivy-re-builders-alist
      '((ivy-bibtex . ivy--regex-ignore-order)
        (t . ivy--regex-plus)))

(advice-add 'bibtex-completion-candidates
             :filter-return 'reverse)

(use-package counsel
  :bind (("M-x" . counsel-M-x)
         ("C-x b" . counsel-ibuffer)
         ("C-x C-f" . counsel-find-file)
         ("C-M-l" . counsel-imenu)
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history))
  :custom
  (counsel-linux-app-format-function #'counsel-linux-app-format-function-name-only)
  :config
  (setq ivy-initial-inputs-alist nil) ;; don't start `counsel-M-x' searches with ^
  (counsel-mode 1))

(use-package flx  ;; Improves sorting for fuzzy-matched results
  :defer t
  :init
  (setq ivy-flx-limit 10000))

(use-package smex ;; Adds M-x recent command sorting for counsel-M-x
  :defer 1
  :after counsel)

(use-package wgrep)

(use-package company
  :diminish company-mode
  :bind (:map company-active-map
   ("<tab>" . company-complete-selection))
  :config
  (add-hook 'after-init-hook 'global-company-mode)
  (add-hook 'exwm-init-hook 'global-company-mode)
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(use-package company-box
  :hook (company-mode . company-box-mode))

(defun text-mode-hook-setup ()
  ;;make `company-backends` local
  (make-local-variable 'company-backends)
  ;;add `company-ispell` to `company-backends`
  (add-to-list 'company-backends 'company-ispell)
  (setq ispell-dictionary "english"))

(add-hook 'text-mode-hook 'text-mode-hook-setup)

(use-package marginalia
  :config
  (marginalia-mode))

(use-package embark
  :bind
  ("C-S-a" . embark-act))              ; pick some comfortable binding

(use-package general
  :after evil
  :config
  (general-create-definer rfh/leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC"))

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll nil)
  (setq evil-want-C-i-jump nil)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-set-initial-state 'messages-buffer-mode 'normal))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(rfh/leader-keys
  "T"  '(:ignore t :which-key "toggles")
  "Tt" '(counsel-load-theme :which-key "choose theme")
  "Tm" '(toggle-frame-maximized :which-key "toggle maximize frame"))

(defhydra hydra-text-scale (:timeout 4)
  "scale text"
  ("j" text-scale-increase "up")
  ("k" text-scale-decrease "down")
  ("f" nil "finished" :exit t))

(rfh/leader-keys
  "Ts" '(hydra-text-scale/body :which-key "scale text"))

(rfh/leader-keys
  "SPC"   '(counsel-M-x :which-key "M-x")
  "TAB"   '(evil-window-next :which-key "cycle windows")
  "f"     '(:ignore t :which-key "files")
  "ff"    '(counsel-find-file :which-key "find file")
  "fr"    '(counsel-recentf :which-key "recent files")
  "fs"    '(save-buffer :which-key "save current buffer")
  "fh"    '(counsel-org-goto :which-key "go to org heading")
  "w"     '(:ignore t :which-key "windows")
  "wq"    '(quit-window :which-key "quit window")
  "wd"    '(delete-window :which-key "delete window")
  "wD"    '(delete-other-windows :which-key "delete other windows")
  "b"     '(:ignore t :which-key "buffers")
  "bb"    '(ivy-switch-buffer :which-key "switch buffer")
  "bd"    '(kill-current-buffer :which-key "kill current buffer")
  "bD"    '(kill-buffer :which-key "kill buffer")
  "B"     '(ivy-bibtex :which-key "bibliography")
 )

(use-package avy
  :defer t
  :commands (avy-goto-char avy-goto-word-0 avy-goto-line))

(rfh/leader-keys
  "j"   '(:ignore t :which-key "jump")
  "jj"  '(avy-goto-char :which-key "jump to char")
  "jw"  '(avy-goto-word-0 :which-key "jump to word")
  "jl"  '(avy-goto-line :which-key "jump to line"))

(use-package alert
  :commands alert
  :config
  (setq alert-default-style 'notifications))

;; (server-start)

(if (daemonp)
    (add-hook 'after-make-frame-functions
              (lambda (frame)
                ;; (setq doom-modeline-icon t)
                (with-selected-frame frame
                  (rfh/set-font-faces))))
    (rfh/set-font-faces))

(setq inhibit-startup-message t)

(defun rfh/display-startup-time ()
  (message "Emacs loaded in %s with %d garbage collections."
           (format "%.2f seconds"
                   (float-time
                   (time-subtract after-init-time before-init-time)))
           gcs-done))

(add-hook 'emacs-startup-hook #'rfh/display-startup-time)

(rfh/leader-keys
  "F"  '(:ignore t :which-key "frames")
  "Fd" '(delete-frame :which-key "delete current frame")
  "FD" '(delete-other-frames :which-key "delete other frames")
)

(use-package default-text-scale
  :defer 1
  :config
  (default-text-scale-mode))

(use-package ace-window
  :bind (("M-o" . ace-window))
  :config
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)))

(use-package winum
  :defer
  :config
  (winum-mode))

(winum-set-keymap-prefix (kbd "C-w"))

(winner-mode)
(define-key evil-window-map "u" 'winner-undo)

(defhydra hydra-window ()
   "
Movement^^        ^Split^         ^Switch^		   ^Resize^
----------------------------------------------------------------
_h_ ←       	_v_ertical    	    _b_uffer		    _q_ X←
_j_ ↓        	_x_ horizontal	    _f_ind files	  _w_ X↓
_k_ ↑        	_z_ undo      	    _a_ce 1         _e_ X↑
_l_ →        	_Z_ reset      	    _s_wap          _r_ X→

_F_ollow		  _D_elete others	    _S_ave		     max_i_mize
_SPC_ cancel	_o_nly this   	    _d_elete
"
   ("h" windmove-left )
   ("j" windmove-down )
   ("k" windmove-up )
   ("l" windmove-right )
   ("q" hydra-move-splitter-left)
   ("w" hydra-move-splitter-down)
   ("e" hydra-move-splitter-up)
   ("r" hydra-move-splitter-right)
   ("b" switch-to-buffer)
   ("f" counsel-find-file)
   ("F" follow-mode)
   ("a" (lambda ()
          (interactive)
          (ace-window 1)
          (add-hook 'ace-window-end-once-hook
                    'hydra-window/body))
       )
   ("v" (lambda ()
          (interactive)
          (split-window-right)
          (windmove-right))
       )
   ("x" (lambda ()
          (interactive)
          (split-window-below)
          (windmove-down))
       )
   ("s" (lambda ()
          (interactive)
          (ace-window 4)
          (add-hook 'ace-window-end-once-hook
                    'hydra-window/body)))
   ("S" save-buffer)
   ("d" delete-window)
   ("D" (lambda ()
          (interactive)
          (ace-window 16)
          (add-hook 'ace-window-end-once-hook
                    'hydra-window/body))
       )
   ("o" delete-other-windows)
   ("i" ace-maximize-window)
   ("z" (progn
          (winner-undo)
          (setq this-command 'winner-undo))
   )
   ("Z" winner-redo)
   ("SPC" nil)
   )

(rfh/leader-keys
"w SPC" '(hydra-window/body :which-key "window manager"))

(defun rfh/org-mode-visual-fill ()
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :defer t
  :hook (org-mode . rfh/org-mode-visual-fill))

;; required dependency
      (use-package page-break-lines
        :init
        (global-page-break-lines-mode))

      (use-package dashboard
        :init
        (dashboard-setup-startup-hook)
        (dashboard-insert-startupify-lists)
        :config
        (setq dashboard-items '(
              (recents . 5)
              (projects . 5)
              ))

        (setq dashboard-set-heading-icons t)
        (setq dashboard-set-file-icons t)
        (setq dashboard-set-navigator t)
        (setq dashboard-set-init-info t)
        (setq dashboard-banner-logo-title "")
        (setq dashboard-center-content t)
        (add-to-list 'dashboard-items '(agenda) t)
        (setq dashboard-week-agenda t)
        (setq dashboard-set-footer nil)
        (setq dashboard-set-navigator nil)
       )

      (setq initial-buffer-choice (lambda () (get-buffer "*dashboard*")))

(defun rfh/switch-to-dashboard ()
   "Jump to dashboard buffer; if it doesn't exist, create one."
  (interactive)
  (switch-to-buffer dashboard-buffer-name)
  (require 'dashboard)
  (dashboard-mode)
  (dashboard-insert-startupify-lists)
  (dashboard-refresh-buffer))

(rfh/leader-keys
  "bh"    '(rfh/switch-to-dashboard :which-key "home buffer/dashboard")
  )

(setq-default tab-width 2)
(setq-default evil-shift-width tab-width)

(use-package counsel
  :bind
  (("M-y" . counsel-yank-pop)
  :map ivy-minibuffer-map
  ("M-y" . ivy-next-line)))

(rfh/leader-keys
"y" '(counsel-yank-pop :which-key "yank ring"))

(setq-default indent-tabs-mode nil)

(use-package evil-nerd-commenter
  :defer t)

(rfh/leader-keys
  ";" '(evilnc-comment-or-uncomment-lines :which-key "comment/uncomment lines"))

(use-package ws-butler
  :hook ((text-mode . ws-butler-mode)
         (prog-mode . ws-butler-mode)))

(use-package expand-region
  :bind (("M-[" . er/expand-region)
         ("C-(" . er/mark-outside-pairs)))

(use-package flycheck
  :defer t
  :hook (lsp-mode . flycheck-mode))

(use-package yasnippet
  :hook (prog-mode . yas-minor-mode)
  :config
  (yas-reload-all))

(use-package smartparens
  :hook (prog-mode . smartparens-mode))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package rainbow-mode
  :defer t
  :hook (org-mode
         emacs-lisp-mode
         web-mode
         typescript-mode
         js2-mode))

(use-package lsp-mode
  :init
  ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  ;; (setq lsp-keymap-prefix "C-c l")
  :hook (;; replace XXX-mode with concrete major-mode(e. g. python-mode)
         (js2-mode . lsp)
         ;; if you want which-key integration
         (lsp-mode . lsp-enable-which-key-integration))
  :commands lsp)

;; optionally
(use-package lsp-ui :commands lsp-ui-mode)

;; if you are ivy user
(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)
(use-package lsp-treemacs :commands lsp-treemacs-errors-list)

;; optionally if you want to use debugger
(use-package dap-mode)
;; (use-package dap-LANGUAGE) to load the dap adapter for your language

(add-hook 'dap-stopped-hook
          (lambda (arg) (call-interactively #'dap-hydra)))

(add-hook 'emacs-lisp-mode-hook #'flycheck-mode)

(rfh/leader-keys
  "e"   '(:ignore t :which-key "eval")
  "eb"  '(eval-buffer :which-key "eval buffer")
  "eI"  '((lambda () (interactive) (load-file (expand-file-name "~/dotfiles/emacs/.emacs.d/init.el"))) :which-key "eval init.el"))
(rfh/leader-keys
  :keymaps '(visual)
  "er" '(eval-region :which-key "eval region"))

(use-package js2-mode
:mode "\\.js\\'"
:config)

(use-package js2-refactor
:hook (js2-mode . js2-refactor))

(use-package xref-js2)

(use-package ac-js2
:config
(add-to-list 'company-backends 'ac-js2-company))

(use-package markdown-mode
  :mode "\\.md\\'"
  :config
  (setq markdown-command "marked")
  (defun rfh/set-markdown-header-font-sizes ()
    (dolist (face '((markdown-header-face-1 . 1.2)
                    (markdown-header-face-2 . 1.1)
                    (markdown-header-face-3 . 1.0)
                    (markdown-header-face-4 . 1.0)
                    (markdown-header-face-5 . 1.0)))
      (set-face-attribute (car face) nil :weight 'normal :height (cdr face))))

  (defun rfh/markdown-mode-hook ()
    (rfh/set-markdown-header-font-sizes))

  (add-hook 'markdown-mode-hook 'rfh/markdown-mode-hook))

(use-package web-mode
  :mode "(\\.\\(html?\\|ejs\\|tsx\\|jsx\\)\\'"
  :config
  (setq-default web-mode-code-indent-offset 2)
  (setq-default web-mode-markup-indent-offset 2)
  (setq-default web-mode-attribute-indent-offset 2))

;; 1. Start the server with `httpd-start'
;; 2. Use `impatient-mode' on any buffer
(use-package impatient-mode
  :ensure t)

(use-package skewer-mode
  :ensure t)

(use-package yaml-mode
  :mode "\\.ya?ml\\'")

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  ;; :bind-keymap
  ;; ("C-c p" . projectile-command-map)
  :init
  ;; NOTE: Set this to the folder where you keep your Git repos!
  (when (file-directory-p "~/projects")
  (setq projectile-project-search-path '("~/projects")))
  (setq projectile-switch-project-action #'projectile-dired)
  )

(rfh/leader-keys
  "p" '(projectile-command-map :which-key "projectile"))

(use-package counsel-projectile
  :config (counsel-projectile-mode))

(use-package magit
  :commands magit-status
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; (use-package evil-magit
;;   :after magit)

(rfh/leader-keys
  "g"   '(:ignore t :which-key "git")
  "gs"  'magit-status
  "gd"  'magit-diff-unstaged
  "gc"  'magit-branch-or-checkout
  "gl"   '(:ignore t :which-key "log")
  "glc" 'magit-log-current
  "glf" 'magit-log-buffer-file
  "gb"  'magit-branch
  "gP"  'magit-push-current
  "gp"  'magit-pull-branch
  "gf"  'magit-fetch
  "gF"  'magit-fetch-all
  "gr"  'magit-rebase)

(use-package term
  :config
  (setq explicit-shell-file-name "bash") ;; Change this to zsh, etc
  ;;(setq explicit-zsh-args '())         ;; Use 'explicit-<shell>-args for shell-specific args

  ;; Match the default Bash shell prompt.  Update this if you have a custom prompt
  (setq term-prompt-regexp "^[^#$%>\n]*[#$%>] *"))

 ;; better `term-mode' colors

 (use-package eterm-256color
   :hook (term-mode . eterm-256color-mode))

(rfh/leader-keys
  "s"  '(:ignore t :which-key "shells")
  "st" '(eshell :which-key "term"))

(defun rfh/configure-eshell ()
  ;; Save command history when commands are entered
  (add-hook 'eshell-pre-command-hook 'eshell-save-some-history)

  ;; Truncate buffer for performance
  (add-to-list 'eshell-output-filter-functions 'eshell-truncate-buffer)

  ;; Bind some useful keys for evil-mode
  (evil-define-key '(normal insert visual) eshell-mode-map (kbd "C-r") 'counsel-esh-history)
  (evil-define-key '(normal insert visual) eshell-mode-map (kbd "<home>") 'eshell-bol)
  (evil-normalize-keymaps)

  (setq eshell-history-size         10000
        eshell-buffer-maximum-lines 10000
        eshell-hist-ignoredups t
        eshell-scroll-to-bottom-on-input t))

(use-package eshell-git-prompt)

(use-package eshell
  :hook (eshell-first-time-mode . rfh/configure-eshell)
  :config
  (with-eval-after-load 'esh-opt
    (setq eshell-destroy-buffer-when-process-dies t)
    (setq eshell-visual-commands '("htop" "zsh" "vim")))

  (eshell-git-prompt-use-theme 'powerline))

(rfh/leader-keys
  "se" '(eshell :which-key "eshell"))

(use-package fish-completion
  :hook (eshell-mode . fish-completion-mode))

(use-package eshell-syntax-highlighting
  :after esh-mode
  :config
  (eshell-syntax-highlighting-global-mode +1))

(use-package esh-autosuggest
  :hook (eshell-mode . esh-autosuggest-mode)
  :config
  (setq esh-autosuggest-delay 0.5)
  (set-face-foreground 'company-preview-common "#4b5668")
  (set-face-background 'company-preview nil))

(use-package eshell-toggle
  :bind ("C-M-'" . eshell-toggle)
  :custom
  (eshell-toggle-size-fraction 3)
  (eshell-toggle-use-projectile-root t)
  (eshell-toggle-run-command nil))

(defun rfh/org-file-jump-to-heading (org-file heading-title)
  (interactive)
  (find-file (expand-file-name org-file))
  (goto-char (point-min))
  (search-forward (concat "* " heading-title))
  (org-overview)
  (org-reveal)
  (org-show-subtree)
  (forward-line))

(defun rfh/org-file-show-headings (org-file)
  (interactive)
  (find-file (expand-file-name org-file))
  (counsel-org-goto)
  (org-overview)
  (org-reveal)
  (org-show-subtree)
  (forward-line))

(rfh/leader-keys
    "fd"  '(:ignore t :which-key "edit dotfiles")
    "fdd" '((lambda () (interactive) (find-file (expand-file-name "~/dotfiles/emacs/.emacs.d/desktop.org"))) :which-key "desktop")
    "fde" '((lambda () (interactive) (find-file (expand-file-name "~/dotfiles/emacs/.emacs.d/emacs.org"))) :which-key "emacs")
    "fdE" '((lambda () (interactive) (rfh/org-file-show-headings "~/dotfiles/emacs/.emacs.d/emacs.org")) :which-key "emacs (at heading)")
    "fdi" '((lambda () (interactive) (find-file (expand-file-name "~/dotfiles/wm/.i3/config"))) :which-key "i3")
    ;; "fdp" '((lambda () (interactive) (find-file (expand-file-name "~/dotfiles/wm/.config/polybar/config"))) :which-key "polybar")
)

(use-package super-save
  :defer 1
  :diminish super-save-mode
  :config
  (super-save-mode +1)
  (setq super-save-auto-save-when-idle t))

(global-auto-revert-mode 1)

(run-at-time (current-time) 300 'recentf-save-list)
(setq recentf-max-saved-items 50)
(setq recentf-max-menu-items 50)

(setq delete-by-moving-to-trash t)

(use-package no-littering)

(setq auto-save-file-name-transforms
      `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))

;; ;; Keep transient cruft out of ~/.emacs.d/
;; (setq user-emacs-directory "~/.cache/emacs/"
;;       backup-directory-alist `(("." . ,(expand-file-name "backups" user-emacs-directory)))
;;       url-history-file (expand-file-name "url/history" user-emacs-directory)
;;       auto-save-list-file-prefix (expand-file-name "auto-save-list/.saves-" user-emacs-directory)
;;       projectile-known-projects-file (expand-file-name "projectile-bookmarks.eld" user-emacs-directory))

;; ;; Keep customization settings in a temporary file (thanks Ambrevar!)
;; (setq custom-file
;;       (if (boundp 'server-socket-dir)
;;           (expand-file-name "custom.el" server-socket-dir)
;;         (expand-file-name (format "emacs-custom-%s.el" (user-uid)) temporary-file-directory)))
;; (load custom-file t)

(use-package dired
  :ensure nil
  :commands (dired dired-jump)
  :bind (("C-x C-j" . dired-jump))
  :custom ((dired-listing-switches "-agho --group-directories-first"))
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "h" 'dired-single-up-directory
    "l" 'dired-single-buffer))

(use-package dired-single
  :after dired)

(use-package diredfl
  :after dired
  :config
  (add-hook 'dired-mode-hook 'diredfl-global-mode))

(use-package dired-open
  :after dired
  :config
  ;; Doesn't work as expected!
  ;; (add-to-list 'dired-open-functions #'dired-open-xdg t)
  (setq dired-open-extensions '(
                                ;; ("png" . "feh")
                                ("mkv" . "vlc")))
  )

(use-package dired-hide-dotfiles
  ;; :hook (dired-mode . dired-hide-dotfiles-mode)
  :after dired
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "H" 'dired-hide-dotfiles-mode))

(rfh/leader-keys
"d" '(dired :which-key "dired"))

(defhydra hydra-dired (:hint nil :color pink)
  "
_+_ mkdir          _v_iew           _m_ark             _(_ details        _i_nsert-subdir    wdired
_C_opy             _O_ view other   _U_nmark all       _)_ omit-mode      _$_ hide-subdir    C-x C-q : edit
_D_elete           _o_pen other     _u_nmark           _l_ redisplay      _w_ kill-subdir    C-c C-c : commit
_R_ename           _M_ chmod        _t_oggle           _g_ revert buf     _e_ ediff          C-c ESC : abort
_Y_ rel symlink    _G_ chgrp        _E_xtension mark   _s_ort             _=_ pdiff
_S_ymlink          ^ ^              _F_ind marked      _TAB_ toggle hydra   \\ flyspell
_r_sync            ^ ^              ^ ^                ^ ^                _?_ summary
_z_ compress-file  _A_ find regexp
_Z_ compress       _Q_ repl regexp

T - tag prefix
"
  ("\\" dired-do-ispell)
  ("(" dired-hide-details-mode)
  (")" dired-omit-mode)
  ("+" dired-create-directory)
  ("=" diredp-ediff)         ;; smart diff
  ("?" dired-summary)
  ("$" diredp-hide-subdir-nomove)
  ("A" dired-do-find-regexp)
  ("C" dired-do-copy)        ;; Copy all marked files
  ("D" dired-do-delete)
  ("E" dired-mark-extension)
  ("e" dired-ediff-files)
  ("F" dired-do-find-marked-files)
  ("G" dired-do-chgrp)
  ("g" revert-buffer)        ;; read all directories again (refresh)
  ("i" dired-maybe-insert-subdir)
  ("l" dired-do-redisplay)   ;; relist the marked or singel directory
  ("M" dired-do-chmod)
  ("m" dired-mark)
  ("O" dired-display-file)
  ("o" dired-find-file-other-window)
  ("Q" dired-do-find-regexp-and-replace)
  ("R" dired-do-rename)
  ("r" dired-do-rsynch)
  ("S" dired-do-symlink)
  ("s" dired-sort-toggle-or-edit)
  ("t" dired-toggle-marks)
  ("U" dired-unmark-all-marks)
  ("u" dired-unmark)
  ("v" dired-view-file)      ;; q to exit, s to search, = gets line #
  ("w" dired-kill-subdir)
  ("Y" dired-do-relsymlink)
  ("z" diredp-compress-this-file)
  ("Z" dired-do-compress)
  ("q" nil)
  ("TAB" nil :color blue))

(define-key dired-mode-map (kbd "<tab>") 'hydra-dired/body)

;; (use-package openwith
;;   :config
;;   (setq openwith-associations
;;     (list
;;       (list (openwith-make-extension-regexp
;;              '("mpg" "mpeg" "mp3" "mp4"
;;                "avi" "wmv" "wav" "mov" "flv"
;;                "ogm" "ogg" "mkv"))
;;              "mpv"
;;              '(file))
;;       (list (openwith-make-extension-regexp
;;              '("xbm" "pbm" "pgm" "ppm" "pnm"
;;                "png" "gif" "bmp" "tif" "jpeg")) ;; Removed jpg because Telega was
;;                                                 ;; causing feh to be opened...
;;              "feh"
;;              '(file))
;;       (list (openwith-make-extension-regexp
;;              '("pdf"))
;;              "zathura"
;;              '(file))))
;;   (openwith-mode 1))

(defun sudo-find-file (file)
    "Opens FILE with root privileges."
    (interactive "FFind file: ")
    (set-buffer
     (find-file (concat "/sudo::" (expand-file-name file)))))

(rfh/leader-keys
"fF" '(sudo-find-file :which-key "sudo find file"))

(defun sudo-remote-find-file (file)
    "Opens repote FILE with root privileges."
    (interactive "FFind file: ")
    (setq begin (replace-regexp-in-string  "scp" "ssh" (car (split-string file ":/"))))
    (setq end (car (cdr (split-string file "@"))))
    (set-buffer
     (find-file (format "%s" (concat begin "|sudo:root@" end)))))

(use-package olivetti
  :ensure
  :defer
  :diminish
  :config
  (setq olivetti-body-width 0.8)
  (setq olivetti-minimum-body-width 72)
  (setq olivetti-recall-visual-line-mode-entry-state t))

;; (use-package emacs
;;   :config
;;   (setq-default scroll-preserve-screen-position t)
;;   (setq-default scroll-conservatively 1) ; affects `scroll-step'
;;   (setq-default scroll-margin 0)

;;   (define-minor-mode rfh/scroll-center-cursor-mode
;;     "Toggle centered cursor scrolling behavior."
;;     :init-value nil
;;     :lighter " S="
;;     :global nil
;;     (if rfh/scroll-center-cursor-mode
;;         (setq-local scroll-margin (* (frame-height) 2)
;;                     scroll-conservatively 0
;;                     maximum-scroll-margin 0.5)
;;       (dolist (local '(scroll-preserve-screen-position
;;                        scroll-conservatively
;;                        maximum-scroll-margin
;;                        scroll-margin))
;;         (kill-local-variable `,local))))

;;   :bind-keymap ("C-c r" . rfh/scroll-Center-Cursor-mode)
;;   )

;; ;; (spacemacs/set-leader-keys "or" 'rfh/scroll-center-cursor-mode)

(use-package pandoc-mode
  :defer t)

;; (use-package ox-pandoc
;;   :after org
;;   :config
;;   ;; (org-pandoc-options-for-latex-pdf '((pdf-engine . "xelatex")))
;; )

(use-package pdf-tools
  :config
  (pdf-tools-install)
  (setq-default pdf-view-display-size 'fit-width)
  (define-key pdf-view-mode-map (kbd "C-s") 'isearch-forward)
  (add-hook 'pdf-view-mode-hook (lambda () (pdf-view-midnight-minor-mode)))
  (add-hook 'pdf-view-mode-hook (lambda () (linum-mode -1)))
  (setq TeX-view-program-selection '((output-pdf "PDF Tools"))
        TeX-view-program-list '(("PDF Tools" TeX-pdf-tools-sync-view))
        TeX-source-correlate-start-server t)
  (add-hook 'TeX-after-compilation-finished-functions
            #'TeX-revert-document-buffer)
  :custom
  (pdf-annot-activate-created-annotations t "automatically annotate highlights"))

(use-package gemini-mode)

(use-package elpher)

(rfh/leader-keys
  "i"  '(:ignore t :which-key "browse internet")
  "iG" '(elpher :which-key "open elpher")
  "ig" '(elpher-go :which-key "open with gemini")
  "ie" '(eww :which-key "open with eww"))

(use-package mu4e
  :ensure nil
  :defer 20
  ;; :load-path "/home/rfh/.guix-profile/share/emacs/site-lisp/"
  :config

  ;; Refresh mail using isync every 10 minutes
  (setq mu4e-update-interval (* 10 60))
  (setq mu4e-get-mail-command "offlineimap")
  (setq mu4e-maildir "~/maildir")

  (setq mu4e-context-policy 'pick-first)
  (setq mu4e-compose-format-flowed t)
  (setq message-kill-buffer-on-exit t)

  (setq mu4e-maildir-shortcuts t
        mu4e-compose-dont-reply-to-self t
        mu4e-change-filenames-when-moving t
        mu4e-view-prefer-html t
        mu4e-show-images t
        mu4e-view-image-max-width 800
        mu4e-enable-async-operations t
        message-kill-buffer-on-exit t
        mu4e-enable-mode-line t
        mu4e-index-cleanup t
        mu4e-index-lazy-check t
        mu4e-use-fancy-chars t
        mu4e-use-maildirs-extension t
        mu4e-enable-notifications t
        mu4e-view-show-addresses t
        )

  (setq mu4e-maildir-shortcuts
      '( (:maildir "/ku/INBOX"                    :key ?i)
         (:maildir "/ku/[Gmail].Sent Mail"        :key ?s)
         (:maildir "/ku/[Gmail].Trash"            :key ?t)
         (:maildir "/ku/[Gmail].All Mail"         :key ?a)
         (:maildir "/personal/PrimaryInbox"       :key ?I)
         (:maildir "/personal/[Gmail].Sent Mail"  :key ?S)
         (:maildir "/personal/[Gmail].Trash"      :key ?T)
         ))

  (setq mu4e-contexts
    (list
      ;; personal account
      (make-mu4e-context
          :name "Personal"
          :enter-func (lambda () (mu4e-message "Switch to personal context"))
          ;; leave-func not defined
          :match-func (lambda (msg)
		      (when msg
			    (string= (mu4e-message-field msg :maildir) "/personal")))
          :vars '(  ( user-mail-address      . "robert.f.howton@gmail.com"  )
            ( user-full-name     . "Robert Howton" )
            ;; ( mu4e-compose-signature .
            ;; (concat
            ;;   "Robert Howton\n"
            ;;   "roberthowton.com\n"))
              ;; (org-msg-signature "


              ;; #+begin_signature
              ;; Robert Howton \\\\
              ;; [[roberthowton.com]]
              ;; #+end_signature")
              (mu4e-drafts-folder . "/personal/[Gmail].Drafts")
              (mu4e-sent-folder   . "/personal/[Gmail].Sent Mail")
              (mu4e-trash-folder  . "/personal/[Gmail].Trash")
              (smtpmail-starttls-credentials . '(("smtp.gmail.com" 587 nil nil)))
              (smtpmail-smtp-user . "robert.f.howton@gmail.com")
              (smtpmail-auth-credentials . '(("smtp.gmail.com" 587 "robert.f.howton@gmail.com" nil)))
              (smtpmail-default-smtp-server . "smtp.gmail.com")
              (smtpmail-smtp-server . "smtp.gmail.com")
              (smtpmail-smtp-service . 587)
              ))
       ;; work account
       (make-mu4e-context
           :name "Work"
           :enter-func (lambda () (mu4e-message "Switch to work context"))
           ;; leave-fun not defined
           :match-func (lambda (msg)
			       (when msg
			            (string= (mu4e-message-field msg :maildir) "/ku")))
           :vars '(  ( user-mail-address      . "rhowton@ku.edu.tr" )
             ( user-full-name     . "Robert Howton" )
             ;; ( mu4e-compose-signature .
             ;; (concat
             ;;   "Robert Howton\n"
             ;;   "Assistant Professor\n"
             ;;   "Department of Philosophy\n"
             ;;   "Koç University\n\n"
             ;;   "roberthowton.com"))
               (mu4e-drafts-folder . "/ku/[Gmail].Drafts")
               (mu4e-sent-folder   . "/ku/[Gmail].Sent Mail")
               (mu4e-trash-folder  . "/ku/[Gmail].Trash")
               (smtpmail-starttls-credentials . '(("smtp.gmail.com" 587 nil nil)))
               (smtpmail-smtp-user . "rhowton@ku.edu.tr")
               (smtpmail-auth-credentials . '(("smtp.gmail.com" 587 "rhowton@ku.edu.tr" nil)))
               (smtpmail-default-smtp-server . "smtp.gmail.com")
               (smtpmail-smtp-server . "smtp.gmail.com")
               (smtpmail-smtp-service . 587)
               )
               ))))

;; configure mail send function
(setq message-send-mail-function 'smtpmail-send-it)

;; use mu4e for e-mail in emacs
(setq mail-user-agent 'mu4e-user-agent)

(add-hook 'mu4e-view-mode-hook #'visual-line-mode)

(add-hook 'mu4e-compose-mode-hook 'flyspell-mode)
(add-hook 'mu4e-compose-mode-hook 'visual-line-mode)

(setq mu4e-completing-read-function 'ivy-completing-read)

;; enable org-mode links
(use-package mu4e-org
  :after (org mu4e)
  :ensure nil
  :config
  (setq mu4e-org-link-query-in-headers-mode nil))

(rfh/leader-keys
  "M"     '(mu4e :which-key "mail dashboard")
  "m"     '(:ignore t :which-key "mail commands")
  "mc"    '(mu4e-compose-new :which-key "compose new message")
)

(use-package org-msg
  :config
  (setq org-msg-options "html-postamble:nil H:5 num:nil ^:{} toc:nil author:nil email:nil \\n:t"
        org-msg-startup "hidestars indent inlineimages"
        org-msg-greeting-fmt "\nHi %s,\n\n"
        org-msg-recipient-names '(("robert.f.howton@gmail.com" . "Robbie") ("rhowton@ku.edu.tr" . "Robert"))
        org-msg-greeting-name-limit 3
        org-msg-default-alternatives '(text html)
        org-msg-convert-citation t
        org-msg-signature "

#+begin_signature
Robert Howton
Assistant Professor
Department of Philosophy
Koç University

roberthowton.com
#+end_signature")
(org-msg-mode)
  )

(use-package deft
 :commands deft
 :config
 (setq deft-file-limit 30)
 (setq deft-recursive t)
 (setq deft-extensions '("txt" "tex" "org" "md"))
 (setq deft-directory "~/projects/org"))

(rfh/leader-keys
 "D" '(deft :which-key "deft"))

(use-package guix
  :defer t
  :config
  (setq guix-package-list-type 'package))

(rfh/leader-keys
  "G"  '(:ignore t :which-key "Guix")
  "GG" '(guix :which-key "Guix interface")
  "Gi" '(guix-installed-user-packages :which-key "user packages")
  "GI" '(guix-installed-system-packages :which-key "system packages")
  "Gs" '(guix-packages-by-name :which-key "search packages")
  "GP" '(guix-pull :which-key "pull"))

(setq epa-pinentry-mode 'loopback)

(defun rfh/org-font-setup ()
  ;; Replace list hyphen with dot
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

  ;; Set faces for heading levels
  (dolist (face '((org-level-1 . 1.4)
                  (org-level-2 . 1.3)
                  (org-level-3 . 1.2)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :font "Cantarell" :weight 'regular :height (cdr face)))

  ;; Ensure that anything that should be fixed-pitch in Org files appears that way
  (set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-table nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch))

(defun rfh/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1))

(use-package org
  :hook (org-mode . rfh/org-mode-setup)
  :config
  (setq org-ellipsis " ▾"
        org-hide-emphasis-markers t
        org-src-fontify-natively t
        org-src-tab-acts-natively t
        org-edit-src-content-indentation 2
        org-src-preserve-indentation nil
        org-startup-folded 'content
        org-cycle-separator-lines 2)
  (rfh/org-font-setup))

(with-eval-after-load 'org

  (rfh/leader-keys
    "o"  '(:ignore t :which-key "org-mode")
    "oe" '(org-export-dispatch :which-key "export")
    "c"  '(org-capture :which-key "org-capture")
    )

  (setq org-directory "~/projects/org")

  (setq org-default-notes-file (concat org-directory "/notes.org"))

  (setq org-todo-keywords
            '((sequence "TODO(t)" "WAITING(w)" "|" "DONE(D)" "CANCELLED(C)")
            (sequence "BUY(b)" "|" "BOUGHT(B)")
            (sequence "MEET(m)" "|" "MET(M)" "POSTPONED(P)"))
            )

(setq org-export-with-smart-quotes t)

(use-package ox-hugo
  :after ox)

(use-package ox-gemini
  :after ox)

(use-package ox-pandoc
  :after ox)

(defun rfh/org-beamer-publish-to-pdf (plist filename pub-dir)
  (org-beamer-publish-to-pdf plist filename (file-name-directory buffer-file-name)))


(setq org-publish-project-alist
      `(("org-lecture"
         :base-directory (file-name-directory buffer-file-name)
         :base-extension "org"
         :exclude ("content.org")
         :publishing-directory (file-name-directory buffer-file-name)
         :publishing-function rfh/org-beamer-publish-to-pdf)))

(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

(defun rfh/org-mode-visual-fill ()
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
 :hook (org-mode . rfh/org-mode-visual-fill))

(require 'org-protocol)
 (add-to-list 'org-modules 'org-protocol)
 (setq org-protocol-default-template-key "p")

(setq org-capture-templates
        '(("n" "Capture note")
          ("ns" "Capture simple note" entry
           (file+headline "notes.org" "Needs Review")
           "* %? %^G\n :PROPERTIES:\n :CAPTURED: %U\n :END:\n\n")
          ("nc" "Capture note with clipboard" entry
           (file+headline "notes.org" "Needs Review")
           "* %? %^G\n :PROPERTIES:\n :CAPTURED: %U\n :END:\n\n %x")
          ("t" "Capture task")
          ("ts" "Capture simple task" entry
           (file+headline "tasks.org" "Quick Tasks")
           "* TODO %? %^G\n :PROPERTIES:\n :CAPTURED: %U\n :END:\n\n")
          ("tc" "Capture task with clipboard" entry
           (file+headline "tasks.org" "Quick Tasks")
           "* TODO %? %^G\n :PROPERTIES:\n :CAPTURED: %U\n :END:\n\n %x")
          ;; ("T" "Schedule task")
          ("tt" "Schedule task due today" entry
           (file+headline "tasks.org" "Scheduled Tasks")
           "* TODO %? %^G\n :PROPERTIES:\n :DEADLINE: %t\n :CAPTURED: %U\n :END:\n\n")
          ("tl" "Schedule task due later than today" entry
           (file+headline "tasks.org" "Scheduled Tasks")
           "* TODO %? %^G\n :PROPERTIES:\n :DEADLINE: %^T\n :CAPTURED: %U\n :END:\n\n")
          ("m" "Schedule meeting")
          ("me" "Schedule event or conference" entry
           (file+headline "meetings.org" "Events and Conferences")
           "* MEET for %^{Title of or conference} %^G\n :PROPERTIES:\n :SCHEDULED: %^t\n :CAPTURED: %U\n :END:\n\n %?")
          ("mm" "Schedule meeting" entry
           (file+headline "meetings.org" "Meetings")
           "* MEET on %^{Topic of meeting?} %^G\n :PROPERTIES:\n :SCHEDULED: %^T\n :CAPTURED: %U\n :END:\n\n %?")
          ("mw" "Schedule work appointment" entry
           (file+headline "meetings.org" "Work Appointments")
           "* MEET with %^{Meeting with whom?} %^G\n :PROPERTIES:\n :SCHEDULED: %^T\n :CAPTURED: %U\n :END:\n\n %?")
          ("mp" "Schedule personal appointment" entry
           (file+headline "meetings.org" "Personal Appointments")
           "* MEET with %^{Meeting with whom?} %^G\n :PROPERTIES:\n :SCHEDULED: %^T\n :CAPTURED: %U\n :END:\n\n %?")
          ("s" "Add to shopping list")
          ("sn" "Need to buy")
          ("sng" "Groceries" entry
           (file+headline "shopping.org" "Groceries, Etc.")
           "* BUY %^{What do you need?} %^G\n :PROPERTIES:\n :CAPTURED: %U\n :END:\n\n %?")
          ("sno" "Other necessary items" entry
           (file+headline "shopping.org" "Other Needs")
           "* BUY %^{What do you need?} %^G\n :PROPERTIES:\n :CAPTURED: %U\n :END:\n\n %?")
          ("sw" "Want to buy"
            (file+headline "shopping.org" "Wants")
            "* BUY %^{What do you want?} %^G\n :PROPERTIES:\n :CAPTURED: %U\n :END:\n\n %?")
          ("sg" "Gift"
           (file+headline "shopping.org" "Gifts")
           "* BUY %^{What do you want to give?} for %^{For whom?} %^G\n :PROPERTIES:\n :CAPTURED: %U\n :END:\n\n %?")
          ("e" "Email capture")
          ("et" "Capture mail task" entry
           (file+headline "tasks.org" "Mail-Oriented Tasks")
           "* TODO %:subject %^G:mail:\n SCHEDULED: %t\n :PROPERTIES:\n :CONTEXT: %a\n :END:\n\n %i %?")
          ("en" "Capture mail note" entry
           (file+headline "notes.org" "Needs Review")
           "* %:subject %^G:mail:\n :PROPERTIES:\n :CONTEXT: %a\n :END:\n\n %i %?")
          ("em" "Capture mail meeting" entry
           (file+headline "meetings.org" "Refile")
           "* MEET with %^{Meeting with whom?} on %^{Topic of meeting?} %:subject %^G:mail:\n SCHEDULED: %t\n :PROPERTIES:\n :CONTEXT: %a\n :END:\n\n %i %?")
          ("a" "Create Anki flashcard")
          ("ar" "Create Basic (and reversed card) flashcard" entry
           (file+headline "anki.org" "Turkish")
           "*** Item %^g\n :PROPERTIES:\n :ANKI_NOTE_TYPE: Basic (and reversed card)\n :END:\n\n **** Front\n\n %^{What is the expression?}\n\n **** Back\n\n %^{What does it mean?}\n\n"
           )
          ("p" "Protocol" entry
           (file+headline "notes.org" "Needs Review")
           "* %^{Title}\nSource: %u, %c\n #+BEGIN_QUOTE\n%i\n#+END_QUOTE\n\n\n%?")
          ("L" "Protocol Link" entry
           (file+headline "notes.org" "Needs Review")
           "* %? [[%:link][%:description]] \nCaptured On: %U")
         )
        )
  (setq org-capture-templates-contexts
        '(("e" ((in-mode . "mu4e-headers-mode")
                (in-mode . "mu4e-view-mode")))))

(setq org-refile-targets '(("anki.org" :maxlevel . 2)
                          ("meetings.org" :maxlevel . 1)
                          ("notes.org" :maxlevel . 2)
                          ("tasks.org" :maxlevel . 2)
                          ("schedule.org" :maxlevel . 2)
                          ("shopping.org" :maxlevel . 2)
                          ;; (nil :maxlevel . 9)
                          ;; (org-agenda-files :maxlevel . 9)
                          ))
(setq org-outline-path-complete-in-steps nil)         ; Refile in a single go
(setq org-refile-use-outline-path t)                  ; Show full paths for refiling

(setq org-agenda-start-with-log-mode t)
(setq org-log-done 'time)
(setq org-log-into-drawer t)
(setq org-agenda-include-all-todo t)
(setq org-agenda-files '("~/projects/org/notes.org"
                         "~/projects/org/tasks.org"
                         "~/projects/org/meetings.org"
                         "~/projects/org/shopping.org"))

(use-package org-rich-yank)

(use-package org-roam
     :hook
     (after-init . org-roam-mode)
     :custom
     (org-roam-directory "~/projects/org/"))

(rfh/leader-keys
  "r"  '(:ignore t :which-key "org-roam")
  "ri" '(org-roam-insert-immediate :which-key "insert immediate link")
  "rI" '(org-roam-insert :which-key "insert link")
  "rf" '(org-roam-find-file :which-key "find/create file")
  "rr" '(org-roam-buffer-toggle-display :which-key "toggle org-roam buffer")
  "r+" '(org-roam-tag-add :which-key "add org-roam tag")
  "r-" '(org-roam-tag-delete :which-key "remove org-roam tag")
  )

(use-package org-noter
    :after (:any org pdf-view)
    :config
    (setq
     ;; The WM can handle splits
     ;; org-noter-notes-window-location 'other-frame
     ;; Please stop opening frames
     org-noter-always-create-frame nil
     ;; I want to see the whole file
     org-noter-hide-other nil
     ;; Everything is relative to the main notes file
     ;; org-noter-notes-search-path (list org_notes)
     org-noter-notes-search-path '("~/projects/org/annotations/")
     org-noter-auto-save-last-location t
     org-noter-separate-notes-from-heading t)
    )

(use-package org-re-reveal)

(use-package hide-mode-line)

(defun rfh/presentation-setup ()
  ;; Hide the mode line
  (hide-mode-line-mode 1)

  ;; Display images inline
  (org-display-inline-images) ;; Can also use org-startup-with-inline-images

  ;; Scale the text.  The next line is for basic scaling:
  (setq text-scale-mode-amount 3)
  (text-scale-mode 1))

  ;; This option is more advanced, allows you to scale other faces too
  ;; (setq-local face-remapping-alist '((default (:height 2.0) variable-pitch)
  ;;                                    (org-verbatim (:height 1.75) org-verbatim)
  ;;                                    (org-block (:height 1.25) org-block))))

(defun rfh/presentation-end ()
  ;; Show the mode line again
  (hide-mode-line-mode 0)

  ;; Turn off text scale mode (or use the next line if you didn't use text-scale-mode)
  (text-scale-mode 0))

(use-package org-tree-slide
  :hook ((org-tree-slide-play . rfh/presentation-setup)
         (org-tree-slide-stop . rfh/presentation-end))
  :custom
  (org-tree-slide-slide-in-effect t)
  (org-tree-slide-activate-message "Presentation started!")
  (org-tree-slide-deactivate-message "Presentation finished!")
  (org-tree-slide-header t)
  (org-tree-slide-breadcrumbs " > ")
  (org-image-actual-width nil))

(setq org-confirm-babel-evaluate nil)

(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (python . t)
   (mermaid . t)))

(push '("conf-unix" . conf-unix) org-src-lang-modes)

(use-package ob-mermaid
  :after org
  :config
  (setq ob-mermaid-cli-path "/usr/bin/mmdc"))

(defun rfh/org-babel-tangle-config ()
  (when (string-equal (file-name-directory (buffer-file-name))
                      (expand-file-name "~/dotfiles/emacs/.emacs.d/"))
    ;; Dynamic scoping to the rescue
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle))))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'rfh/org-babel-tangle-config)))

(require 'org-tempo)

(add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))

)

;; (load-file "~/.emacs.d/desktop.el")
