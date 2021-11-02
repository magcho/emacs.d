;; Init.el --- My init.el  -*- lexical-binding: t; -*-

;; Copyright (C) 2021 magcho

;; Author: magcho <mail@magcho.com>

;;; Commentary:

;; My init.el.

;;; Code:

;; this enables this running method
;;   emacs -q -l ~/.debug.emacs.d/init.el

;; native compile
(setq package-native-compile t)

(setq gc-cons-threshold 100000000) ;; 100mb
(setq read-process-output-max (* 1024 1024)) ;; 1mb

(eval-and-compile (require 'cl-lib nil t))
;; el-get が cl に依存しているので, ここで
;; `Package cl is deprecated' が表示されるのを止めておく.
(setq byte-compile-warnings '(not cl-functions obsolete))

(eval-and-compile
  (customize-set-variable
   'package-archives '(("org" . "https://orgmode.org/elpa/")
                       ("melpa" . "https://melpa.org/packages/")
                       ("gnu" . "https://elpa.gnu.org/packages/")))
  (package-initialize)
  (unless (package-installed-p 'leaf)
    (package-refresh-contents)
    (package-install 'leaf))

  (leaf leaf-keywords
    :ensure t
    :init
    ;; optional packages if you want to use :hydra, :el-get, :blackout,,,
    (leaf hydra :ensure t)
    (leaf el-get
      :ensure t
      :custom
      )
    (leaf blackout :ensure t)
    :config
    ;; initialize leaf-keywords.el
    (leaf-keywords-init)) )
;; </leaf-install-code>


;; Now you can use leaf!
(leaf leaf-tree :ensure t)
(leaf leaf-convert :ensure t)
(leaf *cus-edit
  :doc "tools for customizing Emacs and Lisp packages"
  :tag "builtin" "faces" "help"
  :preface (setq custom-file "~/.emacs.d/custom.el")
  :custom `((custom-file . ,(locate-user-emacs-file "custom.el"))))
(leaf delsel
  :doc "delete selection if you insert"
  :tag "builtin"
  :global-minor-mode delete-selection-mode)
(leaf *default-indent
  :doc "Set global default indent size"
  :init
  (setq-default indent-tabs-mode nil)
  (setq-default tab-width 2)
  )
(leaf *global-settings
  :init
  (defalias 'yes-or-no-p 'y-or-n-p)
  :defvar kill-do-not-save-duplicates
  :custom ((kill-do-not-save-duplicates . t)
           (confirm-kill-emacs . 'y-or-n-p)))
(leaf *turncate
  :bind ("C-x t" . toggle-truncate-lines)
  :custom (truncate-lines . t)
  )
(leaf *trailing-white-space
  :doc "auto remove whitespace on the end line and"
  :url "https://tototoshi.hatenablog.com/entry/20101202/1291289625"
  :init
  (defvar my:delete-trailing-whitespace-exclude-suffix
    ;; ignore file types
    (list "\\.rd$" "\\.md$" "\\.rbt$" "\\.rab$"))
  (defun my:delete-trailing-whitespace ()
    (interactive)
    (eval-when-compile (require 'cl-lib nil t))
    (cond
     ((equal nil
             (cl-loop for pattern in my:delete-trailing-whitespace-exclude-suffix
                      thereis (string-match pattern buffer-file-name)))
      (delete-trailing-whitespace))))
  :hook (before-save-hook . my:delete-trailing-whitespace)
  )
(leaf *clipboard
  :doc "Bidirectional clipboard for mac"
  :if (eq system-type 'darwin)
  :config
  (defun copy-from-osx ()
    (shell-command-to-string "pbpaste"))

  (defun paste-to-osx (text &optional push)
    (let ((process-connection-type nil))
      (let ((proc (start-process "pbcopy" "*Messages*" "pbcopy")))
        (process-send-string proc text)
        (process-send-eof proc)))
    )

  (setq interprogram-cut-function 'paste-to-osx)
  (setq interprogram-paste-function 'copy-from-osx)
  )
(leaf *mouse
  :doc "Enable mouse"
  :config
  (xterm-mouse-mode t)
  (global-set-key [mouse-4] #'(lambda () (interactive) (scroll-down 3)))
  (global-set-key [mouse-5] #'(lambda () (interactive) (scroll-up   3)))
  )
(leaf *backup-file
  :doc "Disable create backup files"
  :init
  (setq create-lockfiles nil)
  (setq make-backup-files nil)
  (setq auto-save-default nil)
  )
(leaf *unset-keybinds
  :doc "Clear global keybinds"
  :bind (;;("C-h t" . nil) ;; tutorial
         ("C-h" . nil)
         ("C-\\" . nil) ;; change IME
         ("<F1> e" . nil) ;; show log
         ;; ("C-x C-c" . nil) ;; force kill emacs
         )
  )
(leaf *set-keybinds
  :doc "Set global keybinds"
  :bind (("C-w" . kill-ring-save)
         ("M-w" . kill-region)
         ("C-u" . scroll-down-command)
         ("C-h" . delete-backward-char))
  )
(leaf *set-aliases
  :init
  (defalias 'exit 'save-buffers-kill-emacs))
(leaf *reload-init
  :tag "function"
  :defun reload-initel
  :config
  (defun reload-init ()
    "Reload init.el"
    (interactive)
    (load-file "~/.emacs.d/init.el"))
  )
(leaf tab-line-mode
  :disabled t
  :doc "tab bar mode"
  :tag "builtin"
  :emacs>= "28"
  :global-minor-mode global-tab-line-mode
  :custom-face
  (tab-line-tab-inactive . '((t (:background "black" :foreground "white"))))
  (tab-line-tab-current  . '((t (:background "gray"  :foreground "black"))))
  :custom ((tab-line-new-button-show   . nil)
           (tab-line-close-button-show . nil)
           (tab-line-separator         . " | "))
  :bind (("<f11>" . tab-line-switch-to-prev-tab)
         ("<f12>" . tab-line-switch-to-next-tab))
  )
(leaf tabbar
  :doc "tab bar"
  :url "https://github.com/dholm/tabbar"
  :ensure t
  :defun (my/tabbar-buffer-list
          my/tabbar-buffer-groups
          projectile-project-name
          projectile-project-root)
  :custom ((tabbar-buffer-list-function   . 'my/tabbar-buffer-list)
           (tabbar-buffer-groups-function . 'my/tabbar-buffer-groups)
           (tabbar-use-images             . nil)
           (tabbar-separator . '(1))
           (tabbar-scroll-left-button . nil)
           (tabbar-scroll-right-button . nil)
           )

  :global-minor-mode t
  :bind (("<f11>" . tabbar-backward-tab)
         ("<f12>" . tabbar-forward-tab))
  :custom-face
  ((tabbar-unselected . '((t (:foreground "gray"))))
   (tabbar-selected   . '((t (:foreground "white")))))
  :init
  (defun my/tabbar-buffer-groups ()
    (list
     (cond
      ;; check project name by projectile.el
      ((projectile-project-name (projectile-project-root (buffer-file-name (current-buffer)))))
      ("default")
      )
     )
    )
  (defun my/tabbar-buffer-list ()
    (delq nil
          (mapcar #'(lambda (b)
                      (cond
                       ;; Always include the current buffer.
                       ((eq (current-buffer) b) b)
                       ((buffer-file-name b) b)
                       ((char-equal ?\  (aref (buffer-name b) 0)) nil)
                       ((eq "*terminal*" (buffer-name b)) b)
                       ((eq "*Python-Help*" (buffer-name b)) b)
                       ((string-match "flymake:?*" (buffer-name b)) nil)
                       ((char-equal ?* (aref (buffer-name b) 0)) nil) ; それ以外の * で始まるバッファは表示しない
                       ((buffer-live-p b) b)))
                  (buffer-list))))
  )
(leaf electric-pair-mode
  :doc "auto close section mark. ()/[]/「」..."
  :tag "builtin"
  :init
  (electric-pair-mode 1)
  )
(leaf *set-my-func
  :bind ("C-q" . one-line-comment)
  :init
  ;; Close all buffers
  (defun kill-all-buff ()
    (interactive)
    (mapc 'kill-buffer (buffer-list))
    )

  (defun one-line-comment ()
    (interactive)
    (save-excursion (beginning-of-line) (set-mark (point))
                    (end-of-line)
                    (comment-or-uncomment-region (region-beginning) (region-end))))
  )
(leaf show-paren-mode
  :tag "builtin"
  :config
  (show-paren-mode 1)
  :custom ((show-paren-delay . 0.0))
  )
(leaf doom-themes
  :ensure t
  :require t
  :if (eq system-type 'darwin)
  :custom ((doom-themes-enable-bold   . t)
           (doom-themes-enable-italic . t)
           (doom-themes-treemacs-theme . "doom-colors"))

  :config
  (load-theme 'doom-moonlight t)
  (doom-themes-treemacs-config)
  )
(leaf *fallback-theme
  :unless (eq system-type 'darwin)
  :tag "builtin"
  :init
  (load-theme 'wombat t)
  )
(leaf exec-path-from-shell
  :ensure t
  :custom (exec-path-from-shell-variables . '("PATH" "SHELL"))
  )
(leaf autorevert
  :doc "revert buffers when files on disk change"
  :tag "builtin"
  :custom ((auto-revert-interval . 1))
  :global-minor-mode global-auto-revert-mode
  )
(leaf golden-ratio
  :doc "Auto resize current paine"
  :ensure t
  :blackout t
  :defvar golden-ratio-exclude-buffer-names golden-ratio-exclude-buffer-regexp
  :global-minor-mode t
  :config
  (add-to-list 'golden-ratio-exclude-buffer-names "*NeoTree*")
  (add-to-list 'golden-ratio-exclude-buffer-regexp "\*ediff.*")
  (add-to-list 'golden-ratio-exclude-buffer-regexp ".*UPPER=.*")
  (add-to-list 'golden-ratio-exclude-buffer-regexp ".*LOWER=.*")
  )
(leaf *window-keybinds
  :doc "Set window global key binds"
  :init
  :bind(("C-d"         . nil)
        ("C-d |"       . split-window-right)
        ("C-d -"       . split-window-below)
        ("C-d x"       . delete-window)
        ("C-d <left>"  . windmove-left)
        ("C-d <down>"  . windmove-down)
        ("C-d <up>"    . windmove-up)
        ("C-d <right>" . windmove-right))
  )
(leaf bind-key :ensure t)
(leaf *enable-minor-mode
  :url "https://github.com/prettier/prettier-emacs"
  :doc "set hook minor-mode for mmm-mode, web-mode and more."
  :init
  (defun enable-minor-mode (my-pair)
    "Enable minor mode if filename match the regexp.  MY-PAIR is a cons cell (regexp . minor-mode)."
    (if (buffer-file-name)
        (if (string-match (car my-pair) buffer-file-name)
            (funcall (cdr my-pair)))))
  )
(leaf visual-regexp-steroids
  :ensure t
  :require t
  :url "https://github.com/benma/visual-regexp-steroids.el/"
  :bind (("C-r" . vr/query-replace))
  )
(leaf session
  :ensure t
  :hook (after-init-hook . session-initialize))
;; ======== editor global package ==========
(leaf neotree
  :doc "cui tree filer"
  :ensure t
  :bind (("C-o" . neotree-toggle)
         (neotree-mode-map ("<left>"  . neotree-select-up-node)
                           ("<right>" . neotree-change-root))
         )
  :custom ((neo-show-hidden-files     . t)
           (neo-create-file-auto-open . t)
           (neo-theme                 . 'arrow)
           (neo-keymap-style          . 'concise))
  )
(leaf company
  :ensure t
  :doc "Modular text completion framework"
  :req "emacs-24.3"
  :tag "matching" "convenience" "abbrev" "emacs>=24.3"
  :url "http://company-mode.github.io/"
  :global-minor-mode global-company-mode
  :custom ((company-auto-expand           . t)
           (company-transformers          . '(company-sort-by-backend-importance))
           (company-idle-delay            . 0.1)
           (company-minimum-prefix-length . 2)
           (company-selection-wrap-around . t)
           (completion-ignore-case        . t)
           (company-dabbrev-downcase      . nil))
  :bind ("TAB" . company-indent-or-complete-common)
  ;; :config
  ;; (defvar company-mode/enable-yas t
  ;;  "Enable yasnippet for all backends.")
  ;; (defun company-mode/backend-with-yas (backend)
  ;;  (if (or (not company-mode/enable-yas) (and (listp backend) (member 'company-yasnippet backend)))
  ;;      backend
  ;;    (append (if (consp backend) backend (list backend))
  ;;            '(:with company-yasnippet))))
  ;; (setq company-backends (mapcar #'company-mode/backend-with-yas company-backends))
  )
(leaf ivy
  :doc "Incremental Vertical completYon"
  :req "emacs-24.5"
  :tag "matching" "emacs>=24.5"
  :url "https://github.com/abo-abo/swiper"
  :emacs>= 24.5
  :ensure t
  :blackout t
  :leaf-defer nil
  :custom ((ivy-initial-inputs-alist  . nil)
           (ivy-use-selectable-prompt . t)
           (ivy-wrap                  . t))
  :custom-face ((ivy-current-match           . '((t (:background "#404040" :distant-foreground "#abb2bf"))))
                (ivy-minibuffer-match-face-1 . '((t (:foreground "#999999"))))
                (ivy-minibuffer-match-face-2 . '((t (:foreground "#e04444" :underline t))))
                (ivy-minibuffer-match-face-3 . '((t (:foreground "#7777ff" :underline t))))
                (ivy-minibuffer-match-face-4 . '((t (:foreground "#33bb33" :underline t)))))
  :global-minor-mode t
  :config
  (leaf swiper
    :doc "Isearch with an overview. Oh, man!"
    :req "emacs-24.5" "ivy-0.13.0"
    :tag "matching" "emacs>=24.5"
    :url "https://github.com/abo-abo/swiper"
    :emacs>= 24.5
    :ensure t
    :bind (("C-s" . swiper))
    )
  (leaf counsel
    :doc "Various completion functions using Ivy"
    :req "emacs-24.5" "swiper-0.13.0"
    :tag "tools" "matching" "convenience" "emacs>=24.5"
    :url "https://github.com/abo-abo/swiper"
    :emacs>= 24.5
    :ensure t
    :bind (("M-y" . counsel-yank-pop)
           ("M-s" . counsel-ag))
    :blackout t
    :custom ((counsel-find-file-ignore-regexp . ,(rx-to-string '(or "./" "../") 'no-group)))
    :global-minor-mode t
    )
  )
(leaf prescient
  :doc "Better sorting and filtering"
  :req "emacs-25.1"
  :tag "extensions" "emacs>=25.1"
  :url "https://github.com/raxod502/prescient.el"
  :emacs>= 25.1
  :ensure t
  :custom ((prescient-aggressive-file-save . t))
  :global-minor-mode prescient-persist-mode)
(leaf ivy-prescient
  :doc "prescient.el + Ivy"
  :req "emacs-25.1" "prescient-4.0" "ivy-0.11.0"
  :tag "extensions" "emacs>=25.1"
  :url "https://github.com/raxod502/prescient.el"
  :emacs>= 25.1
  :ensure t
  :after prescient ivy
  :custom ((ivy-prescient-retain-classic-highlighting . t))
  :global-minor-mode t)
(leaf flycheck
  :doc "On-the-fly syntax checking"
  :req "dash-2.12.1" "pkg-info-0.4" "let-alist-1.0.4" "seq-1.11" "emacs-24.3"
  :tag "minor-mode" "tools" "languages" "convenience" "emacs>=24.3"
  :url "http://www.flycheck.org"
  :emacs>= 24.3
  :ensure t
  :defun flycheck-list-errors
  :bind (("<f6>" . my/toggle-flycheck-error-buffer)
         ("<f4>" . flycheck-previous-error)
         ("<f5>" . flycheck-next-error))
  :global-minor-mode global-flycheck-mode
  :defun my/toggle-flycheck-error-buffer
  :custom ((flycheck-indication-mode . 'left-margin))
  :custom-face ((flycheck-error-list-highlight . '((t (:background "#223022")))))
  :hook (flycheck-mode-hook . flycheck-set-indication-mode)
  :config
  (defun my/toggle-flycheck-error-buffer ()
    "Flycheck list error mini buffer toggle."
    (interactive)
    (if (string-match-p "Flycheck errors" (format "%s" (window-list)))
        (dolist (w (window-list))
          (when (string-match-p "*Flycheck errors*" (buffer-name (window-buffer w)))
            (delete-window w)))
      (flycheck-list-errors))
    )
  (add-to-list 'display-buffer-alist `(,(rx bos "*Flycheck errors*" eos)
                                       (display-buffer-reuse-window display-buffer-in-side-window)
                                       (side . bottom)
                                       (reusable-frames . visible)
                                       (window-height   . 0.33)
                                       ))
  )
(leaf format-all
  :doc "code foramtter on hook the file save"
  :url "https://github.com/lassik/emacs-format-all-the-code"
  :ensure t
  :config
  (add-to-list 'display-buffer-alist `(,(rx bos "*format-all-errors*" eos)
                                       (display-buffer-reuse-window display-buffer-in-side-window)
                                       (side . bottom)
                                       (reusable-frames . visible)
                                       (window-height   . 0.33)
                                       ))
  )
(leaf git-gutter
  :doc "show status of code changes on slide gutter"
  :ensure t
  :require t
  :blackout t
  :global-minor-mode global-git-gutter-mode
  :custom (
           (git-gutter:update-interval . 2)
           (git-gutter:window-width . 2)
           (git-gutter:update-interval . 2)
           (git-gutter:added-sign . "+")
           (git-gutter:deleted-sign . "-")
           (git-gutter:modified-sign . "M"))
  :custom-face  ((git-gutter:added    . '((t (:background "#abf455" :foreground "#010101"))))
                 (git-gutter:deleted  . '((t (:background "#f7465f"   :foreground "#010101"))))
                 (git-gutter:modified . '((t (:background "#1f6feb"  :foreground "#010101")))))
  )
(leaf undo-tree
  :doc "extended redo/undo"
  :blackout t
  :ensure t
  :global-minor-mode global-undo-tree-mode
  :bind (("M-/" . undo-tree-redo)
         ("C-/" . undo-tree-undo))
  )
(leaf powerline
  :doc "power up mode line"
  :ensure t
  :defun powerline-reset
  :config
  (powerline-default-theme)
  )
(leaf airline-themes
  :el-get (airline-themes
           :type git
           :url "https://github.com/magcho/airline-themes.git")
  :require t
  :config
  (load-theme 'airline-kolor t))
(leaf yasnippet
  :doc "code snippet tool"
  :ensure t
  :blackout t
  :global-minor-mode yas-global-mode
  :custom (yas-snippet-dirs . '("~/.config/emacs/my-yasnippet-snippets"
                                "~/.config/emacs/yasnippet-snippets/snippets"
                                "~/.config/emacs/yasnippet-golang"))
  )
(leaf cua-mode
  :doc "block select region"
  :tag "builtin"
  :custom (cua-enable-cua-keys . nil)
  :bind ("M-RET" . cua-set-rectangle-mark)
  :global-minor-mode t
  )
(leaf projectile
  :ensure t
  :global-minor-mode t
  :defvar projectile-globally-ignored-directories
  :config
  (add-to-list 'projectile-globally-ignored-directories '("dist" "dest"))
  (leaf counsel-projectile
    :ensure t
    :bind ("C-f" . counsel-projectile-find-file)
    )
  )
(leaf find-file-in-project
  :disabled t
  :doc "file jump"
  :ensure t
  :bind ("C-f" . find-file-in-project)
  :defvar ffip-prune-patterns
  :config
  (add-to-list 'ffip-prune-patterns "*/node_modules/*")
  (add-to-list 'ffip-prune-patterns "*/dist/*")
  (add-to-list 'ffip-prune-patterns "*/dest/*")
  (add-to-list 'ffip-prune-patterns "*/vendor/*")
  )
(leaf eldoc
  :doc "show function description"
  :tag "buildin"
  :blackout t
  )
(leaf jaword
  :ensure t
  :doc "word morphological support for japanese"
  :url "https://github.com/zk-phi/jaword"
  :global-minor-mode global-jaword-mode)
(leaf magit
  :ensure t
  :config
  (leaf forge
    :ensure t
    :after magit
    :custom ((github.user . "magcho")
             (auth-sources . '("~/.config/forge/.github-authinfo")))
    ))

(leaf ace-jump-mode
  :ensure t
  :bind (("M-j" . ace-jump-word-mode)))
;; ======== common minor mode  ========
(leaf lsp-mode
  :ensure t
  :commands lsp
  :init
  ;; (setq gc-cons-threshold 100000000) ;; 100mb
  ;; (setq read-process-output-max (* 1024 1024)) ;; 1mb
  :config
  (leaf lsp-ui
    :if (not (eq system-type 'windows))
    :ensure t
    :hook lsp-mode-hook
    )
  (leaf all-the-icons
    :ensure t)
  (leaf dap-mode :ensure t)
  ;; (define-key lsp-ui-mode-map [remap xref-find-definitions] #'lsp-ui-peek-find-definitions)
  ;; (define-key lsp-ui-mode-map [remap xref-find-references] #'lsp-ui-peek-find-references)
  :custom ((lsp-prefer-capf . t)
           (lsp-headerline-breadcrumb-enable . nil)
           (lsp-ui-peek-enable . t))
  :bind (("<f9>" . lsp-execute-code-action))
  )
(leaf tide
  :ensure t
  :defvar flycheck-check-syntax-automatically
  :after (flycheck eldoc company-mode)
  :commands setup-tide-mode
  :init
  (defun setup-tide-mode ()
    (interactive)
    (tide-setup)
    (flycheck-mode +1)
    (setq flycheck-check-syntax-automatically '(save mode-enabled))
    (eldoc-mode +1)
    (tide-hl-identifier-mode +1)
    (company-mode +1))
  )
(leaf prettier-js
  :ensure t
  :url "https://github.com/prettier/prettier-emacs"
  )
;; ======== language mode settings ========
(leaf lisp-mode
  :doc "EmacsLisp major mode"
  :config
  (leaf hs-minor-mode
    :doc "expand and close code block"
    :tag "builtin"
    :init (define-global-minor-mode global-hs-minor-mode hs-minor-mode hs-minor-mode)
    :hook (emacs-lisp-mode-hook . hs-minor-mode)
    :bind (("C-p" . hs-toggle-hiding)
           ("M-p" . hs-hide-all))
    )
  (leaf rainbow-delimiters
    :ensure t
    :hook emacs-lisp-mode-hook)
  (leaf auto-async-byte-compile
    :disabled t
    :ensure t
    :hook (emacs-lisp-mode-hook . enable-auto-async-byte-compile-mode)
    )
  )
(leaf arduino-mode
  :doc "C++ for Arduino(.ino) major mode"
  :url "https://github.com/stardiviner/arduino-mode"
  :ensure t
  :hook (arduino-mode-hook . flycheck-arduino-setup)
  )
(leaf cc-mode
  :doc "C C++ major mode"
  :tag "builtin"
  :hook ((c-mode-hook   . format-all-mode)
         (c++-mode-hook . format-all-mode))
  )
(leaf css-mode
  :doc "CSS major mode"
  :tag "builtin"
  :hook (css-mode-hook . lsp)
  )
(leaf docker-compose-mode
  :doc "docker-compose.yml major mode"
  :ensure t
  )
(leaf dockerfile-mode
  :doc "dockerfile major mode"
  :ensure t
  )
(leaf go-mode
  :disabled t
  :doc "Golang major mode"
  :url "https://qiita.com/kod314/items/2232d480411c5c2ab002"
  :ensure t
  :config
  (leaf lsp-mode
    :hook (go-mode-hook . lsp)
    )
  )
(leaf java-mode
  :doc "java major mode"
  :tag "builtin"
  :hook ((java-mode-hook . format-all-mode)
         (java-mode-hook . lsp))
  :config
  (leaf lsp-java :ensure t )
  )
(leaf js-mode
  :doc "javascript major mode"
  :tag "builtin"
  :hook ((js-mode-hook . format-all-mode)
         (js-mode-hook . lsp))
  :custom ((javascript-indentation . 2)
           (js-indent-level        . 2)
           (js-jsx-indent-level    . 2)
           (js-jsx-syntax          . t))
  :config
  (leaf lsp-mode
    :defvar lsp-file-watch-ignored
    :init
    (setq-local lsp-enabled-clients '(ts-ls eslint))
    :config
    (add-to-list lsp-file-watch-ignored '("[/\\\\]dist\\'" "[/\\\\]dest\\'"))
    )
  (leaf add-node-modules-path
    :ensure t
    :hook js-mode-hook
    )
  )
(leaf typescript-mode
  :ensure t
  :mode "\\.ts\\'"
  :custom (typescript-indent-level . 2)
  :hook ((typescript-mode-hook . format-all-mode)
         (typescript-mode-hook . lsp))
  :config
  (leaf add-node-modules-path
    :ensure t
    :hook (typescript-mode-hook . add-node-modules-path))
  )
(leaf *tsx
  :doc "typescript tsx"
  :defvar flycheck-check-syntax-automatically
  :config
  (leaf web-mode
    :ensure t
    :url "https://web-mode.org/"
    :mode "\\.tsx\\'"
    :defun (enable-minor-mode web-mode-reload)
    :hook ((web-mode-hook    . prettier-js-mode)
           (web-mode-on-after-save . web-mode-reload))
    :custom ((web-mode-markup-indent-offset . 2)
             (web-mode-css-indent-offset    . 2)
             (web-mode-code-indent-offset   . 2)
             (web-mode-code-indent-offset   . 2))
    :config
    (leaf tide
      :tag "configure"
      :defun (setup-tide-mode flycheck-add-mode)
      :hook ((web-mode-hook . (lambda ()
                                (when (string-equal "tsx" (file-name-extension buffer-file-name))
                                  (progn
                                    (tide-setup)
                                    (flycheck-mode +1)
                                    (setq flycheck-check-syntax-automatically '(save mode-enabled))
                                    (eldoc-mode +1)
                                    (tide-hl-identifier-mode +1)
                                    (company-mode +1))))))
      :custom ((company-tooltip-align-annotations . t)
               (tide-completion-ignore-case       . t))
      :config
      (flycheck-add-mode 'typescript-tslint 'web-mode)
      )
    )
  )
(leaf *jsx
  :doc "javascript jsx"
  :defvar flycheck-check-syntax-automatically
  :config
  (leaf web-mode
    :ensure t
    :url "https://web-mode.org/"
    :mode "\\.jsx\\'"
    :custom ((web-mode-markup-indent-offset . 2)
             (web-mode-css-indent-offset    . 2)
             (web-mode-code-indent-offset   . 2)
             (web-mode-code-indent-offset   . 2))
    :config
    (leaf tide
      :tag "configure"
      :defun (flycheck-add-mode flycheck-add-next-checker)
      :hook ((web-mode-hook . (enable-minor-mode '("\\.jsx?\\'" . prettier-js-mode)))
             (web-mode-hook . (lambda ()
                                (when (string-equal "jsx" (file-name-extension buffer-file-name))
                                  (progn
                                    (tide-setup)
                                    (flycheck-mode +1)
                                    (setq flycheck-check-syntax-automatically '(save mode-enabled))
                                    (eldoc-mode +1)
                                    (tide-hl-identifier-mode +1)
                                    (company-mode +1))))))

      :custom ((company-tooltip-align-annotations . t)
               (tide-completion-ignore-case       . t))
      :config
      (flycheck-add-mode 'javascript-eslint 'web-mode)
      (flycheck-add-next-checker 'javascript-eslint 'jsx-tide 'append)
      )
    )
  )
(leaf tex-mode
  :doc "LaTex major mode"
  :req "brew install texlab"
  :tag "builtin"
  :hook (tex-mode-hook . lsp)
  )
(leaf markdown-mode
  :doc "markdown major mode"
  :url "https://jblevins.org/projects/markdown-mode/"
  :ensure t
  :custom (markdown-fontify-code-blocks-natively . t)
  :mode (("README\\.md\\'" . gfm-mode))
  )
(leaf mermaid-mode
  :doc "marmaid major mode"
  :ensure t
  :mode "\\.mmd\\'"
  )
(leaf php-mode
  :doc "php major mode"
  :ensure t
  :hook (php-mode-hook . lsp)
  :bind(("C-d"         . nil)
        ("C-d |"       . split-window-right)
        ("C-d -"       . split-window-below)
        ("C-d x"       . delete-window)
        ("C-d <left>"  . windmove-left)
        ("C-d <down>"  . windmove-down)
        ("C-d <up>"    . windmove-up)
        ("C-d <right>" . windmove-right))
  :config
  (leaf *lsp-ignore-setting
    :defvar lsp-file-watch-ignored
    :after lsp
    :config
    (add-to-list lsp-file-watch-ignored '("[/\\\\]vendor\\'")))
  )
(leaf python-mode
  :tag "builtin"
  :hook ((python-mode-hook . python-black-on-save-mode)
         (python-mode-hook . pyenv-mode)
         (python-mode-hook . indent-guide-mode)
         (python-mode-hook . lsp))
  :init
  (leaf indent-guide
    :ensure t
    :blackout t)
  (leaf pyenv-mode :ensure t)
  (leaf python-black
    :ensure t
    :blackout t)
  )
(leaf ruby-mode
  :tag "bultin"
  :hook (ruby-mode-hook . format-all-mode)
  )
(leaf dotenv-mode
  :ensure t
  :url "https://github.com/preetpalS/emacs-dotenv-mode"
  )
(leaf vimrc-mode :ensure t)
(leaf go-mode
  :ensure t)
(leaf nginx-mode
  :ensure t)
(leaf terraform-mode
  :doc "terraform major mode"
  :ensure t
  :config
  (leaf lsp-mode
    :url "https://github.com/hashicorp/terraform-ls"
    :hook (terraform-mode-hook . lsp))
  :hook (terraform-mode-hook . format-all-mode)
  )
(leaf vue-mode
  :doc "vue major mode"
  :ensure t
  :custom ((mmm-submode-decoration-level . 0))
  :hook ((vue-mode-hook . add-node-modules-path)
         (vue-mode-hook . lsp)
         (vue-mode-hook . prettier-js-mode)
         )
  :config
  (leaf add-node-modules-path
    :ensure t)
  )
(leaf emacs-prisma-mode
  :doc "prisma orm mode"
  :el-get (emacs-prisma-mode
           :type git
           :url "https://github.com/pimeys/emacs-prisma-mode.git")
  )
(leaf *scala
  :config
  (leaf lsp-metals
    :ensure t)
  (leaf scala-mode
    :doc "scala language major mode"
    :ensure t
    :hook ((scala-mode-hook . lsp)
           (scala-mode-hook . lsp))
    )
  (leaf sbt-mode
    :ensure t
    :commands sbt-start sbt-command
    :custom ((sbt:program-options . "-Dsbt.supershell=false"))
    )
  )
(leaf *rust
  :config
  (add-to-list 'exec-path (expand-file-name "/usr/local/bin/rust-analyzer"))
  (add-to-list 'exec-path (expand-file-name "~/.cargo/bin"))
  (leaf rust-mode
    :doc "rust language major mode"
    :ensure t
    :defvar rust-mode-map
    :custom ((rust-format-on-save . t)
             (lsp-rust-server . 'rust-analyzer))
    :config
    (define-key rust-mode-map (kbd "C-c C-c") 'rust-run)
    :hook ((rust-mode . lsp))
    )
  (leaf flycheck-rust
    :ensure t
    :hook ((flycheck-mode-hook . flycheck-rust-setup)))
  )
(leaf gitconfig-mode
  :ensure t)
(leaf homebrew-mode
  :ensure t
  )
;;; init.el ends here
