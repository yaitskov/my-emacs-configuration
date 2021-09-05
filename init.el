;;; package --- Summary
;;; Commentary:
;;; Code:

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

;; Emacs always has terminal and
;;  this caused a prompt to confirm killing extern process
(setq confirm-kill-processes nil)

(use-package general
  :config
  (general-evil-setup t)

  (general-create-definer dw/leader-key-def
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC")

  (general-create-definer dw/ctrl-c-keys
    :prefix "C-c"))


(require 'org)
(require 'use-package)



(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(setq org-log-done t)
(setq org-startup-folded nil)
(use-package term
  :config
  (setq explicit-shell-file-name "bash")
  (setq term-prompt-regexp "$ "))
;; (defadvice switch-to-buffer (before save-buffer-now activate)
;;   (when buffer-file-name (save-buffer)))

;; (defadvice switch-to-buffer (before save-buffer-now)
;;   (save-buffer))

;; (ad-activate 'switch-to-buffer)


(if (and (version< emacs-version "26.3") (>= libgnutls-version 30604))
    (setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3"))

;(add-to-list 'load-path "~/.emacs.d/lisp")
(add-to-list 'load-path "~/.emacs.d/elpa")
;; (add-to-list 'load-path "~/.emacs.d/elpa/openwith-20120531.2136")
;; (add-to-list 'load-path "~/.emacs.d/elpa/super-save-20190806.915")
;; (add-to-list 'load-path "~/.emacs.d/elpa/purescript-mode-20200708.827")
;; (add-to-list 'load-path "~/.emacs.d/elpa/flycheck-20200610.1809")
;; (add-to-list 'load-path "~/.emacs.d/elpa/flycheck-haskell-20200218.753")
;; (add-to-list 'load-path "~/.emacs.d/elpa/ztree-20191108.2234")
;; (add-to-list 'load-path "~/.emacs.d/elpa/dash-20200524.1947")
;; (add-to-list 'load-path "~/.emacs.d/elpa/gitconfig-mode-20180318.1956")
;; (add-to-list 'load-path "~/.emacs.d/elpa/git-lens-20190319.1342")
;; (add-to-list 'load-path "~/.emacs.d/elpa/nix-mode-20200521.1745")
;; (add-to-list 'load-path "~/.emacs.d/elpa/lsp-docker-20200222.505")
;; (add-to-list 'load-path "~/.emacs.d/elpa/lsp-haskell-20200527.2014")
;; (add-to-list 'load-path "~/.emacs.d/elpa/lsp-java-20200701.2040")
;; (add-to-list 'load-path "~/.emacs.d/elpa/lsp-latex-20200701.931")
;; (add-to-list 'load-path "~/.emacs.d/elpa/lsp-mode-20200712.1933")
;; (add-to-list 'load-path "~/.emacs.d/elpa/lsp-treemacs-20200710.532")
;; (add-to-list 'load-path "~/.emacs.d/elpa/lsp-ui-20200703.448")
;; (add-to-list 'load-path "~/.emacs.d/elpa/use-package-20200629.1856")

; (package-initialize)
(require 'package)
(require 'use-package)

(require 'haskell-mode)

;(add-hook 'haskell-mode-hook 'lsp)
; (add-hook 'haskell-mode-hook #'lsp)
; (add-hook 'haskell-literate-mode-hook #'lsp)


;; config before
; (require 'lsp)
(require 'lsp)
(require 'lsp-haskell)
;; Hooks so haskell and literate haskell major modes trigger LSP setup
(add-hook 'haskell-mode-hook #'lsp)
(add-hook 'haskell-literate-mode-hook #'lsp)

(use-package nvm
  :defer t)

(use-package lsp-mode
  ;; :straight t
  :commands lsp
  :hook ((typescript-mode js2-mode web-mode) . lsp)
  :bind (:map lsp-mode-map
         ("TAB" . completion-at-point))
  :custom (lsp-headerline-breadcrumb-enable nil))

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
  :config
  (setq lsp-ui-sideline-enable t)
  (setq lsp-ui-sideline-show-hover nil)
  (setq lsp-ui-doc-position 'bottom)
  (lsp-ui-doc-show))

;; (use-package lsp-haskell
;;  :ensure t
;;  :config
;;  (setq lsp-haskell-server-path "/home/dan/.local/bin/haskell-language-server")
;;  ; (setq lsp-haskell-process-path-hie "haskell-language-server")
;;  ;; Comment/uncomment this line to see interactions between lsp client/server.
;;  (setq lsp-log-io t)

;; )

(global-undo-tree-mode)
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



(add-to-list 'auto-mode-alist '("\\.tsc\\'" . typescript-mode))

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
 '(lsp-haskell-diagnostics-on-change t)
 '(lsp-haskell-server-args (quote ("-d" "-l" "/tmp/hls.log" "--debug" "")))
 '(lsp-haskell-server-path "haskell-language-server")
 '(org-agenda-files (quote ("~/demo/emacs/org-agenda.org")))
 '(package-selected-packages
   (quote
    (general nvm js2-mode xref xref-js2 ivy-xref typing-game multi-vterm multi-term dockerfile-mode org-gcal undo-tree terraform-mode company-ghci company-lsp projectile treemacs-magit treemacs company which-key lsp-ui lsp-treemacs lsp-haskell poly-R ess fancy-battery ormolu graphviz-dot-mode yaml-mode magit-find-file magit-imerge magit git-blamed git-commit git-command lsp-mode nix-mode flycheck-haskell super-save openwith ztree gitconfig-mode git-lens elm-mode skewer-mode slack typescript-mode purescript-mode haskell-mode flycheck))))

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

(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))

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


; (set-face-attribute 'default nil :height 200)
(setq inhibit-splash-screen t)
(tool-bar-mode 0)


(add-to-list
 'package-archives
 '("melpa" . "https://melpa.org/packages/")
 t)
(package-initialize)
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

(set-frame-font "DejaVu Sans Mono-16")

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
(super-save-mode +1)
