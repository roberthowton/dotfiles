;; Prevent frame resize during init (smoother startup).
(setq frame-inhibit-implied-resize t)

;; Avoid GC slowdowns with many fonts.
(setq inhibit-compacting-font-caches t)

;; Reduce idle redisplay overhead.
(setq idle-update-delay 1.0)

;; No modeline flash before config loads.
(setq-default mode-line-format nil)

;; Suppress startup echo message (unless daemon).
(unless (daemonp)
  (advice-add #'display-startup-echo-area-message :override #'ignore))

(setq inhibit-startup-screen t)
(setq initial-scratch-message nil)

;; No alarms.
(setq ring-bell-function 'ignore)

;; Suppress UI elements before first frame is drawn (avoids flash).
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(when (fboundp 'menu-bar-mode)   (menu-bar-mode -1))
(when (fboundp 'tool-bar-mode)   (tool-bar-mode -1))
(when (fboundp 'tooltip-mode)    (tooltip-mode -1))

;; Suppress toolbar on macOS NS frames via frame defaults.
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars . nil) default-frame-alist)

(setq package-enable-at-startup nil)
