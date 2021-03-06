;;;; clang-expression.lisp --- Mutation and evaluation of clang expressions in Lisp form.
(defpackage :software-evolution-library/test/clang-expression
  (:nicknames :sel/test/clang-expression)
  (:use
   :gt/full
   #+gt :testbot
   :software-evolution-library/test/util
   :software-evolution-library/test/util-clang
   :software-evolution-library/stefil-plus
   :software-evolution-library
   :software-evolution-library/software/parseable
   :software-evolution-library/software/clang
   :software-evolution-library/software/expression
   :software-evolution-library/software/clang-expression
   :software-evolution-library/software/clang-expression)
  (:export :test-clang-expression))
(in-package :software-evolution-library/test/clang-expression)
(in-readtable :curry-compose-reader-macros)
(defsuite test-clang-expression
    "Mutation and evaluation of clang expressions in Lisp form."
  (clang-available-p))

(deftest (clang-expression-test :long-running) ()
  (flet ((test-conversion (obj pair)
           (destructuring-bind (text expected-expression) pair
             (let ((result (expression obj (stmt-with-text obj text))))
               (is (equalp result expected-expression)
                   "Statement ~S yields ~S not ~S."
                   text result expected-expression)))))
    (append
     (with-fixture gcd-clang
       (mapc {test-conversion *gcd*}
             '(("b = b - a;" (:= :b (:- :b :a)))
               ("a = a - b;" (:= :a (:- :a :b)))
               ("b != 0"    (:!= :b 0))
               ("a > b"     (:> :a :b))
               ("a == 0"    (:== :a 0)))))
     (with-fixture binary-search-clang
       (mapc {test-conversion *binary-search*}
             '(("mid = (start + end) / 2;"
                (:= :mid (:/ (:+ :start :end) 2)))
               ("haystack[i] = malloc(256 * sizeof(*haystack[i]));"
                (:= (:|[]| :haystack :i)
                 (:malloc (:* 256
                              (:sizeof (:unary-* (:|[]| :haystack :i))))))))))
     (with-fixture huf-clang
       (mapc {test-conversion *huf*}
             '(("h->h = malloc(sizeof(int)*s);"
                (:= (:-> :h :h) (:malloc (:* (:sizeof :int) :s))))
               ("heap->h = realloc(heap->h, heap->s + heap->cs);"
                (:= (:-> :heap :h)
                 (:realloc (:-> :heap :h) (:+ (:-> :heap :s)
                                              (:-> :heap :cs)))))))))))

;;;; Mutations of clang expressions in Lisp form.
(deftest change-operator-first ()
  (with-fixture clang-expr
    (apply-mutation *clang-expr*
                    (make-instance 'change-operator :targets '(0 :-)))
    (is (equal (genome *clang-expr*) '(:- 1 (:* 2 (:- 3 :y)))))))

(deftest change-operator-subtree ()
  (with-fixture clang-expr
    (apply-mutation *clang-expr*
                    (make-instance 'change-operator :targets '(3 :+)))
    (is (equal (genome *clang-expr*) '(:+ 1 (:+ 2 (:- 3 :y)))))))

(deftest double-constant ()
  (with-fixture clang-expr
    (apply-mutation *clang-expr*
                    (make-instance 'change-constant :targets '(7 :double)))
    (is (equal (genome *clang-expr*) '(:+ 1 (:* 2 (:- 6 :y)))))))

(deftest halve-constant ()
  (with-fixture clang-expr
    (apply-mutation *clang-expr*
                    (make-instance 'change-constant :targets '(7 :halve)))
    (is (equal (genome *clang-expr*) '(:+ 1 (:* 2 (:- 1 :y)))))))

(deftest mult-divide-leaf ()
  (with-fixture clang-expr
    (apply-mutation *clang-expr*
                    (make-instance 'mult-divide :targets 4))
    (is (equal (genome *clang-expr*) '(:+ 1 (:* (:/ (:* 2 2) 2) (:- 3 :y)))))))

(deftest mult-divide-subtree ()
  (with-fixture clang-expr
    (apply-mutation *clang-expr*
                    (make-instance 'mult-divide :targets 2))
    (is (equal (genome *clang-expr*) '(:+ 1 (:/ (:* (:* 2 (:- 3 :y)) 2) 2))))))

(deftest add-subtract-subtree ()
  (with-fixture clang-expr
    (apply-mutation *clang-expr*
                    (make-instance 'add-subtract :targets 2))
    (is (equal (genome *clang-expr*) '(:+ 1 (:- (:+ (:* 2 (:- 3 :y)) 1) 1))))))

(deftest subtract-add-subtree ()
  (with-fixture clang-expr
    (apply-mutation *clang-expr*
                    (make-instance 'subtract-add :targets 2))
    (is (equal (genome *clang-expr*) '(:+ 1 (:+ (:- (:* 2 (:- 3 :y)) 1) 1))))))


;;;; Evaluation of clang expressions in Lisp form.
(deftest eval-number-clang ()
  (is (equal (evaluate-expression (make-instance 'clang-expression) nil 1)
             '(1 "int"))))

(deftest eval-var-clang ()
  (is (equal (evaluate-expression
              (make-instance 'clang-expression) '((:a 1 "int")) :a)
             '(1 "int"))))

(deftest eval-function-clang ()
  (is (equal (evaluate-expression
              (make-instance 'clang-expression) '((:a 2 "int")) '(:+ 1 :a))
             '(3 "int"))))

(deftest eval-division-truncates-clang ()
  (is (equal (evaluate-expression
              (make-instance 'clang-expression) nil '(:/ 3 2)) '(1 "int")))
  (is (equal (evaluate-expression
              (make-instance 'clang-expression) nil '(:/ -3 2)) '(-1 "int"))))

(deftest eval-interior-max-clang ()
  (multiple-value-bind (result interior-max)
      (evaluate-expression
       (make-instance 'clang-expression) '((:a 3 "int"))  '(:- (:* 2 :a) 2))
    (is (equal result '(4 "int")))
    (is (equal interior-max 6))))

(deftest eval-signals-on-undefined-variable-clang ()
  (signals eval-error
           (evaluate-expression (make-instance 'clang-expression) nil  :a)))

(deftest eval-signals-on-unknown-type-clang ()
  (signals eval-error
           (evaluate-expression (make-instance 'clang-expression) nil  "test")))

(deftest eval-signals-on-unknown-function-clang ()
  (signals eval-error
           (evaluate-expression (make-instance 'clang-expression) nil  '(:test 1 2))))

(deftest eval-signals-on-wrong-arity-clang ()
  (signals eval-error
           (evaluate-expression (make-instance 'clang-expression) nil  '(:+ 1 2 3))))

(deftest eval-signals-on-illegal-pointer-ops-clang ()
  (signals eval-error
           (evaluate-expression
            (make-instance 'clang-expression) '((:ptr 1234 "*char"))
            '(:* 2 (:+ :ptr 1))))
  (signals eval-error
           (evaluate-expression
            (make-instance 'clang-expression) '((:ptr 1234 "*char"))
            '(:/ 2 (:+ :ptr 1)))))
