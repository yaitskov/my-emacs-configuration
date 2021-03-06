;;; package --- Summary
;;; Commentary:
;;; Code:

;; Last major update is influence by
;; https://github.com/daviwil/dotfiles/blob/master/Emacs.org#system-settings

;;  M-x toggle-debug-on-error
;; (debug-on-entry 'package-initialize)

;; Startup Performance
;; Make startup fasteer by reducing the frequency of garbage collection
;; and then use a hook to measure Emacs startup time.

;; the default is 800 kilobytes. Measurd in bytes.
(setq gc-cons-threshold (* 50 2000 1000))

;; profile Emacs startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (message "*** Emacs loaded in %s with %d garbage collections."
                     (format "%.2f seconds"
                             (float-time
                              (time-subtract after-init-time before-init-time)))
                     gcs-done)))

;; System settings
;; I don't run Emacs on Android yet.

(require 'subr-x)
(setq dw/is-termux
      (string-suffix-p "Android" (string-trim (shell-command-to-string "uname -a"))))

(setq dw/is-guix-system (and (eq system-type 'gnu/linux)
                             (require 'f)
                             (string-equal (f-read "/etc/issue")
                                           "\nThis is the GNU system.  Welcome.\n")))


;; Initialize package sources
(require 'package)

;; dash is required for lsp-mode
(require 'dash)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("melpa-stable" . "https://stable.melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

;; Fix an issue accessing the ELPA archive in Termux
(when dw/is-termux
  (setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3"))

(add-to-list 'load-path "~/.emacs.d/elpa")
(package-initialize)
; (package-refresh-contents)

(require 'use-package)
(require 'haskell-mode)
(require 'lsp)
(require 'lsp-ui)
(require 'yasnippet)
;(require 'lsp-haskell)
(require 'lsp-treemacs)
(require 'dap-mode)
;(require 'lsp-origami)
;(require 'lsp-pyright-ms)
(require 'company)
(require 'flycheck)

(yas-global-mode)
(add-hook 'prog-mode-hook 'lsp)
;; (unless package-archive-contents
;;   (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
(unless (or (package-installed-p 'use-package)
            dw/is-guix-system)
   (package-install 'use-package))
(require 'use-package)

;; Uncomment this to get a reading on packages that get loaded at startup
;;(setq use-package-verbose t)

;; On non-Guix systems, "ensure" packages by default
(setq use-package-always-ensure (not dw/is-guix-system))

;; key bindings

;(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; show possible key combinations in a popup
(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.3))

;; Emacs always has terminal and
;; this caused a prompt to confirm killing extern process
;; drawback it is less safe
(setq confirm-kill-processes nil)


;; simplify defining prefixd keybindings
(use-package general
  :config
  (general-evil-setup t)

  (general-create-definer dw/leader-key-def
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC")

  (general-create-definer dw/ctrl-c-keys
    :prefix "C-c"))

;; User interface

(setq inhibit-splash-screen t)

(tool-bar-mode 0)
(menu-bar-mode 0)
(scroll-bar-mode 0)        ; Disable visible scrollbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 10) ;; margin left
(setq visible-bell t)

(unless dw/is-termux
  (setq mouse-wheel-scroll-amount '(3 ((shift) . 3))) ;; one line at a time
  (setq mouse-wheel-progressive-speed nil) ;; don't accelerate scrolling
  (setq mouse-wheel-follow-mouse 't) ;; scroll window under mouse
  (setq scroll-step 1) ;; keyboard scroll one line at a time
  (setq use-dialog-box nil)) ;; Disable dialog boxes since they weren't working in Mac OSX

(use-package paren
  :config
  (set-face-attribute 'show-paren-match-expression nil :background "#363e4a")
  (show-paren-mode 1))

(require 'org)
;(require 'use-package)



(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(setq org-log-done t)
(setq org-startup-folded nil)
(use-package term
  :config
  (setq explicit-shell-file-name "bash")
  (setq term-prompt-regexp "$ "))

(if (and (version< emacs-version "26.3") (>= libgnutls-version 30604))
    (setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3"))



;; config before

(use-package nvm :defer t)

;; (use-package flycheck
;;   :ensure t
;;   :init
;;   (global-flycheck-mode t))

;; use command 'lsp-workspace-folders-add' to init project without meta files
(use-package lsp-mode
  :commands lsp
  :hook (
         ((typescript-mode js2-mode web-mode sh-mode) . lsp)
         ; haskell-mode is broken
         ; (haskell-mode . lsp)
         (lsp-mode . lsp-enable-which-key-integration)
         )
  :bind (:map lsp-mode-map
         ("TAB" . completion-at-point))
  ; :config (lsp-enable-which-key-integration t)
  ;; :custom (lsp-headerline-breadcrumb-enable nil)
)
(define-key lsp-mode-map (kbd "C-c C-l") lsp-command-map)


(with-eval-after-load 'lsp-mode
  (add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration))

;; (use-package lsp-haskell
;;   :ensure t
;;   :config
;;   (setq lsp-haskell-server-path "/home/dan/.local/bin/haskell-language-server-wrapper")
;;   (setq lsp-haskell-process-path-hie "/home/dan/.local/bin/haskell-language-server-wrapper")
;;   ;(setq lsp-haskell-server-args ("-d -l /tmp/hls.log"))
;;   ;; Comment/uncomment this line to see interactions between lsp client/server.
;;   (setq lsp-log-io t))
;; Hooks so haskell and literate haskell major modes trigger LSP setup
;(add-hook 'haskell-mode-hook #'lsp)
;(add-hook 'haskell-literate-mode-hook #'lsp)

(dw/leader-key-def
  "l"  '(:ignore t :which-key "lsp")
  "ld" 'xref-find-definitions
  "lr" 'xref-find-references
  "ln" 'lsp-ui-find-next-reference
  "lp" 'lsp-ui-find-prev-reference
  "ls" 'counsel-imenu
  "le" 'lsp-ui-flycheck-list
  "lS" 'lsp-ui-sideline-mode
  "lX" 'lsp-execute-code-action)

(use-package lsp-ui
  ;; :straight t
  :hook (lsp-mode . lsp-ui-mode)
  ;:config
  ;(setq lsp-ui-sideline-enable t)
  ; (setq lsp-ui-sideline-show-hover nil)
  ;(setq lsp-ui-doc-position 'bottom)
  (lsp-ui-doc-show))


(use-package typescript-mode
  :mode "\\.ts\\'"
  ; :hook (typescript-mode . lsp-deferred)
  :config
  (setq typescript-indent-level 2))

(defun dw/set-js-indentation ()
  (setq js-indent-level 2)
  (setq evil-shift-width js-indent-level)
  (setq-default tab-width 2))

(use-package js2-mode
  :mode "\\.jsx?\\'"
  :config
  ;; Use js2-mode for Node scripts
  (add-to-list 'magic-mode-alist '("#!/usr/bin/env node" . js2-mode))

  ;; Don't use built-in syntax checking
  (setq js2-mode-show-strict-warnings nil)

  ;; Set up proper indentation in JavaScript and JSON files
  (add-hook 'js2-mode-hook #'dw/set-js-indentation)
  (add-hook 'json-mode-hook #'dw/set-js-indentation))

(use-package prettier-js
  ;; :hook ((js2-mode . prettier-js-mode)
  ;;        (typescript-mode . prettier-js-mode))
  :config
  (setq prettier-js-show-errors nil))

;; lsp-mode supports bash out of the box
;; bash backend isntallation: sudo npm i -g bash-language-server

;; c++ backend installation: "nix-env -i ccls"
(use-package ccls
  :hook ((c-mode c++-mode objc-mode cuda-mode) .
         (lambda () (require 'ccls) (lsp))))

;; (use-package lsp-haskell
;;  :ensure t
;;  :config
;;  (setq lsp-haskell-server-path "/home/dan/.local/bin/haskell-language-server")
;;  ; (setq lsp-haskell-process-path-hie "haskell-language-server")
;;  ;; Comment/uncomment this line to see interactions between lsp client/server.
;;  (setq lsp-log-io t)

;; )

;; vim like undo with all version as tree
(use-package undo-tree
  :init
  (global-undo-tree-mode 1))


;;
(dolist (mode '(org-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

; (setq large-file-warning-threshold nil)
(setq vc-follow-symlinks t)
(setq ad-redefinition-action 'accept)

(use-package doom-themes :defer t)
(unless dw/is-termux
  (load-theme 'doom-palenight t)
  (doom-themes-visual-bell-config))

;; multiple workspaces - names groups of buffers
;; similar to tmux switching between terminals c-c 1
(use-package perspective
  :demand t
  :bind (("C-M-k" . persp-switch)
         ("C-M-n" . persp-next)
         ("C-x C-b" . persp-list-buffers)
         ("C-x k" . persp-kill-buffer*))
  :custom
  (persp-initial-frame-name "Main")
  :config
  ;; Running `persp-mode' multiple times resets the perspective list...
  (unless (equal persp-mode t)
    (persp-mode)))

;; mode line
(use-package super-save)
(super-save-mode +1)

;;
(use-package savehist
  :config
  (setq history-length 25)
  (savehist-mode 1))


(defalias 'yes-or-no-p 'y-or-n-p)

(set-frame-parameter nil 'unsplittable t)
(add-hook 'purescript-mode-hook
  (lambda () (turn-on-purescript-indentation)))

(defun increment-number-at-point ()
      (interactive)
      (skip-chars-backward "0-9")
      (or (looking-at "[0-9]+")
          (error "No number at point"))
      (replace-match (number-to-string (1+ (string-to-number (match-string 0))))))


(setq use-dialog-box nil)
(require 'flycheck)
(global-flycheck-mode)
(setq flycheck-check-syntax-automatically
      '(mode-enabled idle-change save))



; (add-to-list 'auto-mode-alist '("\\.tsc\\'" . typescript-mode))

(add-to-list 'auto-mode-alist '("\\.scss\\'" . css-mode))
(add-to-list 'auto-mode-alist '("\\.yml\\'" . python-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . gfm-mode))
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . web-mode))

(defun my-web-mode-hook ()
  "Hooks for Web mode."
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
)
(add-hook 'web-mode-hook  'my-web-mode-hook)


(setq company-tooltip-align-annotations t)


;; 'before-make-frame-hook
(add-hook 'after-make-frame-functions
    (lambda (frame)
      (select-frame frame)
      (set-foreground-color "white")
      (set-background-color "black")
      ; (set-face-attribute 'default nil :height 200)
      (set-face-attribute 'default nil
                    :family "Nimbus Mono L"; "Liberation Mono"; "DejaVu Sans Mono";  "Mx437 CompaqThin 8x16"
                    :height 200)
      ;; (set-face-attribute 'default nil
      ;;                     :family  "Inconsolata"
      ;;                     :height 200)
      ;;                     :weight 'normal
      ;;                     :width 'normal)
      )
)


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(haskell-indent-after-keywords
   (quote
    (("where" 2 0)
     ("of" 2)
     ("do" 2)
     ("mdo" 2)
     ("rec" 2)
     ("in" 2 0)
     ("{" 2)
     "if" "then" "else" "let")))
 '(haskell-indent-offset 2)
 '(haskell-indent-rhs-align-column 2)
 '(haskell-indentation-electric-flag t)
 '(haskell-indentation-layout-offset 2)
 '(haskell-indentation-left-offset 2)
 '(haskell-indentation-starter-offset 2)
 '(haskell-indentation-where-post-offset 2)
 '(haskell-mode-hook
   (quote
    (flyspell-prog-mode haskell-indent-mode turn-on-haskell-indent)))
 ;'(lsp-haskell-diagnostics-on-change t)
 ;'(lsp-haskell-server-args (quote ("-d" "-l" "/tmp/hls.log" "--debug" "")))
 ;'(lsp-haskell-server-path "/home/dan/.local/bin/haskell-language-server")
 '(lsp-keymap-prefix "C-c l")
 '(org-agenda-files (quote ("~/demo/emacs/org-agenda.org")))
 '(package-selected-packages
   (quote
    (yascroll yasnippet lsp-python-ms lsp-pyright lsp-origami daemons dante dap-mode ccls dash dash-docs dash-functional prettier dired-launch smart-mode-line diminish doom-themes use-package general nvm js2-mode xref xref-js2 ivy-xref typing-game multi-vterm multi-term dockerfile-mode org-gcal undo-tree terraform-mode company-ghci company-lsp projectile treemacs-magit treemacs company which-key lsp-ui lsp-treemacs  poly-R ess fancy-battery ormolu graphviz-dot-mode yaml-mode magit-find-file magit-imerge magit git-blamed git-commit git-command lsp-mode nix-mode flycheck-haskell super-save openwith ztree gitconfig-mode git-lens elm-mode skewer-mode slack typescript-mode purescript-mode haskell-mode flycheck))))

(defun jsx-mode-init ()
  (define-key jsx-mode-map (kbd "C-c d") 'jsx-display-popup-err-for-current-line)
  (when (require 'auto-complete nil t)
    (auto-complete-mode t)))

(add-hook 'jsx-mode-hook 'jsx-mode-init)


(add-hook 'haskell-mode-hook 'turn-on-haskell-indent)
(define-key haskell-mode-map "\C-ch" 'haskell-hoogle)

;; (defun haskell-setup ()
;;     (make-local-variable 'tab-stop-list)
;;     (setq tab-stop-list (number-sequence 0 120 4))
;;     (setq indent-line-function 'tab-to-tab-stop)
;;     (setq haskell-indent-spaces 4))

(add-hook 'haskell-mode-hook 'haskell-setup)


(require 'openwith)

(setq openwith-associations '(
                              ("\\.pdf\\'" "evince" (file))
                              ("\\.wmv\\'" "vlc" (file))
                              ("\\.avi\\'" "smplayer" (file))
                              ("\\.mp3\\'" "smplayer" (file))
                              )
      )

(openwith-mode t)
(setq large-file-warning-threshold (expt 10 8))

(setq twittering-use-master-password t)

(add-to-list 'auto-mode-alist '("\\.twig\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.tpl\\'" . html-mode))
(column-number-mode)

(setq dired-deletion-confirmer '(lambda (x) t))
(setq dired-recursive-deletes 'always)

(defun revert-buffer-no-confirm ()
    "Revert buffer without confirmation."
    (interactive) (revert-buffer t t))
(setq indent-tabs-mode nil)
(setq-default indent-tabs-mode nil)


(defun s (buffer-name)
  (interactive "Bbuffer name\n")
  (shell buffer-name)
  )
(setq sort-fold-case t)

(defun mulstring (str n)
  (if (> n 0)
      (concat str
	      (mulstring str (- n 1)))
    ""))
(defun shift-to-left (n)
  (interactive "p")
  (replace-regexp (concat "^  "
			  (mulstring "  " n))
		  ""
		  nil
		  (min (point)
		       (mark))
		  (max (point)
		       (mark))))

(defun shift-to-right (n)
  (interactive "p")
  (replace-regexp "^"
		  (concat "  "
			  (mulstring "  " n))
		  nil
		  (min (point)
		       (mark))
		  (max (point)
		       (mark))))

(defun myshift ()
  (interactive)
  (let (a (mx (max (point) (mark)))
	(mn (min (point) (mark))))
    (save-excursion
      (goto-char mn)
      (beginning-of-line)
      (setq a (- (re-search-forward "[^ ]")
		 mn 1))
      (beginning-of-line)
      (if (> a 0)
	  (replace-regexp (concat "^"
				  (mulstring " " a))
			  ""
			  nil
			  (point)
			  mx)
	(replace-regexp "^"
			(mulstring " " (- a))
			nil
			(point)
			mx)))
    (goto-char mn)))

(setq make-backup-files nil)
(set-foreground-color "white")
(set-background-color "black")
;; (set-face-attribute 'default nil
;;                     :family "Nimbus Mono L"; "Liberation Mono"; "DejaVu Sans Mono";  "Mx437 CompaqThin 8x16"

; "Mx437 ATI 8x16"
; "Mx437 IBM DOS ISO9"
; "Mx437 PhoenixVGA 9x16"
; "Mx437 EuroPC Mono"
;;  "Mx437 CL EagleIII 9x16"
;                    :family "Ac437 NEC APC3 8x16"
;                    :height 200)
;;                     :weight 'normal
;;                     :width 'normal)


;(set-frame-font "-misc-fixed-medium-r-normal--24-120-100-100-c-90-iso10646-1")


(global-set-key "\e\C-a" 'append-to-buffer)
(global-set-key "\e\eb" 'magit-show-refs)
(global-set-key "\e\et" 'magit-status)
(global-set-key "\C-z" 'undo)
(global-set-key "\M-s" 'search-forward-regexp)
(global-set-key "\e\es" 'replace-regexp)
(global-set-key "\e\ev" 'revert-buffer-no-confirm)
(global-set-key "\M-\\" 'delete-horizontal-space)
(global-set-key "\e\eg" 'goto-line)
(global-set-key "\e\e<" 'shift-to-left)
(global-set-key "\e\e>" 'shift-to-right)
(global-set-key "\M- " 'just-one-space)


(global-set-key "\e\em" 'compile)
(global-set-key "\e\ec" 'comment-region)
(global-set-key "\e\eu" 'uncomment-region)
(global-set-key "\e\eq" 'query-replace)
(global-set-key "\e\er" 'replace-string)
; (global-set-key "\e\eb" 'ecb-minor-mode)
(global-set-key "\e\el" 'rml)

(global-set-key "\C-w" 'backward-kill-word)
(global-set-key "\C-x\C-k" 'kill-region)
(global-set-key "\C-c\C-k" 'kill-region)
(global-set-key "\C-x\C-m" 'execute-extended-command)
(global-set-key "\C-c\C-m" 'execute-extended-command)
(set-terminal-coding-system 'utf-8-unix)
(setq default-major-mode 'paragraph-indent-text-mode)
; (setq auto-save-default nil)

;; (add-hook 'auto-save-hook
;; 	  '(lambda() ()))

(add-hook 'shell-mode-hook (lambda ()
                             (setq show-trailing-whitespace nil)))

(setq ssl-program-name "gnutls-cli"
      ssl-program-arguments '("--insecure" "-p" service host)
      ssl-certificate-verification-policy 1)

(add-hook 'before-save-hook 'delete-trailing-whitespace)


(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )




(ansi-color-for-comint-mode-on)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(set-buffer-file-coding-system 'utf-8)
(set-clipboard-coding-system 'utf-8)

(set-input-method 'russian-computer)

(setq x-select-enable-clipboard t)
(global-set-key "\C-xO" '(lambda nil (interactive) (other-window -1)))





;; (add-to-list
;;  'package-archives
;;  '("melpa" . "https://melpa.org/packages/")
;;  t)
;; (package-initialize)
(shell)

;; (when (load "flymake" t)
;;  (defun flymake-pylint-init ()
;;    (let* ((temp-file (flymake-init-create-temp-buffer-copy
;;                       'flymake-create-temp-inplace))
;;           (local-file (file-relative-name
;;                        temp-file
;;                        (file-name-directory buffer-file-name))))
;;          (list "pep8" (list "--repeat" local-file))))

;;  (add-to-list 'flymake-allowed-file-name-masks
;;               '("\\.py\\'" flymake-pylint-init)))

;; (defun my-flymake-show-help ()
;;   (when (get-char-property (point) 'flymake-overlay)
;;     (let ((help (get-char-property (point) 'help-echo)))
;;       (if help (message "%s" help)))))

;; (add-hook 'python-mode-hook
;;  	  '(lambda() (flymake-mode)))

;; (add-hook 'post-command-hook 'my-flymake-show-help)
(setq Buffer-menu-name-width 80)


 ; (global-set-key "\C-M-l" 'lsp-format-region)
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))


(require 'dired)
(put 'dired-find-alternate-file 'disabled nil)
(define-key dired-mode-map (kbd "<mouse-2>") 'dired-find-alternate-file)

; (super-save-mode +1)
(setq js-indent-level 2)
(setq-default typescript-indent-level 2)
(setq-default typescript-expr-indent-offset 4)


(defun find-file-at-point-with-line()
  "if file has an attached line num goto that line, ie boom.rb:12"
  (interactive)
  (setq line-num 0)
  (save-excursion
    (search-forward-regexp "[^ ]:" (point-max) t)
    (if (looking-at "[0-9]+")
         (setq line-num (string-to-number (buffer-substring (match-beginning 0) (match-end 0))))))
  (find-file-at-point)
  (if (not (equal line-num 0))
      (progn
        ; todo right-char $ column
        (goto-line line-num))))

(global-set-key "\C-x-" 'find-file-at-point-with-line)

(display-time-mode)
      (set-face-attribute 'default nil
                    :family "Nimbus Mono L"; "Liberation Mono"; "DejaVu Sans Mono";  "Mx437 CompaqThin 8x16"
                    :height 200)


;; (use-package org-gcal
;;   :ensure t
;;   :config
;;   (setq org-gcal-client-id "533167337614-q0pf2tf8p0tdghksqm0us72itt6i5mn9.apps.googleusercontent.com"
;;         org-gcal-client-secret "nd3dcvRk-lO68hoRVI6EXIco"
;;         org-gcal-file-alist '(("rtfm.rtfm.rtfm@gmail.com" .  "~/data/org/gcal.org"))))

;; (add-hook 'org-agenda-mode-hook (lambda () (org-gcal-sync) ))
;; (add-hook 'org-capture-after-finalize-hook (lambda () (org-gcal-sync) ))

;; (add-to-list 'load-path "~/.emacs.d/pack/icicles")
;;(require 'icicles)
;;(icicle-mode 1)


;; (use-package super-save
;;   :ensure f
;;   :config
;;   (super-save-mode +1))


; (require 'super-save)

(use-package diminish)
(diminish 'undo-tree-mode)
(diminish 'super-save-mode)
;(diminish 'company-mode)
(diminish 'eldoc-mode)

(use-package smart-mode-line
  :disabled
  :if dw/is-termux
  :config
  (setq sml/no-confirm-load-theme t)
  (sml/setup)
  (sml/apply-theme 'respectful)  ; Respect the theme colors
  (setq sml/mode-width 'right
      sml/name-width 60)

  (setq-default mode-line-format
  `("%e"
      ,(when dw/exwm-enabled
          '(:eval (format "[%d] " exwm-workspace-current-index)))
      mode-line-front-space
      evil-mode-line-tag
      mode-line-mule-info
      mode-line-client
      mode-line-modified
      mode-line-remote
      mode-line-frame-identification
      mode-line-buffer-identification
      sml/pos-id-separator
      (vc-mode vc-mode)
      " "
      ;mode-line-position
      sml/pre-modes-separator
      mode-line-modes
      " "
      mode-line-misc-info)))

; (set-frame-font "DejaVu Sans Mono-16")
(provide 'init)
;;; init.el ends here
