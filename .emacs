;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Global Variables ;;;;
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(TeX-PDF-mode t)
 '(TeX-source-correlate-method (quote synctex))
 '(TeX-source-correlate-mode t)
 '(TeX-source-correlate-start-server t)
 '(column-number-mode t)
 '(current-language-environment "French")
 '(custom-enabled-themes (quote (wombat)))
 '(custom-safe-themes (quote ("2b5aa66b7d5be41b18cc67f3286ae664134b95ccc4a86c9339c886dfd736132d" default)))
 '(display-battery-mode t)
 '(display-time-24hr-format t)
 '(display-time-mode t)
 '(doc-view-continuous t)
 '(inhibit-startup-screen t)
 '(markdown-command "markdown2")
 '(save-place t nil (saveplace))
 '(scroll-bar-mode nil)
 '(send-mail-function (quote smtpmail-send-it))
 '(show-paren-mode t)
 '(size-indication-mode t)
 '(tool-bar-mode nil)
 '(uniquify-buffer-name-style (quote forward) nil (uniquify)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Repositories ;;;;

;; Melpa, Marmalade & gnu repo for Emacs24
(when (>= emacs-major-version 24)
  (setq package-archives
        '(("gnu" . "http://elpa.gnu.org/packages/")
          ("marmalade" . "http://marmalade-repo.org/packages/")
          ("melpa" . "http://melpa.milkbox.net/packages/"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq package-list '(auctex-latexmk auctex auctex-lua auto-complete-c-headers autopair company el-autoyas ensime auto-complete dash log4e makefile-runner php-mode popup pretty-mode s scala-mode2 smex web-beautify web-mode yaml-mode yasnippet-bundle yaxception))



;; activate all the packages (in particular autoloads)
(package-initialize)

;;fetch the list of packages available
(unless package-archive-contents
  (package-refresh-contents))

;; install the missing packages
(dolist (package package-list)
  (unless (package-installed-p package)
    (package-install package)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Core emacs tweaks ;;;;

;; Change default indentation
(setq-default c-basic-offset 4)

;; Auto-fill, \n automatically your text
(add-hook 'text-mode-hook 'turn-on-auto-fill)

;; Automatically update an unmodified buffer
(global-auto-revert-mode t)

;; Kill buffer withouth prompt
(global-set-key "\C-xk" 'kill-this-buffer)

;; Move from paragraph to paragraph with the unbind M-n/M-p
(global-set-key (kbd "M-n") 'forward-paragraph)
(global-set-key (kbd "M-p") 'backward-paragraph)

;; Kill the scratch buffer
(kill-buffer "*scratch*")

;; Ansi term
(global-set-key "\C-x\ a" '(lambda ()(interactive)(ansi-term "/bin/zsh")))

;; Don't prompt for exiting existing buffers
(defun my-kill-emacs ()
  "save some buffers, then exit unconditionally"
  (interactive)
  (save-some-buffers nil t)
  (kill-emacs))
(global-set-key (kbd "C-x C-c") 'my-kill-emacs)

;; Toggle fullscreen on F11
(defun toggle-fullscreen ()
  "Toggle full screen on X11"
  (interactive)
  (when (eq window-system 'x)
    (set-frame-parameter
     nil 'fullscreen
     (when (not (frame-parameter nil 'fullscreen)) 'fullboth))))
(global-set-key [f11] 'toggle-fullscreen)

;; F12 to launch Makefile

(global-set-key [f12] 'makefile-runner)

;;automatic company-mode (autocompletion)
(add-hook 'after-init-hook 'global-company-mode)

;; Function needed to indent the whole buffer
(defun x ()
  "Indent the buffer"
  (interactive)
  (save-excursion
    (delete-trailing-whitespace)
    (indent-region (point-min) (point-max) nil)
    (untabify (point-min) (point-max))))

;; Auto pair mode
(add-hook 'after-init-hook 'autopair-global-mode) ;; to enable in all buffers

;; Auto correct for spelling mistakes
(setq-default ispell-program-name "aspell")

;; Do (buffers/files) interactively
(ido-mode t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Core plugins ;;;;

;; Buffer-move, swap your buffers all over the place
(global-set-key (kbd "C-S-p") 'buf-move-up)
(global-set-key (kbd "C-S-n") 'buf-move-down)
(global-set-key (kbd "C-S-b") 'buf-move-left)
(global-set-key (kbd "C-S-f") 'buf-move-right)

;; 80-100 column rule
(setq whitespace-style '(face empty tabs lines-tail trailing)
      whitespace-line-column 82 )
(global-whitespace-mode t)

;; Pretty symbol (e.g. lambda)
(add-hook 'after-init-hook 'global-pretty-mode t)
(add-hook 'scala-mode2 'turn-on-pretty-mode)
(add-hook 'elisp 'turn-on-pretty-mode)
(add-hook 'tuareg-mode 'turn-on-pretty-mode)
(add-hook 'haskell-mode 'turn-on-pretty-mode)



;;;;;fiplr + ido vertical

;; Outline mode
(defun turn-on-outline-minor-mode ()
  (outline-minor-mode 1))
(add-hook 'LaTeX-mode-hook 'turn-on-outline-minor-mode)
(add-hook 'latex-mode-hook 'turn-on-outline-minor-mode)

;; Ocaml tuareg mode
(setq load-path (cons "~/.emacs.d/" load-path))
(add-to-list 'auto-mode-alist '("\\.ml[iylp]?" . tuareg-mode))
(autoload 'tuareg-mode "tuareg" "Major mode for editing OCaml code" t)
(autoload 'tuareg-run-ocaml "tuareg" "Run an inferior OCaml process." t)
(autoload 'ocamldebug "ocamldebug" "Run the OCaml debugger" t)

;; undo !
(global-set-key (kbd "C-u") 'undo)
