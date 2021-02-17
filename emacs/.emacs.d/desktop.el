(defvar rfh/polybar-process nil
  "Holds the process of the running Polybar instance, if any")

(defun rfh/kill-panel ()
  (interactive)
  (when rfh/polybar-process
    (ignore-errors
      (kill-process efs/polybar-process)))
  (setq rfh/polybar-process nil))

(defun rfh/start-panel ()
  (interactive)
  (rfh/kill-panel)
  (setq rfh/polybar-process (start-process-shell-command "polybar" nil "polybar panel")))

(defun rfh/send-polybar-hook (module-name hook-index)
  (start-process-shell-command "polybar-msg" nil (format "polybar-msg hook %s %s" module-name hook-index)))

(defun rfh/send-polybar-exwm-workspace ()
  (rfh/send-polybar-hook "exwm-workspace" 1))

;; Update panel indicator when workspace changes
(add-hook 'exwm-workspace-switch-hook #'rfh/send-polybar-exwm-workspace)


(defun rfh/exwm-update-class ()
  (exwm-workspace-rename-buffer exwm-class-name))

(defun rfh/run-in-background (command)
  (let ((command-parts (split-string command "[ ]+")))
  (apply #'call-process `(,(car command-parts) nil 0 nil ,@(cdr command-parts)))))

(defun rfh/exwm-init-hook ()
  ;; Make workspace 1 be the one where we land at startup
  (exwm-workspace-switch-create 1)

  ;; Launch apps that will run in the background
  (rfh/run-in-background "nm-applet")
  (rfh/run-in-background "syncthing-gtk")

  ;; Start polybar panel
  (rfh/start-panel)
  )

(use-package exwm
  :config
  ;; Set the default number of workspaces
  (setq exwm-workspace-number 5)

  ;; Rebind CapsLock to Ctrl
  (start-process-shell-command "xmodmap" nil "xmodmap ~/dotfiles/emacs/.emacs.d/exwm/Xmodmap")

  ;; When window "class" updates, use it to set the buffer name
  (add-hook 'exwm-update-class-hook #'rfh/exwm-update-class)

  ;; Load the system tray before exwm-init
  ;; (require 'exwm-systemtray)
  ;; (exwm-systemtray-enable)

  ;; When EXWM starts up, do some extra confifuration
  (add-hook 'exwm-init-hook #'rfh/exwm-init-hook)

  ;; These keys should always pass through to Emacs
  (setq exwm-input-prefix-keys
    '(?\C-x
      ?\C-u
      ?\C-h
      ?\M-x
      ?\M-`
      ?\M-&
      ?\M-:
      ?\C-\M-j  ;; Buffer list
      ?\C-\ ))  ;; Ctrl+Space

  ;; Ctrl+Q will enable the next key to be sent directly
  (define-key exwm-mode-map [?\C-q] 'exwm-input-send-next-key)

  ;; Set up global key bindings.  These always work, no matter the input state!
  ;; Keep in mind that changing this list after EXWM initializes has no effect.
  (setq exwm-input-global-keys
        `(
          ;; Reset to line-mode (C-c C-k switches to char-mode via exwm-input-release-keyboard)
          ([?\s-r] . exwm-reset)

          ;; Move between windows
          ([s-left] . windmove-left)
          ([s-right] . windmove-right)
          ([s-up] . windmove-up)
          ([s-down] . windmove-down)

          ;; Also with vim keybindings
          ([?\s-h] . windmove-left)
          ([?\s-j] . windmove-up)
          ([?\s-k] . windmove-down)
          ([?\s-l] . windmove-right)


          ;; Launch applications via shell command
          ([?\s-&] . (lambda (command)
                       (interactive (list (read-shell-command "$ ")))
                       (start-process-shell-command command nil command)))

          ;; Switch workspace
          ([?\s-w] . exwm-workspace-switch)

          ;; Bind =s-`= to workspace 0
          ([?\s-`] . (lambda () (interactive) (exwm-workspace-switch-create 0)))

          ;; 's-N': Switch to certain workspace with Super (Win) plus a number key (0 - 9)
          ,@(mapcar (lambda (i)
                      `(,(kbd (format "s-%d" i)) .
                        (lambda ()
                          (interactive)
                          (exwm-workspace-switch-create ,i))))
                    (number-sequence 0 9))))

  ;; App Launcher Keybindings
  (exwm-input-set-key (kbd "s-SPC") 'counsel-linux-app)
  (exwm-input-set-key (kbd "s-f") 'exwm-toggle-fullscreen)

  (exwm-enable))

;; (use-package desktop-environment
;;   :after exwm
;;   :config (desktop-environment-mode)
;;   :custom
;;   (desktop-environment-brightness-small-increment "2%+")
;;   (desktop-environment-brightness-small-decrement "2%-")
;;   (desktop-environment-brightness-normal-increment "5%+")
;;   (desktop-environment-brightness-normal-decrement "5%-"))
