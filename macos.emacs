(require 'package)

(setq max-lisp-eval-depth 10000)

(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
(package-initialize)

;; refresh package metadata
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(setq user-full-name "kongo Tania"
      user-mail-address "kongotania@gmail.com")

;; exec-path-from-shell-initialize
(unless (package-installed-p 'exec-path-from-shell)
  (package-refresh-contents)
  (package-install 'exec-path-from-shell))

(setq default-frame-alist
      '((height . 30)
        (width . 90)
        (left . 10)
        (top . 10)))

(when (memq window-system '(mac ns x))
  (setq ns-right-alternate-modifier 'none)
  (exec-path-from-shell-initialize))

;; Always load newest byte code
(setq load-prefer-newer t)

(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))

;; the blinking cursor is nothing, but an annoyance
(blink-cursor-mode -1)

;; disable the annoying bell ring
(setq ring-bell-function 'ignore)

;; disable startup screen
(setq inhibit-startup-screen t)
(setq inhibit-splash-screen t)
(setq initial-scratch-message nil)

;; nice scrolling
(setq scroll-margin 0
      scroll-conservatively 100000
      scroll-preserve-screen-position 1)

(setq-default indent-tabs-mode nil)   ;; don't use tabs to indent
(setq-default tab-width 8)            ;; but maintain correct appearance

;; Newline at end of file
(setq require-final-newline t)

;; Wrap lines at 80 characters
(setq-default fill-column 80)

;; delete the selection with a keypress
(delete-selection-mode t)

;; store all backup and autosave files in the tmp dir
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

;; revert buffers automatically when underlying files are changed externally
(global-auto-revert-mode t)

(prefer-coding-system 'utf-8)
(set-language-environment "UTF-8")
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

(use-package company
  :diminish company-mode
  :config (add-hook 'after-init-hook #'global-company-mode))

(use-package slime
  :config
  (setq slime-lisp-implementations
        '((sbcl ("sbcl") :coding-system utf-8-unix)
          (clisp ("clisp"))))
  (setq slime-contribs '(slime-fancy
			 slime-company
			 slime-repl-ansi-color))
  (global-set-key "\C-cs" 'slime-selector)
  (add-hook 'slime-repl-mode-hook 'slime-repl-ansi-color-mode)
  (setq slime-company-completion 'fuzzy
        slime-company-after-completion 'slime-company-just-one-space
        slime-company-after-completion 'slime-company-just-one-space))

(use-package paredit
  :after (slime)
  :config
  (add-hook 'emacs-lisp-mode-hook 'enable-paredit-mode)
  (add-hook 'eval-expression-minibuffer-setup-hook 'enable-paredit-mode)
  (add-hook 'ielm-mode-hook 'enable-paredit-mode)
  (add-hook 'lisp-mode-hook 'enable-paredit-mode)
  (add-hook 'lisp-interaction-mode-hook 'enable-paredit-mode)
  (add-hook 'slime-repl-mode-hook 'enable-paredit-mode)
  (add-hook 'scheme-mode-hook 'enable-paredit-mode)
  (defun override-slime-del-key ()
    (define-key slime-repl-mode-map
                (read-kbd-macro paredit-backward-delete-key) nil))
  (add-hook 'slime-repl-mode-hook 'override-slime-del-key))

(use-package rainbow-delimiters
  :after (slime)
  :config
  (set-face-foreground 'rainbow-delimiters-depth-1-face "#c66")  ; red
  (set-face-foreground 'rainbow-delimiters-depth-2-face "#6c6")  ; green
  (set-face-foreground 'rainbow-delimiters-depth-3-face "#69f")  ; blue
  (set-face-foreground 'rainbow-delimiters-depth-4-face "#cc6")  ; yellow
  (set-face-foreground 'rainbow-delimiters-depth-5-face "#6cc")  ; cyan
  (set-face-foreground 'rainbow-delimiters-depth-6-face "#c6c")  ; magenta
  (set-face-foreground 'rainbow-delimiters-depth-7-face "#ccc")  ; light gray
  (set-face-foreground 'rainbow-delimiters-depth-8-face "#999")  ; medium gray
  (set-face-foreground 'rainbow-delimiters-depth-9-face "#666")  ; dark gray
  (add-hook 'emacs-lisp-mode-hook 'rainbow-delimiters-mode)
  (add-hook 'ielm-mode-hook 'rainbow-delimiters-mode)
  (add-hook 'lisp-mode-hook 'rainbow-delimiters-mode)
  (add-hook 'lisp-interaction-mode-hook 'rainbow-delimiters-mode)
  (add-hook 'slime-repl-mode-hook 'rainbow-delimiters-mode)
  (add-hook 'scheme-mode-hook 'rainbow-delimiters-mode))

(use-package vertico
  :ensure t
  :init
  (vertico-mode 1))

(use-package marginalia
  :ensure t
  :init
  (marginalia-mode))

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package gptel
  :ensure t
  :config
  (setq
   gptel-model "opencoder:latest"
   gptel-backend
   (gptel-make-ollama "Ollama"
     :host "localhost:11434"
     :stream t
     :models '("qwen2.5-coder:latest"
               "llama3.1:latest"
               "dolphin3:latest"
               "opencoder:latest"
               "deepseek-r1:14b"
               "phi4:latest"))))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(blink-cursor-mode nil)
 '(custom-enabled-themes '(wheatgrass))
 '(geiser-chez-binary "chez")
 '(package-selected-packages
   '(0blayout chatwork exec-path-from-shell gptel marginalia markdown-mode
              mermaid-mode orderless paredit plantuml-mode rainbow-delimiters
              slime-company slime-repl-ansi-color vertico))
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Courier New" :foundry "nil" :slant normal :weight regular :height 180 :width normal)))))
