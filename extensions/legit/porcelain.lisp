
(uiop:define-package :lem/porcelain
  (:use :cl)
  (:shadow :push)
  (:import-from :trivial-types
                :proper-list)
  (:export
   :porcelain-error
   :message
   :apply-patch
   :branches
   :checkout
   :checkout-create
   :commit
   :components
   :current-branch
   :discard-file
   :file-diff
   :latest-commits
   :pull
   :push
   :rebase-abort
   :rebase-continue
   :rebase-interactively
   :rebase-skip
   :rebase-in-progress
   :show-commit-diff
   :stage
   :unstage
   :*diff-context-lines*
   :commits-log
   :*commits-log-page-size*
   :commit-count
   :*nb-latest-commits*
   :vcs-project)
  (:documentation "Functions to run VCS operations: get the list of changes, of untracked files, commit, push… Git support is the main goal, a simple layer is used with other VCS systems (Fossil, Mercurial).

On interactive commands, Legit will check what VCS is in use in the current project.

When multiple VCS are used at the same time in a project, Git takes
precedence by default. See `lem/porcelain:*vcs-existence-order*`."))

(in-package :lem/porcelain)

#|
Supported version control systems:
- Git: main support
- Fossil: preliminary support
- Mercurial: preliminary support

TODOs:

Mercurial:

- add (stage) diff hunks

|#

;;; Global variables, for all VCS.
(defvar *nb-latest-commits* 10
  "Number of commits to show in the status.")

(defvar *commits-log-page-size* 200
  "Number of commits to show in the commits log.")

(defvar *diff-context-lines* 4
  "How many lines of context before/after the first committed line")

(define-condition porcelain-condition (simple-error)
  ())

(define-condition porcelain-error (porcelain-condition)
  ((message
    :initform ""
    :initarg :message
    :type :string))
  (:report
   (lambda (condition stream)
     (with-slots (message) condition
       (princ message stream)))))

(defun porcelain-error (message &rest args)
  (error 'porcelain-error :message (apply #'format nil message args)))

(defclass vcs-project ()
  ())

;;;
;;; Getting changes.
;;;
(defgeneric components (vcs)
  (:documentation "Returns three values, each a List[string]
- Untracked files
- Modified and unstaged files
- Modified and staged files")
  (:method (vcs)
    (porcelain-error "lem/porcelain:components not implemented for vcs ~a" vcs)))

;;;
;;; diff
;;;
(defgeneric file-diff (vcs file &key cached)
  (:method (vcs file &key cached)
    (declare (ignorable file cached))
    (porcelain-error "lem/porcelain:file-diff not implemented for vcs ~a" vcs)))

;;;
;;; Show commits.
;;;
(defgeneric show-commit-diff (vcs ref &key ignore-all-space)
  (:method (vcs ref &key ignore-all-space)
    (declare (ignorable ref ignore-all-space))
    (porcelain-error "lem/porcelain:show-commit-diff not implemented for vcs ~a" vcs)))

;; commit
(defgeneric commit (vcs message)
  (:documentation "Performs a commit operation: `message` must be a string.")
  (:method (vcs message)
    (declare (ignorable message))
    (porcelain-error "lem/porcelain:commit not implemented for vcs ~a" vcs)))

;; branches
(defgeneric branches (vcs &key sort-by)
  (:documentation "Returns a list[str] of branches in the repository")
  (:method (vcs &key sort-by)
    (declare (ignorable vcs sort-by))
    (porcelain-error "Method branches not supported for vcs ~a" vcs)))

(defgeneric current-branch (vcs)
  (:documentation "Return the current branch name (string).")
  (:method (vcs)
    (porcelain-error "lem/porcelain:current-branch not implemented for vcs ~a" vcs)))

(defgeneric rebase-in-progress (vcs)
  (:documentation 
   "Return a plist if a rebase is in progress. Used for legit-status.

  plist keys:

  :status (boolean) -> T if a rebase is in progress
  :head-name -> content from .git/rebase-merge/head-name, such as \"refs/heads/master\"
  :head-short-name -> \"master\"
  :onto -> content from .git/rebase-merge/onto, a commit id.")
  (:method (vcs)
    (porcelain-error "lem/porcelain:rebase-in-progress not implemented for vcs ~a" vcs)))

;;;
;;; Latest commits.
;;;
(defgeneric latest-commits (vcs &key n hash-length offset)
  (:documentation "Return a list of strings or plists.
  The plist has a :hash and a :message, or simply a :line."))

(defgeneric commits-log (vcs &key offset limit hash-length)
  (:documentation
   "Return a list of commits starting from the given offset.
   If a limit is not provided, it returns all commits after the offset."))

(defgeneric commit-count (vcs)
  (:documentation 
   "Returns: integer representing number of commits in the current branch.")
  (:method (vcs)
    (porcelain-error "lem/porcelain:commit-count not implemented for vcs ~a" vcs)))

;; stage, add files.
(defgeneric stage (vcs file)
  (:documentation "Stage changes to a file(TODO document type)")
  (:method (vcs file)
    (declare (ignorable file))
    (porcelain-error "lem/porcelain:stage not implemented for vcs ~a" vcs)))

(defgeneric unstage (vcs file)
  (:documentation 
   "Unstage changes to this file. The reverse of \"add\".")
  (:method (vcs file)
    (declare (ignorable file))
    (porcelain-error "VCS does not support or legit does not implement unstage: ~a" vcs)))
#|
Interestingly, this returns the list of unstaged changes:
"Unstaged changes after reset:
M	src/ext/legit.lisp
M	src/ext/peek-legit.lisp
M	src/ext/porcelain.lisp
""
|#

;; discard changes.
(defgeneric discard-file (vcs file)
  (:documentation "Discard all changes to this file")
  (:method (vcs file)
    (declare (ignorable file))
    (porcelain-error "discard-file is not implemented for this VCS: ~a" vcs)))

(defgeneric apply-patch (vcs diff &key reverse)
  (:documentation 
   "Apply a patch from this diff.
  diff: string.")
  (:method (vcs diff &key reverse)
    (declare (ignorable diff reverse))
    (porcelain-error "lem/porcelain:apply-patch not implemented for vcs ~a" vcs)))

(defgeneric checkout (vcs branch)
  (:documentation "Checkouts out branch (str) in vcs")
  (:method (vcs branch)
    (declare (ignorable branch))
    (porcelain-error "lem/porcelain:checkout not implemented for vcs ~a" vcs)))

(defgeneric checkout-create (vcs new start)
  (:documentation "Checkouts out branch (str) in vcs, creating it at HEAD if it does not exit")
  (:method (vcs new start)
    (declare (ignorable vcs new start))
    (porcelain-error "lem/porcelain:checkout-create not implemented for vcs ~a" vcs)))

(defgeneric pull (vcs)
  (:documentation "Pulls remotes")
  (:method (vcs)
    (porcelain-error "lem/porcelain:pull not implemented for vcs ~a" vcs)))

(defgeneric push (vcs)
  (:documentation "Pushes to remotes")
  (:method (vcs)
    (porcelain-error "lem/porcelain:push not implemented for vcs ~a" vcs)))

;; Interactive rebase
(defgeneric rebase-interactively (vcs &key from)
  (:method (vcs &key from)
    (declare (ignorable from))
    (porcelain-error "lem/porcelain:rebase-interactively not implemented for vcs ~a" vcs)))

(defgeneric rebase-continue (vcs)
  (:documentation
   "Either send a continuation signal to the underlying git rebase process, for it to pick up our changes to the interactive rebase file,
  either call git rebase --continue.")
  (:method (vcs)
    (porcelain-error "lem/porcelain:rebase-continue not implemented for vcs ~a" vcs)))

(defgeneric rebase-abort (vcs)
  (:method (vcs)
    (porcelain-error "lem/porcelain:rebase-abort not implemented for vcs ~a" vcs)))

(defgeneric rebase-skip (vcs)
  (:method (vcs)
    (porcelain-error "lem/porcelain:rebase-skip not implemented for vcs ~a" vcs)))