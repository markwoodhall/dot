;;; lsp.el --- My EMACS config -*- lexical-binding: t -*-

;; Copyright © 2024-2024 Mark Woodhall and contributors

;;; Commentary:

;; An EMACS config that is ok for me!

;;; License:

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 3
;; of the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Code:
(add-hook 'clojure-mode-hook 'eglot-ensure)
(add-hook 'fennel-mode-hook 'eglot-ensure)

(nvmap :keymaps 'eglot-mode-map :prefix "SPC"
  "l"   '(:which-key "lsp")
  "l d" '(:which-key "diagnostics")

  "l g" '(:which-key "goto")
  "l g d" '(xref-find-definitions :which-key "Find definitions")

  "l d a" '(eglot-code-actions :which-key "Code actions")
  "l d r" '(xref-find-references :which-key "Find references")
  "l d d" '(flymake-show-buffer-diagnostics :which-key "Buffer diagnostics")
  "l d D" '(flymake-show-diagnostic :which-key "Project diagnostics"))

;;; lsp.el ends here
