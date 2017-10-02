;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Global Variables ;;;;

(package-initialize)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(custom-enabled-themes (quote (wombat)))
 '(display-battery-mode t)
 '(display-time-24hr-format t)
 '(display-time-mode t)
 '(doc-view-continuous t)
 '(hl-line ((t (:underline t))))
 '(inhibit-startup-screen t)
 '(markdown-command "markdown2")
 '(package-selected-packages
   (quote
    (nginx-mode move-text smex powerline multiple-cursors magit expand-region drag-stuff company browse-kill-ring autopair auto-complete ace-jump-mode)))
 '(show-paren-mode t)
 '(uniquify-buffer-name-satyle (quote forward) nil (uniquify)))
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

(setq package-list '(
                     ace-jump-mode
                     auto-complete
                     autopair
                     browse-kill-ring
                     company
                     drag-stuff
                     expand-region
                     magit
                     multiple-cursors
                     powerline
		     move-text
		     nginx-mode
		     ))

;; Backup folder
(defvar --backup-directory (concat user-emacs-directory "backups"))
(if (not (file-exists-p --backup-directory))
    (make-directory --backup-directory t))
(setq backup-directory-alist `(("." . ,--backup-directory)))
(setq make-backup-files t               ; backup of a file the first time it is saved.
      backup-by-copying t               ; don't clobber symlinks
      version-control t                 ; version numbers for backup files
      delete-old-versions t             ; delete excess backup files silently
      delete-by-moving-to-trash t
      kept-old-versions 6               ; oldest versions to keep when a new numbered backup is made (default: 2)
      kept-new-versions 9               ; newest versions to keep when a new numbered backup is made (default: 2)
      auto-save-default t               ; auto-save every buffer that visits a file
      auto-save-timeout 20              ; number of seconds idle time before auto-save (default: 30)
      auto-save-interval 200            ; number of keystrokes between auto-saves (default: 300)
      )


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

;;move text default binding
(move-text-default-bindings)

;; Ansi term
;;(global-set-key (kbd "C-$a;") '(lambda ()(interactive)(ansi-term "/bin/zsh")))

;; Drag Stuff
(require 'drag-stuff)
(drag-stuff-global-mode)

;; Expand region
(require 'expand-region)
(global-set-key (kbd "M-=") 'er/expand-region)

(defun er/add-text-mode-expansions ()
  (make-variable-buffer-local 'er/try-expand-list)
  (setq er/try-expand-list (append
                            er/try-expand-list
                            '(mark-paragraph
                              mark-page))))

(add-hook 'text-mode-hook 'er/add-text-mode-expansions)

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
;;(add-hook 'after-init-hook 'autopair-global-mode) ;; to enable in all buffers

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
