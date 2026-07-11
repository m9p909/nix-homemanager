;;; myai.el --- AI-powered inline code editing via SEARCH/REPLACE blocks -*- lexical-binding: t -*-

;; Requires gptel to be installed and configured with an API backend.

(require 'cl-lib)
(require 'subr-x)
(require 'gptel)

;;; Code:

(defvar myai-system-prompt
  "You are an inline code editor for Emacs. You receive a file with line numbers and a cursor position. You return edits as one or more SEARCH/REPLACE blocks in this exact format:

<<<< SEARCH
exact original lines from the file
====
new lines to replace them with
>>>>

Rules:
- SEARCH must match text in the file exactly (whitespace-sensitive).
- Include enough context lines in SEARCH to be unambiguous.
- Multiple SEARCH/REPLACE blocks allowed, separated by a blank line.
- Output ONLY the blocks. No prose, no markdown fences, no explanation.
- If no edit is needed, output nothing.

Markers in the file:
- `--> N|` marks the line where the user's cursor is. This is the user's focal point — the edit they describe likely targets code at or near this line.
- `--> N|` and `<-- N|` bracket a visual selection when the user has selected a range of lines."
  "System prompt for AI inline editing.")

(defun myai--strip-fences (text)
  "Strip markdown code fences from TEXT if present."
  (let ((trimmed (string-trim text)))
    (if (string-match "\\````[a-zA-Z0-9]*\n\\(\\(.\\|\n\\)*?\\)\n```\\'" trimmed)
        (match-string 1 trimmed)
      text)))

(defun myai--parse-blocks (text)
  "Parse SEARCH/REPLACE blocks from TEXT.
Returns a list of (SEARCH . REPLACE) cons cells."
  (let ((blocks nil)
        (lines (split-string text "\n"))
        (state :idle)
        (search-lines nil)
        (replace-lines nil))
    (dolist (line lines)
      (cond
       ((and (eq state :idle) (string= line "<<<< SEARCH"))
        (setq state :search))
       ((and (eq state :search) (string= line "===="))
        (setq state :replace))
       ((and (eq state :replace) (string= line ">>>>"))
        (push (cons (string-join (nreverse search-lines) "\n")
                    (string-join (nreverse replace-lines) "\n"))
              blocks)
        (setq state :idle
              search-lines nil
              replace-lines nil))
       ((eq state :search)
        (push line search-lines))
       ((eq state :replace)
        (push line replace-lines))))
    (nreverse blocks)))

(defun myai--build-context (lines cursor-line range)
  "Build numbered lines with cursor/selection markers.
LINES is a list of buffer lines.  CURSOR-LINE is the current line number.
RANGE is nil or a plist with :start-line and :end-line."
  (let* ((line-count (max 1 (length lines)))
         (width (length (number-to-string line-count)))
         (numbered-lines nil))
    (dotimes (i line-count)
      (let* ((line-num (1+ i))
             (line (nth i lines))
             (prefix (format (format "%%%dd|" width) line-num)))
        (cond
         ((and range (= line-num (plist-get range :start-line)))
          (setq prefix (concat "--> " prefix)))
         ((and range (= line-num (plist-get range :end-line)))
          (setq prefix (concat "<-- " prefix)))
         ((and (not range) (= line-num cursor-line))
          (setq prefix (concat "--> " prefix))))
        (push (concat prefix line) numbered-lines)))
    (nreverse numbered-lines)))

(defun myai--apply-blocks (response)
  "Apply SEARCH/REPLACE blocks from RESPONSE to the current buffer."
  (let* ((cleaned (myai--strip-fences response))
         (blocks (myai--parse-blocks cleaned)))
    (if (null blocks)
        (message "no SEARCH/REPLACE blocks found")
      (save-excursion
        (save-restriction
          (widen)
          (let ((content (buffer-substring-no-properties (point-min) (point-max))))
            (cl-block apply-loop
              (dolist (block blocks)
                (let ((search (car block))
                      (replace (cdr block)))
                  (let ((start-idx (string-match-p (regexp-quote search) content)))
                    (if (not start-idx)
                        (cl-return-from apply-loop
                          (message "SEARCH block not found: %s"
                                   (substring search 0 (min 60 (length search)))))
                      (setq content (concat (substring content 0 start-idx)
                                            replace
                                            (substring content (+ start-idx (length search))))))))
              (delete-region (point-min) (point-max))
              (insert content)
              (message "Applied %d edit(s)" (length blocks))))))))))

(defun myai-edit ()
  "AI-powered inline code edit.
If region is active, targets the selected lines.  Otherwise targets the current line.
Prompts for an instruction in the minibuffer, then applies SEARCH/REPLACE blocks
from the AI response."
  (interactive)
  (let* ((buf (current-buffer))
         (filepath (buffer-file-name))
         (filetype (replace-regexp-in-string "-mode\\'" "" (symbol-name major-mode)))
         (cursor-line (line-number-at-pos (point)))
         (range (when (use-region-p)
                  (list :start-line (line-number-at-pos (region-beginning))
                        :end-line (line-number-at-pos (region-end)))))
         (lines (save-excursion
                  (save-restriction
                    (widen)
                    (split-string (buffer-substring-no-properties (point-min) (point-max)) "\n"))))
         (numbered-lines (myai--build-context lines cursor-line range))
         (input (read-from-minibuffer "Edit: ")))
    (when (string= input "")
      (user-error "empty instruction"))
    (let ((user-prompt (format "File: %s (%s)\n\n%s\n\nUser request: %s\n\nOutput SEARCH/REPLACE blocks for the edits."
                               (or filepath "(unsaved)") filetype
                               (string-join numbered-lines "\n") input)))
      (gptel-request
       user-prompt
       :system myai-system-prompt
       :buffer buf
       :callback
       (lambda (response info)
         (if (not response)
             (message "myai error: %s" (plist-get info :status))
           (with-current-buffer buf
              (myai--apply-blocks response))))))))



(provide 'myai)
