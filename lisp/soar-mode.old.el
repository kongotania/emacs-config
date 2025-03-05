;;; soar-mode.el --- A major mode for the Soar language -*- lexical-binding: t; -*-

;; Version: 0.2
;; Keywords: languages, soar
;; URL: https://github.com/username/soar-mode
;; Package-Requires: ((emacs "28.1"))

;;; License:

;; BSD 3-Clause License
;;
;; Copyright (c) 2025
;; All rights reserved.
;;
;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions are met:
;;
;; * Redistributions of source code must retain the above copyright notice, this
;;   list of conditions and the following disclaimer.
;;
;; * Redistributions in binary form must reproduce the above copyright notice,
;;   this list of conditions and the following disclaimer in the documentation
;;   and/or other materials provided with the distribution.
;;
;; * Neither the name of the copyright holder nor the names of its
;;   contributors may be used to endorse or promote products derived from
;;   this software without specific prior written permission.
;;
;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
;; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
;; DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
;; FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
;; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
;; SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
;; CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
;; OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
;; OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

;;; Commentary:

;; This package provides syntax highlighting and indentation for the
;; Soar language (https://soar.eecs.umich.edu/).
;;
;; Features:
;; - Syntax highlighting for Soar keywords, attributes, variables, and comments
;; - Proper indentation for Soar productions
;; - Auto-mode association for .soar files
;; - Automatic pairing of parentheses, brackets, braces, quotes, and pipes

;;; Code:

(require 'electric)
(require 'elec-pair)

(defgroup soar-mode nil
  "Major mode for editing Soar files."
  :group 'languages)

(defcustom soar-mode-tab-width 4
  "Default tab width inside productions."
  :type 'integer
  :group 'soar-mode)

(defcustom soar-mode-enable-auto-pair t
  "Enable automatic pairing of parentheses, brackets, braces, and quotes."
  :type 'boolean
  :group 'soar-mode)

(defvar soar-mode-syntax-table
  (let ((st (make-syntax-table)))
    ;; Comments start with # and end with newline
    (modify-syntax-entry ?# "<" st)
    (modify-syntax-entry ?\n ">" st)
    ;; Treat ^ as part of symbol names
    (modify-syntax-entry ?^ "_" st)
    ;; Treat $ as part of symbol names
    (modify-syntax-entry ?$ "_" st)
    ;; Treat - as part of symbol names
    (modify-syntax-entry ?- "_" st)
    ;; Define parenthesis pairs
    (modify-syntax-entry ?\( "()" st)
    (modify-syntax-entry ?\) ")(" st)
    (modify-syntax-entry ?\[ "(]" st)
    (modify-syntax-entry ?\] ")[" st)
    (modify-syntax-entry ?{ "(}" st)
    (modify-syntax-entry ?} "){" st)
    ;; Treat < and > as paired delimiters
    (modify-syntax-entry ?< "(>" st)
    (modify-syntax-entry ?> ")<" st)
    ;; String delimiters
    (modify-syntax-entry ?\" "\"" st)  ;; Double quotes for strings
    (modify-syntax-entry ?| "\"" st)   ;; Pipe for symbol strings
    st)
  "Syntax table for `soar-mode'.")

(defconst soar-mode-keywords
  '("sp" "source" "pushd" "popd" "alias" "chunk" "default-wme-depth"
    "echo" "excise" "explain-interrupt" "firing-counts" "gds-print"
    "help" "indifferent-selection" "init-soar" "learn" "matches"
    "max-elaborations" "max-nil-output-cycles" "memories" "multi-attributes"
    "o-support-mode" "preferences" "print" "production-find" "pwatch"
    "quit" "remove-wme" "replay-input" "run" "save-backtraces"
    "select" "set-stop-phase" "soar" "soarnews" "stats" "stop-soar"
    "time" "timers" "unalias" "watch" "warnings")
  "List of Soar keywords.")

(defconst soar-mode-state-keywords
  '("state" "superstate" "operator" "impasse" "attribute" "choices"
    "quiescence" "type" "none" "multiple" "constraint-failure"
    "conflict" "tie" "item" "no-change")
  "List of Soar state-related keywords.")

(defconst soar-mode-operators
  '("->" "-->" "<-" "<--" "=>" "<=")
  "List of Soar operators.")

(defconst soar-mode-font-lock-keywords
  (list
   ;; Comments
   '("#.*$" . font-lock-comment-face)
   
   ;; String literals with pipes
   '("|[^|]*|" . font-lock-string-face)
   
   ;; String literals with double quotes
   '("\"[^\"]*\"" . font-lock-doc-face)
   
   ;; Keywords
   `(,(regexp-opt soar-mode-keywords 'words) . font-lock-keyword-face)
   
   ;; State-related keywords
   `(,(regexp-opt soar-mode-state-keywords 'words) . font-lock-builtin-face)
   
   ;; Operators
   `(,(regexp-opt soar-mode-operators) . font-lock-keyword-face)
   
   ;; Variables starting with $
   '("\\$[A-Za-z0-9_-]+" . font-lock-preprocessor-face)
   
   ;; Attributes starting with ^
   '("\\^[A-Za-z0-9_-]+" . font-lock-variable-name-face)
   
   ;; Identifiers in angle brackets
   '("<[^>]+>" . font-lock-constant-face)
   
   ;; Production names in square brackets
   '("\\[\\s-*\\([^][:space:]]+\\)" 1 font-lock-function-name-face)
  )
  "Highlighting expressions for `soar-mode'.")

(defun soar-in-production-p ()
  "Check if point is inside a Soar production definition."
  (save-excursion
    (let ((found nil))
      (while (and (not found) (not (bobp)))
        (forward-line -1)
        (beginning-of-line)
        (cond
         ((looking-at "\\s-*sp\\s-*{") (setq found t))
         ((looking-at ".*}\\s-*$") (setq found nil) (goto-char (point-min)))))
      found)))

;; Enhanced indentation functions for soar-mode.el

(defun soar-calculate-indent-level ()
  "Calculate the indent level based on parenthesis depth and context."
  (save-excursion
    (beginning-of-line)
    (if (looking-at "\\s-*}") ; Closing brace gets special treatment
        (progn
          (skip-chars-forward " \t")
          (backward-up-list)
          (current-column))
      (let ((indent 0)
            (paren-depth 0))
        ;; Find previous non-blank line
        (forward-line -1)
        (while (and (not (bobp)) (soar-blank-line-p))
          (forward-line -1))
        
        ;; Check if previous line ends with an opening delimiter
        (end-of-line)
        (let ((opens-expr (looking-back "[{(\\[]\\s-*" (line-beginning-position))))
          (beginning-of-line)
          (setq indent (current-indentation))
          
          ;; Add indentation if previous line opens an expression
          (when opens-expr
            (setq indent (+ indent soar-mode-tab-width))))
        
        ;; Return calculated indentation
        indent))))

(defun soar-find-matching-open-delimiter ()
  "Find the position of the matching opening delimiter for the current nesting level."
  (save-excursion
    (let ((closing-delim-pos nil))
      (beginning-of-line)
      (skip-chars-forward " \t")
      (when (looking-at "[]})]")
        (setq closing-delim-pos (point))
        (condition-case nil
            (progn
              (backward-up-list)
              (point))
          (error nil))))))

(defun soar-indent-line ()
  "Indent current line as Soar code with improved subexpression support."
  (interactive)
  (let ((savep (point))
        (indent 0))
    (save-excursion
      (back-to-indentation)
      (let ((line-start (point)))
        (setq indent
              (cond
               ;; Productions and source commands start at column 0
               ((looking-at "\\s-*\\(sp\\|source\\)\\>") 0)
               
               ;; Closing delimiters align with their opening counterparts
               ((looking-at "\\s-*[]})]")
                (or (save-excursion
                      (let ((pos (soar-find-matching-open-delimiter)))
                        (when pos
                          (goto-char pos)
                          (current-column))))
                    ;; Fallback if matching delimiter not found
                    (max 0 (- (current-indentation) soar-mode-tab-width))))
               
               ;; Production comment/documentation strings get indented
               ((and (soar-in-production-p)
                     (looking-at "\\s-*\".*\"\\s-*$"))
                soar-mode-tab-width)
               
               ;; Arrow operator gets indent of soar-mode-tab-width
               ((looking-at "\\s-*-->")
                soar-mode-tab-width)
               
               ;; Opening conditions in LHS get indented
               ((and (soar-in-production-p)
                     (looking-at "\\s-*([^-]"))
                soar-mode-tab-width)
                
               ;; Conditions in RHS get indented
               ((and (soar-in-production-p)
                     (soar-in-rhs-p)
                     (looking-at "\\s-*("))
                (+ soar-mode-tab-width
                   (save-excursion
                     (if (re-search-backward "\\s-*-->" (line-beginning-position -100) t)
                         (current-indentation)
                       soar-mode-tab-width))))
               
               ;; Attributes (^attr) get special indentation
               ((looking-at "\\s-*-?\\^")
                (let ((attr-indent 0))
                  (save-excursion
                    (forward-line -1)
                    (beginning-of-line)
                    (if (looking-at "^[^^]*\\(\\^\\)")
                        (setq attr-indent (- (match-beginning 1) (match-beginning 0)))
                      (setq attr-indent soar-mode-tab-widt)))
                  (if (looking-at "\\s-*-") 
                      (max 0 (1- attr-indent))
                    attr-indent)))
               
               ;; Inside nested subexpressions
               ((soar-in-nested-expr-p)
                (soar-calculate-nested-indent))
               
               ;; If we're inside a production, default to double tab width
               ((soar-in-production-p)
                soar-mode-tab-width)
               
               ;; Default to previous line's indentation
               (t
                (soar-calculate-indent-level))))))
    
    ;; Apply the indentation
    (if (<= (current-column) (current-indentation))
        (indent-line-to indent)
      (save-excursion (indent-line-to indent)))
    
    ;; If point was before the indentation, move it to after
    (when (< savep (point))
      (back-to-indentation))))

(defun soar-in-nested-expr-p ()
  "Check if point is inside a nested expression."
  (save-excursion
    (let ((paren-depth 0))
      (beginning-of-line)
      (skip-chars-forward " \t")
      (while (and (not (eolp)) 
                  (forward-char 1)
                  (not (bobp))
                  (soar-backward-up-list))
        (setq paren-depth (1+ paren-depth)))
      (> paren-depth 1))))

(defun soar-backward-up-list ()
  "Move backward up one level of parentheses, brackets, or braces."
  (condition-case nil
      (backward-up-list 1)
    (error nil)))

(defun soar-calculate-nested-indent ()
  "Calculate indentation for nested expressions."
  (save-excursion
    (let ((indent 0)
          (stack '()))
      (while (and (not (bobp)) 
                  (soar-backward-up-list))
        (push (current-column) stack))
      (if stack
          (+ (car (last stack)) 1)
        (* 2 soar-mode-tab-width)))))

(defun soar-in-rhs-p ()
  "Check if point is in the right-hand side of a production (after -->)."
  (save-excursion
    (let ((arrow-pos (save-excursion
                       (re-search-backward "\\s-*-->" (line-beginning-position -100) t))))
      (and arrow-pos
           (> (point) arrow-pos)))))

;; Add this function to check for balanced expressions
(defun soar-check-balanced-expressions ()
  "Check if parentheses, brackets, and braces are balanced in the buffer."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (let ((unmatched 0)
          (error-positions '()))
      (while (re-search-forward "[][(){}]" nil t)
        (let ((char (char-before)))
          (cond
           ;; Opening delimiters
           ((or (= char ?\() (= char ?\[) (= char ?\{))
            (setq unmatched (1+ unmatched)))
           ;; Closing delimiters
           ((or (= char ?\)) (= char ?\]) (= char ?\}))
            (setq unmatched (1- unmatched))
            (when (< unmatched 0)
              (push (point) error-positions)
              (setq unmatched 0))))))
      
      (if (= unmatched 0)
          (message "All expressions are balanced")
        (message "Found %d unmatched opening delimiter(s)" unmatched)))))
(defun soar-blank-line-p ()
  "Predicate to test whether current line is empty or contains only whitespace."
  (save-excursion
    (beginning-of-line)
    (looking-at "^\\s-*$")))

(defun soar-mode-setup-electric-pair ()
  "Setup electric-pair-mode for Soar mode."
  (when soar-mode-enable-auto-pair
    (electric-pair-local-mode 1)
    ;; Configure special Soar pairs (including quotes and pipes)
    (setq-local electric-pair-pairs
                (append electric-pair-pairs
                        '((?\{ . ?\})
                          (?\[ . ?\])
                          (?\( . ?\))
                          (?\< . ?\>)
                          (?\" . ?\")
                          (?\| . ?\|))))
    (setq-local electric-pair-text-pairs electric-pair-pairs)))

;;;###autoload
(define-derived-mode soar-mode prog-mode "Soar"
  "Major mode for editing Soar cognitive agent language files.

\\{soar-mode-map}"
  :syntax-table soar-mode-syntax-table
  
  ;; Comment setup
  (setq-local comment-start "# ")
  (setq-local comment-end "")
  (setq-local comment-start-skip "#+ *")
  
  ;; Indentation
  (setq-local indent-line-function 'soar-indent-line)
  
  ;; Font-lock
  (setq-local font-lock-defaults '(soar-mode-font-lock-keywords nil nil nil nil))

  ;; Setup Electric Pair mode
  (soar-mode-setup-electric-pair))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.soar\\'" . soar-mode))

(provide 'soar-mode)
;;; soar-mode.el ends here
