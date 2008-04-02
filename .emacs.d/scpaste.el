;;; scpaste.el --- Paste to the web via SCP.

;; Copyright (C) 2008 Phil Hagelberg

;; Author: Phil Hagelberg
;; URL: http://www.emacswiki.org/cgi-bin/wiki/SCPaste
;; Version: 0.1
;; Created: 2008-04-02
;; Keywords: convenience hypermedia
;; EmacsWiki: SCPaste

;; This file is NOT part of GNU Emacs.

;;; License:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
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

;;; Commentary:

;; This will place an HTML copy of a buffer on the web on a server
;; that the user has shell access on.

;; Tested in Emacs 23, but should work in 22 and perhaps 21.

;;; Todo:

;; Find some way to list extant pastes?
;; Force SCP password prompt into the minibuffer
;; Add some metadata to pastes (who pasted, when?)
;; Include the footer in pastes
;; Make htmlize convert URLs to hyperlinks?

;;; Code:

(require 'url)
(require 'htmlize) ;; http://fly.srk.fer.hr/~hniksic/emacs/htmlize.el.html

(defvar scpaste-scp-destination
  "philhag@hagelb.org:p.hagelb.org"
  "Directory to place files via `scp' command.")

(defvar scpaste-http-destination
  "http://p.hagelb.org"
  "Http-accessible location that corresponds to `scpaste-scp-destination'.")

(defvar scpaste-footer
  (concat "<p>Generated by <a href='"
	  scpaste-http-destination
	  "'>scpaste</a>.</p>")
  "HTML message to place at the bottom of each file.")

(defvar scpaste-tmp-dir "/tmp"
  "Writable location to store temporary files.")

(defun scpaste (original-name)
  (interactive "MName: ")
  (save-excursion
    (let* ((b (htmlize-buffer))
	   (name (url-hexify-string original-name))
	   (full-url (concat scpaste-http-destination "/" name ".html"))
	   (scp-destination (concat scpaste-scp-destination "/" name ".html"))
	   (tmp-file (concat scpaste-tmp-dir "/" name)))
      (switch-to-buffer b)
      (write-file tmp-file)
      (shell-command (concat "scp " tmp-file " " scp-destination))
      (kill-new full-url)
      (kill-buffer b)
      (message "Pasted to %s" full-url))))

(provide 'scpaste)
;;; scpaste.el ends here