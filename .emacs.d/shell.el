;;; shell.el --- A collection of useful functions that shell out -*- lexical-binding: t -*-

;; Copyright © 2024-2024 Mark Woodhall and contributors

;;; Commentary:

;; Provides a range of functions that shell out to other programs

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

(defun mw/bash (cmd)
  "Run CMD using bash and return a seq of line output."
  (split-string
   (shell-command-to-string
    (concat "bash -c \"" cmd "\"")) "\n"))

(defun mw/jq (file jq)
  "Run JQ command against json FILE."
  (mw/bash (concat "jq -r '" jq "' " file )))

;;; shell.el ends here
