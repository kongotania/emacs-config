(require 'package)

(setq gc-cons-threshold 100000000)
(setq read-process-output-max (* 1024 1024))

(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
(package-initialize)

(setq default-frame-alist
       '((height . 30)
         (width . 90)
         (left . 10)
         (top . 10)))

;; refresh package metadata
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(setq user-full-name "kongo Tania"
      user-mail-address "kongotania@gmail.com")

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
  :ensure t
  :diminish company-mode
  :config (add-hook 'after-init-hook #'global-company-mode))

(use-package flycheck
  :ensure t
  :diminish flycheck-mode
  :config (add-hook 'after-init-hook #'global-flycheck-mode))

(use-package slime
  :ensure t
  :config
  (setq inferior-lisp-program "lx86cl64")
  (setq slime-net-coding-system 'utf-8-unix)
  (setq slime-contribs '(slime-fancy
			 slime-company
			 slime-repl-ansi-color))
  (global-set-key "\C-cs" 'slime-selector)
  (add-hook 'slime-repl-mode-hook 'slime-repl-ansi-color-mode)
  )

(use-package slime-repl-ansi-color
  :ensure t
  :after (slime))

(use-package paredit
  :ensure t
  :after (:any (:all slime company) (:all geiser company))
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
  :ensure t
  :after (slime company)
  :config
  (add-hook 'emacs-lisp-mode-hook 'rainbow-delimiters-mode)
  (add-hook 'ielm-mode-hook 'rainbow-delimiters-mode)
  (add-hook 'lisp-mode-hook 'rainbow-delimiters-mode)
  (add-hook 'lisp-interaction-mode-hook 'rainbow-delimiters-mode)
  (add-hook 'slime-repl-mode-hook 'rainbow-delimiters-mode))

;; ;; sample `helm' configuration use https://github.com/emacs-helm/helm/ for details
(helm-mode)
(require 'helm-xref)
(define-key global-map [remap find-file] #'helm-find-files)
(define-key global-map [remap execute-extended-command] #'helm-M-x)
(define-key global-map [remap switch-to-buffer] #'helm-mini)

(use-package lsp-mode
  :ensure t
  :init
  ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  (setq lsp-keymap-prefix "C-c l")
  :hook ((c++-mode . lsp)
         (c-mode . lsp)
         (lsp-mode . lsp-enable-which-key-integration))
  :commands lsp)

;;optionally

(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode)

;; if you are helm user
(use-package helm-lsp
  :ensure t
  :commands helm-lsp-workspace-symbol)

;; if you are ivy user
(use-package lsp-ivy
  :ensure t
  :commands lsp-ivy-workspace-symbol)

(use-package lsp-treemacs
  :ensure t
  :commands lsp-treemacs-errors-list)

;; optionally if you want to use debugger
(use-package dap-mode
  :ensure t)

;;
;; (use-package dap-cpp
;;   :ensure t) 

;; optional if you want which-key integration
(use-package which-key
  :config
  (which-key-mode))

(setq load-path (cons "~/.emacs.d/lean4-mode" load-path))
(use-package lean4-mode)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(blink-cursor-mode nil)
 '(custom-enabled-themes '(wheatgrass))
 '(custom-safe-themes
   '("00445e6f15d31e9afaa23ed0d765850e9cd5e929be5e8e63b114a3346236c44c" "2b501400e19b1dd09d8b3708cefcb5227fda580754051a24e8abf3aff0601f87" "fee7287586b17efbfda432f05539b58e86e059e78006ce9237b8732fde991b4c" "c5e7a36784b1955b28a89a39fef7c65ddc455b8e7fd70c6f5635cb21e4615670" "36b57dcbe8262c52d3123ed30fa34e5ef6b355881674142162a8ca8e26124da9" "0e28d654f0db881aeaa50e1fa80725bb123795990285ac0b7d21edd68e6bf878" "52632b69c2813771327a2c22f51ccaca466ba3cc1aa8f3bf2d613573ea934993" "6b912e025527ffae0feb76217f1a3e494b0699e5219ab59ea4b3a36c319cea17" "10e5d4cc0f67ed5cafac0f4252093d2119ee8b8cb449e7053273453c1a1eb7cc" "4594d6b9753691142f02e67b8eb0fda7d12f6cc9f1299a49b819312d6addad1d" "b5fd9c7429d52190235f2383e47d340d7ff769f141cd8f9e7a4629a81abc6b19" "014cb63097fc7dbda3edf53eb09802237961cbb4c9e9abd705f23b86511b0a69" default))
 '(package-selected-packages
   '(gnu-elpa-keyring-update magit-stats magit-section doom-themes modus-themes nimbus-theme solarized-theme avy dap-mode helm-lsp helm-xref hydra lsp-mode lsp-treemacs projectile which-key geiser-guile geiser-chez rainbow-delimiters paredit slime-repl-ansi-color slime-company slime flycheck company))
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "JetBrains Mono" :foundry "JB" :slant normal :weight regular :height 158 :width normal)))))
