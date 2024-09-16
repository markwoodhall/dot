(setq gc-cons-threshold 5002653184
      gc-cons-percentage 0.6)

(setq vc-follow-symlinks t)
(org-babel-load-file
 (expand-file-name
  "emacs.org"
  user-emacs-directory))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(helm-minibuffer-history-key "M-p")
 '(package-selected-packages
   '(fennel-mode yasnippet evil-surround evil-goggles flycheck-kotlin smex git-gutter pandoc-mode feature-mode ws-butler exwm yaml dockerfile-mode docker org-roam-dailies org-roam undo-tree helm-icons smartparens highlight-indent-guides rainbow-delimiters paredit helm-xref kind-icon helm-lsp ivy-xref counsel-cider lsp-treemacs company flycheck lsp-mode helm-cider helm cider writeroom-mode which-key doom-themes vterm eshell-syntax-highlighting projectile perspective toc-org use-package sudo-edit peep-dired general gcmh evil-tutor evil-collection emojify elfeed-goodies dired-open dashboard all-the-icons-dired))
 '(warning-suppress-log-types '((comp))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
