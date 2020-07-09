;;; init.el --- Meetup Urfist 7 & 9 juillet 2020

;;; Commentary:
;; Exemple de fichier d'initialisation pour Emacs 26.3.
;; Des adaptations sont peut-être à faire pour la sortie
;; d'Emacs 27, prévue au mois de septembre 2020.

;;; Code :
;;; PACKAGES :
(package-initialize)
;; Choix et priorité des dépôts :
(add-to-list 'package-archives
	     '("melpa-stable" . "http://stable.melpa.org/packages/"))
(add-to-list 'package-archives
	     '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives
	     '("org" . "https://orgmode.org/elpa/") t)
(setq package-archive-priorities '(("gnu" . 5)
                                   ("melpa" . 10)
                                   ("org" . 11)
                                   ("melpa-stable" . 6)))

;; Utilisation de use-package :
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile
  (require 'use-package))

;;; APPARENCE :
;; Désactiver l'écran d'accueil :
(setq inhibit-splash-screen t)

;; Affichage du nombre de lignes et de colonnes dans la "modeline":
(line-number-mode t)
(column-number-mode t)

;; Affichage des numéros de ligne dans la marge de gauche :
(global-display-line-numbers-mode)

;; Thème solarized :
(use-package solarized-theme
  :ensure t
  :config
  (setq solarized-distinct-fringe-background t)
  (setq solarized-use-variable-pitch nil)
  (setq solarized-scale-org-headlines nil)
  (load-theme 'solarized-light t))

;;; GÉNÉRALITÉS :
;; Refonte de la commande kill-buffer :
(require 'misc-cmds)
(substitute-key-definition 'kill-buffer 'kill-buffer-and-its-windows global-map)

;; Utilisation de l'encodage UTF-8 :
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

;; Activer le mode de suppression de la région active :
(delete-selection-mode 1)

;; Réglages pour les parenthèses correspondantes :
(use-package paren
  :ensure t
  :config
  (setq show-paren-delay 0)
  (show-paren-mode 1))

;; Mettre en surbrillance la ligne active :
(use-package hl-line
  :ensure t
  :config
  (global-hl-line-mode 1))

;; Line wrapping :
(setq-default word-wrap t)
(toggle-truncate-lines -1)
(setq longlines-wrap-follows-window-size t)

;; Backups automatiques :
(setq backup-directory-alist
          `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
          `((".*" , temporary-file-directory t)))

;; Ajout de dictionnaires :
(let ((langs '("american" "british" "francais")))
  (setq lang-ring (make-ring (length langs)))
  (dolist (elem langs) (ring-insert lang-ring elem)))
(defun cycle-ispell-languages ()
  (interactive)
  (let ((lang (ring-ref lang-ring -1)))
    (ring-insert lang-ring lang)
    (ispell-change-dictionary lang)))
(global-set-key [f6] 'cycle-ispell-languages)

;; Vérification orthographique en mode texte :
(add-hook 'text-mode-hook 'flyspell-mode)

;; CHARGER ET CONFIGURER ESS POUR L'UTILISATION DE R :
;; Réglages ESS:
(use-package ess
  :ensure t
  :init
  (require 'ess-site)
  :config
  ;; Evaluation visible du code dans le buffer iESS :
  (setq ess-eval-visibly t)
  ;; Configurer la disposition des buffers en mode ESS[R] :
  (setq display-buffer-alist '(("*R Dired"
				(display-buffer-reuse-window display-buffer-at-bottom)
				(window-width . 0.5)
				(window-height . 0.25)
				(reusable-frames . nil))
			       ("*R"
				(display-buffer-reuse-window display-buffer-in-side-window)
				(side . right)
				(slot . -1)
				(window-width . 0.5)
				(reusable-frames . nil))
			       ("*Help"
				(display-buffer-reuse-window display-buffer-in-side-window)
				(side . right)
				(slot . 1)
				(window-width . 0.5)
				(reusable-frames . nil))))
  ;; Supprimer Flymake (sera remplacé par Flycheck plus bas dans le script) :
  (setq ess-use-flymake nil)
  ;; Raccourci (touche F9) pour ouvrir ou fermer la fenêtre de l'explorateur d'objets R (ess-r-mode) :
  (add-hook 'ess-r-mode-hook
	    '(lambda ()
	       (local-set-key (kbd "<f9>") #'ess-rdired)))
  (add-hook 'ess-rdired-mode-hook
	    '(lambda ()
	       (local-set-key (kbd "<f9>") #'kill-buffer-and-window)))
  ;; Raccourci pour les boites de commentaires R :
  (add-hook 'ess-r-mode-hook
	    '(lambda ()
	       (local-set-key (kbd "\C-cb") #'comment-box-line)))
  ;; Personnaliser la coloration syntaxique :
  (setq ess-R-font-lock-keywords '((ess-R-fl-keyword:keywords . t)
				   (ess-R-fl-keyword:constants . t)
				   (ess-R-fl-keyword:modifiers . t)
				   (ess-R-fl-keyword:fun-defs . t)
				   (ess-R-fl-keyword:assign-ops . t)
				   (ess-R-fl-keyword:%op% . t)
				   (ess-fl-keyword:fun-calls . t)
				   (ess-fl-keyword:numbers . t)
				   (ess-fl-keyword:operators)
				   (ess-fl-keyword:delimiters)
				   (ess-fl-keyword:=)
				   (ess-R-fl-keyword:F&T . t))))

;; PYHTON :
;; Réglages pour Python via le major mode Elpy :
(use-package elpy
  :ensure t
  :init
  (elpy-enable)
  :config
  (remove-hook 'elpy-modules 'elpy-module-flymake)
  (setq python-indent-offset 4) ;; inutile, est déjà la valeur par défaut
  (setq python-shell-interpreter "ipython"
	python-shell-interpreter-args "-i --simple-prompt")
  (setq python-shell-completion-native-enable nil)
  (setq elpy-get-info-from-shell t))

(use-package exec-path-from-shell
  :ensure t
  :config
  (exec-path-from-shell-initialize)
  (exec-path-from-shell-copy-env "PYTHONPATH"))

;; Réglages pour autopep8 (corrections à la volée d'erreurs syntaxiques Python) :
(use-package py-autopep8
  :ensure t
  :after elpy
  :config
  (add-hook 'python-mode-hook 'py-autopep8-enable-on-save)
  (add-hook 'elpy-mode-hook 'py-autopep8-enable-on-save))

;; EMACS LISP :
(add-hook 'emacs-lisp-mode-hook 'electric-pair-local-mode)

(defun disable-tabs ()
  (setq indent-tabs-mode nil))
;; Hooks to Disable Tabs
(add-hook 'lisp-mode-hook 'disable-tabs)
(add-hook 'emacs-lisp-mode-hook 'disable-tabs)

;; FONCTIONNALITÉS GÉNÉRALES D'ÉDITION DE CODE :
;; Autocomplétion avec company :
(use-package company
  :ensure t
  :config
  ;; Activer company globalement (y compris ESS), sauf org-mode :
  (add-hook 'after-init-hook 'global-company-mode)
  (setq company-global-modes '(not org-mode text-mode))
  (setq ess-use-company 'script-only)
  ;; Redéfinier certains raccourcis en accord avec le Wiki de company :
  (define-key company-active-map (kbd "M-n") nil)
  (define-key company-active-map (kbd "M-p") nil)
  (define-key company-active-map (kbd "M-,") 'company-select-next)
  (define-key company-active-map (kbd "M-k") 'company-select-previous)
  (define-key company-active-map [return] nil)
  (define-key company-active-map [tab] 'company-complete-common)
  (define-key company-active-map (kbd "TAB") 'company-complete-common)
  (define-key company-active-map (kbd "M-TAB") 'company-complete-selection)
  (setq company-selection-wrap-around t
	company-tooltip-align-annotations t
	company-idle-delay 0.45
	company-minimum-prefix-length 2
	company-tooltip-limit 10)
  ;; Associer la touche F12 à l'auto-complétion des arguments des fonctions R (raccourci valable en mode ESS) :
  (add-hook 'ess-r-mode-hook
	    '(lambda ()
	       (local-set-key (kbd "<f12>") #'company-R-args))))

;; Activer les info-bulles d'aide Company pour les fonctions :
(use-package company-quickhelp
  :ensure t
  :config
  (company-quickhelp-mode))

;; Vérification à la volée avec Flycheck (activation pour tous les modes) :
(use-package flycheck
  :ensure t
  :init
  (global-flycheck-mode t))

;;; ORG :
;; Configuration de Org-mode :
(use-package org
  :ensure t
  :init
  (defun turn-on-visual-line-mode () (visual-line-mode 1)) ;; fonction Lisp utile ci-dessous
  :config
  (require 'org-tempo)
  (require 'ox-latex)	    ; export LaTeX
  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; 1. Configuration générale de Org-mode :
  ;; Apparence générale d'un document Org :
  (setq org-hide-leading-stars nil)  ;; ne pas cacher les "*" supplémentaires des sous-sections
  (setq org-alphabetical-lists t)
  (setq org-src-fontify-natively t)  ;; activer la coloration syntaxique au sein des blocs
  (setq org-src-tab-acts-natively t) ;; activer la complétion au sein des blocs
  (setq org-pretty-entities t)       ;; permet d'avoir des caractères spéciaux (\alpha, ...)
  (add-hook 'org-mode-hook 'turn-on-visual-line-mode) ;; activer le mode visual-line en org-mode
  ;; Gestion des TODO listes :
  (setq org-todo-keywords ;; nouveaux statuts
      '((sequence "TODO(t)" "IN-PROGRESS(p)" "SOMEDAY(s)" "WAITING(w@)" "|" "DONE(d)" "CANCELED(c@)")))
  (setq org-todo-keyword-faces ;; couleurs associées
	'(("TODO" . "red3")
          ("IN-PROGRESS" . "DarkOrange2")
          ("SOMEDAY" . "blue")
          ("WAITING" . "gold2")
	  ("CANCELED" . "thistle4")
          ("DONE" . "forest green")))
  (setq org-enforce-todo-dependencies t) ;; tâches mères et filles
  ;; Drawers et logging :
  (setq org-log-into-drawer t) ;; ajouter les notes dans un drawer "LOGBOOK". Voir la vidéo de Rainer : https://www.youtube.com/watch?v=nUvdddKZQzs&list=PLVtKhBrRV_ZkPnBtt_TD1Cs9PJlU0IIdE&index=9
  (setq org-log-done 'time) ;; ajout d'un timestamp à la fermeture d'une tâche. Voir la vidéo de Rainer : https://www.youtube.com/watch?v=R4QSTDco_w8&list=PLVtKhBrRV_ZkPnBtt_TD1Cs9PJlU0IIdE&index=11
  (setq org-log-reschedule 'note) ;; ajout d'une note lorsqu'on replanifie une tâche
  (setq org-clock-into-drawer "CLOCKING") ;; clocking info placée dans un drawer nommé "CLOCKING"
  ;; Réglages pour l'export LaTeX :
  (setq org-export-with-smart-quotes t) ;; de jolis guillemets français par défaut (avec babel !)
  (setq org-latex-caption-above nil) ;; les légendes sont à positionner au-dessous des flottants
  (require 'ox-beamer) ;; activer le support de beamer
  (defun my-beamer-bold (contents backend info)
    (when (eq backend 'beamer)
      (replace-regexp-in-string "\\`\\\\[A-Za-z0-9]+" "\\\\textbf" contents)))
  (add-to-list 'org-export-filter-bold-functions 'my-beamer-bold)
  ;; Ajout de classes LaTeX spécifiques aux éditeurs scientifiques :
  (add-to-list 'org-latex-classes
	       '("elsarticle"
		 "\\documentclass{elsarticle}"
		 ("\\section{%s}" . "\\section*{%s}")
		 ("\\subsection{%s}" . "\\subsection*{%s}")
		 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")))
  (add-to-list 'org-latex-classes
	       '("WileyNJD-v2"
		 "\\documentclass{WileyNJD-V2}"
		 ("\\section{%s}" . "\\section*{%s}")
		 ("\\subsection{%s}" . "\\subsection*{%s}")
		 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")))
  (add-to-list 'org-latex-classes
	       '("krantz"
		 "\\documentclass{krantz}"
		 ("\\part{%s}" . "\\part*{%s}")
		 ("\\chapter{%s}" . "\\chapter*{%s}")
		 ("\\section{%s}" . "\\section*{%s}")
		 ("\\subsection{%s}" . "\\subsection*{%s}")
		 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")))
  ;; Réglages pour org-capture :
  (global-set-key (kbd "C-c c") 'org-capture) ;; keybinding suggéré par le manuel
  
  ;; ;;;;;;;;;;;;;;;;;;;;;;;
  ;; 2. Réglages Org Babel :
  ;; Langages reconnus par défaut :
  (org-babel-do-load-languages
   'org-babel-load-languages
   '(
     (ein . t)
     (emacs-lisp . t)
     (ipython . t)
     (julia . t)
     (latex . t)
     (makefile . t)
     (octave . t)
     (org . t)
     (python . t)
     (R . t)
     (shell . t)))
  ;; Évaluation silencieuse des chunks :
  (setq org-confirm-babel-evaluate nil)
  ;; Préservation de l'indentation lors de l'export :
  (setq org-src-preserve-indentation t)
  ;; Ne pas ajouter d'identation systématique au code (gênant en Python) :
  (setq org-edit-src-content-indentation 0)
  ;; De nouveaux raccourcis clavier et blocs de code pour Org-mode avec R :
  (add-to-list 'org-structure-template-alist
	       '("r" . "src R :results output :session *R* :exports both"))
  (add-to-list 'org-structure-template-alist
	       '("rfig" . "src R :results graphics file :file FILENAME.png :exports both :width 600 :height 400 :session *R*"))
  (add-to-list 'org-structure-template-alist
	       '("rtab" . "src R :results value table :colnames yes :rownames yes :session *R* :exports both"))
  ;; De nouveaux raccourcis clavier et blocs de code pour Org-mode avec Python, iPython & Jupyter :
  (add-to-list 'org-structure-template-alist
	       '("p" . "src python :results output :session :exports both"))
  (add-to-list 'org-structure-template-alist
	       '("ip" . "src ipython :results output :session ip1 :exports both"))
  (add-to-list 'org-structure-template-alist
	       '("pfig" . "src python :results file :session :exports both :var plot_filename='FILENAME.png'\nimport matplotlib.pyplot as plt\n\nplt.savefig(plot_filename)\nplot_filename"))
  (add-to-list 'org-structure-template-alist
	       '("einp" . "src ein-python :results output :session localhost :exports both"))
  ;; Un raccourci clavier pour les blocs de code emacs-lisp (dont un pour générer init.el) :
  (add-to-list 'org-structure-template-alist
	       '("el" . "src emacs-lisp :results output"))
  (add-to-list 'org-structure-template-alist
	       '("init" . "src emacs-lisp :tangle init.el"))
  ;; Gestion des images (affichage inline) : 
  (add-hook 'org-babel-after-execute-hook 'org-display-inline-images) 
  (add-hook 'org-mode-hook 'org-display-inline-images)
  ;; Utiliser minted et pygments pour la mise en forme des chunks pour l'export TeX/PDF :
  (setq org-latex-listings 'minted)
  ;; (add-to-list 'org-latex-packages-alist '("" "minted")) ;; peut-être pas une bonne idée de toujours le charger par défaut...
  (add-to-list 'org-latex-packages-alist '("" "color"))
  (add-to-list 'org-latex-minted-langs '(R "r"))
  (add-to-list 'org-latex-minted-langs '(SAS "sas")))

;; Utilisation de org-ref :
(use-package org-ref
  :ensure t
  :after org
  :init
  (setq org-latex-pdf-process (list "latexmk -shell-escape -bibtex -f -pdf %f")))

;; Gestion de iPython en Org-mode :
(use-package ob-ipython
  :ensure t)

;; Gestion de l'exécution asynchrone des blocs en Org-Babel :
(use-package ob-async
  :ensure t
  :defer t
  :config
  ;; Résoudre une incompatibilité entre ob-async et ob-ipython :
  (setq ob-async-no-async-languages-alist '("ipython")))

;; Interaction avec pandoc pour l'export Org-mode :
(use-package ox-pandoc
  :ensure t)

(use-package ox-gfm
  :ensure t)

;; Polymode:
(use-package poly-markdown
  :ensure t)
(use-package poly-org
  :ensure t)
(use-package poly-R
  :ensure t)

;; Réglages pour LaTeX :
(use-package tex
  :ensure auctex
  :init
  (defun tex-pdf-on () (TeX-PDF-mode 1)) ;; fonction utilisée plus bas
  :config
  ;; Réglages conseillés par le manuel de AucTeX :
  (setq TeX-auto-save t)
  (setq TeX-parse-self t)
  (setq-default TeX-master nil)
  ;; Activer par défaut le PDF avec LaTeX :
  (add-hook 'tex-mode-hook 'tex-pdf-on)
  (add-hook 'latex-mode-hook 'tex-pdf-on)
  (setq TeX-PDF-mode t)
  ;; Activer le mode auto-fill pour LaTeX :
  (add-hook 'tex-mode-hook 'turn-on-auto-fill)
  (add-hook 'LaTeX-mode-hook 'turn-on-auto-fill)
  ;; Activer le support de reftex :
  (require 'reftex)
  (add-hook 'LaTeX-mode-hook 'reftex-mode)
  (setq reftex-plug-into-AUCTeX t)
  ;; Vérification orthographique en mode TeX :
  (add-hook 'LaTeX-mode-hook 'flyspell-mode)
  ;; Activer le mode math par défaut :
  (add-hook 'LaTeX-mode-hook 'LaTeX-math-mode)
  ;; Toujours exporter avec shell-escape :
  (setq LaTeX-command-style '(("" "%(PDF)%(latex) %(file-line-error) %(extraopts) -shell-escape %S%(PDFout)"))))

;; Diaporamas reveal.js :
(use-package ox-reveal
  :ensure t)

;; Markdown :
(use-package markdown-mode
  :ensure t
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.Rmd\\'" . markdown-mode))
  :config
  (setq markdown-enable-math t))

;; Écriture d'articles :
(use-package academic-phrases
  :ensure t)

;; PDF-TOOLS :
(use-package pdf-tools
  :ensure t
  :config
  (pdf-tools-install)
  (setq-default pdf-view-display-size 'fit-width)
  (setq pdf-annot-activate-created-annotations t)
  (add-hook 'pdf-tools-enabled-hook 'auto-revert-mode) ; rafraichissement auto des PDF
  (setq revert-without-query "*.pdf"))

;; INTERACTION AVEC ZOTERO :
(use-package zotxt
  :ensure t)

;; Ediff :
(setq ediff-split-window-function 'split-window-horizontally)

;; Magit :
(use-package magit
  :ensure t
  :init
  (setq vc-handled-backends nil) ;; désactiver le mode VC par défaut, le remplacer par magit
  :config
  (remove-hook 'server-switch-hook 'magit-commit-diff) ;; ne pas montrer le diff par défaut à chaque commit
  )

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-level-1 ((t (:inherit default :foreground "#cb4b16" :overline t :weight semi-bold :height 1.15))))
 '(org-level-2 ((t (:inherit default :foreground "#859900" :weight semi-bold :height 1.1))))
 '(org-level-3 ((t (:inherit default :height 1.05)))))

;;; init.el ends here
