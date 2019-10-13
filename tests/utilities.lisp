(in-package :lem-tests)

(defvar *tests* '())

(defmacro define-test (name &body body)
  `(progn
     (setf *tests* (nconc *tests* (list ',name)))
     (defun ,name () ,@body)))

(defmacro test (form description)
  `(unless ,form
     (cerror "skip" (make-condition 'test-error
                                    :description ,description))))

(defun run-test (test-fn)
  (handler-bind ((test-error (lambda (e)
                               (format t "~&~A~%" e)
                               (invoke-restart 'continue))))
    (funcall test-fn)))

(defun run-all-tests ()
  (dolist (test *tests*)
    (run-test test)))
