;;;; cpp-scan.lisp --- Tests of CPP-SCAN
(defpackage :software-evolution-library/test/cpp-scan
  (:nicknames :sel/test/cpp-scan)
  (:use
   :common-lisp
   :alexandria
   :closer-mop
   :software-evolution-library/stefil-plus
   :named-readtables
   :curry-compose-reader-macros
   :iterate
   :split-sequence
   :cl-ppcre
   #+gt :testbot
   :software-evolution-library
   :software-evolution-library/utility)
  (:import-from :uiop :nest)
  (:shadowing-import-from
   :closer-mop
   :standard-method :standard-class :standard-generic-function
   :defmethod :defgeneric)
  (:export :cpp-scan))
(in-package :software-evolution-library/test/cpp-scan)
(in-readtable :curry-compose-reader-macros)
(defsuite cpp-scan)

(deftest cpp-scan-basic ()
  (is (null (cpp-scan "" #'is-comma)))
  (is (eql (cpp-scan "," #'is-comma) 0))
  (is (eql (cpp-scan "," #'is-comma :start 0) 0))
  (is (null (cpp-scan ", " #'is-comma :start 1)))
  (is (null (cpp-scan " , " #'is-comma :end 1))))

(deftest cpp-scan-simple-parens ()
  (is (eql (cpp-scan " , " #'is-comma) 1))
  (is (null (cpp-scan "()" #'is-comma)))
  (is (null (cpp-scan "(,)" #'is-comma)))
  (is (eql (cpp-scan "(,)," #'is-comma) 3))
  (is (eql (cpp-scan "()," #'is-comma) 2))
  (is (null (cpp-scan "[,]" #'is-comma)))
  (is (eql (cpp-scan "[,]," #'is-comma) 3))
  (is (eql (cpp-scan "[]," #'is-comma) 2))
  (is (null (cpp-scan "{,}" #'is-comma)))
  (is (eql (cpp-scan "{,}," #'is-comma) 3))
  (is (eql (cpp-scan "{}," #'is-comma) 2)))

(deftest cpp-scan-literals ()
  (is (null (cpp-scan "\",\"" #'is-comma)))
  (is (null (cpp-scan "\"\\\",\"" #'is-comma)))
  (is (eql (cpp-scan "\"\\\",\" , " #'is-comma) 6))
  (is (eql (cpp-scan " ,\",\"" #'is-comma) 1))
  (is (null (cpp-scan "','" #'is-comma)))
  (is (eql (cpp-scan "',' , " #'is-comma) 4))
  (is (eql (cpp-scan "'\\n'," #'is-comma) 4)))

(deftest cpp-scan-comments ()
  (is (null (cpp-scan "/* , , , */" #'is-comma)))
  (is (eql (cpp-scan "/**/," #'is-comma) 4))
  (is (eql (cpp-scan "/***/," #'is-comma) 5))
  (is (eql (cpp-scan "/* // */ ," #'is-comma) 9)))

(deftest cpp-scan-partials ()
  (is (null (cpp-scan "/" #'is-comma)))
  (is (null (cpp-scan "\"" #'is-comma)))
  (is (null (cpp-scan "'" #'is-comma)))
  (is (null (cpp-scan "'," #'is-comma)))
  (is (null (cpp-scan "\"" #'is-comma)))
  (is (null (cpp-scan "\"," #'is-comma)))
  (is (eql (cpp-scan "/," #'is-comma) 1)))


(deftest cpp-scan-line-comments ()
  (is (null (cpp-scan " // jsajd ,adas" #'is-comma)))
  (is (eql (cpp-scan (format nil " // . ~% , ") #'is-comma) 8)))

(deftest cpp-scan-nested-comments ()
  (is (eql (cpp-scan "( /* ( */ ) , " #'is-comma) 12))
  (is (eql (cpp-scan "( /* ) */ ) , " #'is-comma) 12))
  (is (eql (cpp-scan "( /* [ */ ) , " #'is-comma) 12))
  (is (eql (cpp-scan "( /* ] */ ) , " #'is-comma) 12))
  (is (eql (cpp-scan "( /* { */ ) , " #'is-comma) 12))
  (is (eql (cpp-scan "( /* } */ ) , " #'is-comma) 12))
  (is (eql (cpp-scan "[ /* ( */ ] , " #'is-comma) 12))
  (is (eql (cpp-scan "[ /* ) */ ] , " #'is-comma) 12))
  (is (eql (cpp-scan "[ /* [ */ ] , " #'is-comma) 12))
  (is (eql (cpp-scan "[ /* ] */ ] , " #'is-comma) 12))
  (is (eql (cpp-scan "[ /* { */ ] , " #'is-comma) 12))
  (is (eql (cpp-scan "[ /* } */ ] , " #'is-comma) 12))
  (is (eql (cpp-scan "{ /* ( */ } , " #'is-comma) 12))
  (is (eql (cpp-scan "{ /* ) */ } , " #'is-comma) 12))
  (is (eql (cpp-scan "{ /* [ */ } , " #'is-comma) 12))
  (is (eql (cpp-scan "{ /* ] */ } , " #'is-comma) 12))
  (is (eql (cpp-scan "{ /* { */ } , " #'is-comma) 12))
  (is (eql (cpp-scan "{ /* } */ } , " #'is-comma) 12)))

(deftest cpp-scan-nested-parens ()
  (is (null (cpp-scan "(())" #'is-comma)))
  (is (null (cpp-scan "((,))" #'is-comma)))
  (is (null (cpp-scan "(,())" #'is-comma)))
  (is (null (cpp-scan "((),)" #'is-comma)))
  (is (null (cpp-scan "([])" #'is-comma)))
  (is (null (cpp-scan "(,[])" #'is-comma)))
  (is (null (cpp-scan "([,])" #'is-comma)))
  (is (null (cpp-scan "([],)" #'is-comma)))
  (is (null (cpp-scan "({})" #'is-comma)))
  (is (null (cpp-scan "(,{})" #'is-comma)))
  (is (null (cpp-scan "({,})" #'is-comma)))
  (is (null (cpp-scan "({},)" #'is-comma)))

  (is (null (cpp-scan "[()]" #'is-comma)))
  (is (null (cpp-scan "[(,)]" #'is-comma)))
  (is (null (cpp-scan "[,()]" #'is-comma)))
  (is (null (cpp-scan "[(),]" #'is-comma)))
  (is (null (cpp-scan "[[]]" #'is-comma)))
  (is (null (cpp-scan "[,[]]" #'is-comma)))
  (is (null (cpp-scan "[[,]]" #'is-comma)))
  (is (null (cpp-scan "[[],]" #'is-comma)))
  (is (null (cpp-scan "[{}]" #'is-comma)))
  (is (null (cpp-scan "[,{}]" #'is-comma)))
  (is (null (cpp-scan "[{,}]" #'is-comma)))
  (is (null (cpp-scan "[{},]" #'is-comma)))

  (is (null (cpp-scan "{()}" #'is-comma)))
  (is (null (cpp-scan "{(,)}" #'is-comma)))
  (is (null (cpp-scan "{,()}" #'is-comma)))
  (is (null (cpp-scan "{(),}" #'is-comma)))
  (is (null (cpp-scan "{[]}" #'is-comma)))
  (is (null (cpp-scan "{,[]}" #'is-comma)))
  (is (null (cpp-scan "{[,]}" #'is-comma)))
  (is (null (cpp-scan "{[],}" #'is-comma)))
  (is (null (cpp-scan "{{}}" #'is-comma)))
  (is (null (cpp-scan "{,{}}" #'is-comma)))
  (is (null (cpp-scan "{{,}}" #'is-comma)))
  (is (null (cpp-scan "{{},}" #'is-comma))))

(deftest cpp-scan-angle-brackets ()
  (is (null (cpp-scan "" #'is-comma :angle-brackets t)))
  (is (null (cpp-scan "<,>" #'is-comma :angle-brackets t)))
  (is (eql (cpp-scan "," #'is-comma :angle-brackets t) 0))
  (is (eql (cpp-scan "<>," #'is-comma :angle-brackets t) 2)))
(deftest cpp-scan-skip-first ()
  (is (eql (cpp-scan "()(" (lambda (c) (eql c #\())) 0))
  (is (eql (cpp-scan "()(" (lambda (c) (eql c #\()) :skip-first t) 2))
  (is (eql (cpp-scan "(())(" (lambda (c) (eql c #\()) :skip-first t) 4))
  (is (eql (cpp-scan "(()(" (lambda (c) (eql c #\()) :start 1 :skip-first t)
           3))
  (is (eql (cpp-scan " ()(" (lambda (c) (eql c #\()) :start 1 :skip-first t)
           3)))
