;;; Emacs4CL 0.3.0 <https://github.com/susam/emacs4cl>

;; Customize user interface.
;; (menu-bar-mode 0)
(when (display-graphic-p)
  (tool-bar-mode 0)
  (scroll-bar-mode 0))

(setq inhibit-startup-screen t)
(load-theme 'wombat)

;; Use spaces, not tabs, for indentation.
(setq-default indent-tabs-mode nil)

;; Highlight matching pairs of parentheses.
(setq show-paren-delay 0)
(show-paren-mode)

;; Workaround for https://debbugs.gnu.org/34341 in GNU Emacs <= 26.3.
(when (and (version< emacs-version "26.3")
           (>= libgnutls-version 30603))
  (setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3"))

;; Enable installation of packages from MELPA.
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Write customizations to ~/.emacs.d/custom.el instead of this file.
(setq custom-file (concat user-emacs-directory "custom.el"))
(load custom-file)

;; Install packages.
(dolist (package '(slime paredit rainbow-delimiters company slime-company slime-repl-ansi-color))
  (unless (package-installed-p package)
    (package-install package)))

;; Configure SBCL as the Lisp program for SLIME.
;; (add-to-list 'exec-path "/usr/local/bin")
(setq inferior-lisp-program "wx86cl64")
(slime-setup '(slime-fancy slime-company slime-repl-ansi-color))
(global-set-key "\C-cs" 'slime-selector)
(add-hook 'slime-repl-mode-hook 'slime-repl-ansi-color-mode)
(global-set-key [f8] 'neotree-toggle)

;; Enable Paredit.
(add-hook 'emacs-lisp-mode-hook 'enable-paredit-mode)
(add-hook 'eval-expression-minibuffer-setup-hook 'enable-paredit-mode)
(add-hook 'ielm-mode-hook 'enable-paredit-mode)
(add-hook 'lisp-mode-hook 'enable-paredit-mode)
(add-hook 'lisp-interaction-mode-hook 'enable-paredit-mode)
(add-hook 'slime-repl-mode-hook 'enable-paredit-mode)
(defun override-slime-del-key ()
  (define-key slime-repl-mode-map
    (read-kbd-macro paredit-backward-delete-key) nil))
(add-hook 'slime-repl-mode-hook 'override-slime-del-key)

;; Enable Rainbow Delimiters.
(add-hook 'emacs-lisp-mode-hook 'rainbow-delimiters-mode)
(add-hook 'ielm-mode-hook 'rainbow-delimiters-mode)
(add-hook 'lisp-mode-hook 'rainbow-delimiters-mode)
(add-hook 'lisp-interaction-mode-hook 'rainbow-delimiters-mode)
(add-hook 'slime-repl-mode-hook 'rainbow-delimiters-mode)

;; Customize colors for Rainbow Delimiters.
(require 'rainbow-delimiters)
(set-face-foreground 'rainbow-delimiters-depth-1-face "#f99")  ; red
(set-face-foreground 'rainbow-delimiters-depth-2-face "#9f9")  ; green
(set-face-foreground 'rainbow-delimiters-depth-3-face "#9cf")  ; blue
(set-face-foreground 'rainbow-delimiters-depth-4-face "#ff9")  ; yellow
(set-face-foreground 'rainbow-delimiters-depth-5-face "#9ff")  ; cyan
(set-face-foreground 'rainbow-delimiters-depth-6-face "#f9f")  ; magenta
(set-face-foreground 'rainbow-delimiters-depth-7-face "#fff")  ; white
(set-face-foreground 'rainbow-delimiters-depth-8-face "#ccc")  ; light gray
(set-face-foreground 'rainbow-delimiters-depth-9-face "#999")  ; dark gray