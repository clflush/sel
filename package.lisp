;; Copyright (C) 2011-2013  Eric Schulte
(defpackage :software-evolution
  (:use
   :common-lisp
   :alexandria
   :metabang-bind
   :curry-compose-reader-macros
   :split-sequence
   :cl-ppcre
   :cl-mongo
   :mongo-middle-man
   :usocket
   :diff
   :elf
   :memoize
   :software-evolution-utility)
  (:shadow :elf :size :type :magic-number :diff :insert)
  (:export
   ;; software objects
   :software
   :define-software
   :edits
   :fitness
   :fitness-extra-data
   :mutation-stats
   :genome
   :phenome
   :compile-p
   :evaluate
   :copy
   :size
   :lines
   :line-breaks
   :genome-string
   :mitochondria
   :ancestors
   :pick
   :pick-good
   :pick-bad
   :pick-snippet
   :mutate
   :mutate-clang
   :mutation-types-clang
   :apply-mutation
   :text
   :obj
   :op
   :*mutation-stats*
   :*crossover-stats*
   :*analyze-mutation-verbose-stream*
   :analyze-mutation
   :mutation-key
   :crossover
   :one-point-crossover
   :two-point-crossover
   :*edit-consolidation-size*
   :*consolidated-edits*
   :*edit-consolidation-function*
   :edit-distance
   :from-file
   :ext
   :*clang-genome-separator*
   :genome-string-without-separator
   :from-file-exactly
   :get-vars-in-scope
   :get-indexed-vars-in-scope
   :bind-free-vars
   :prepare-sequence-snippet
   :apply-fun-body-substitutions
   :crossover-2pt-outward
   :crossover-single-stmt
   :crossover-all-functions
   :clang-tidy
   :clang-format
   :clang-mutate
   :update-mito-from-snippet
   :to-file
   :apply-path
   :compiler
   :prototypes
   :asts
   :good-asts
   :bad-asts
   :update-asts
   :source-location
   :line
   :column
   :asts-containing-source-location
   :asts-contained-in-source-range
   :asts-intersecting-source-range
   :ast-to-source-range
   :get-ast
   :get-parent-asts
   :parent-ast-p
   :get-parent-full-stmt
   :get-immediate-children
   :extend-to-enclosing
   :get-ast-info
   :get-fresh-ancestry-id
   :random-function-name
   :replace-fields-in-ast
   ;; global variables
   :*population*
   :*generations*
   :*max-population-size*
   :*tournament-size*
   :*tournament-eviction-size*
   :*fitness-predicate*
   :*cross-chance*
   :*mut-rate*
   :*fitness-evals*
   :*running*
   :*start-time*
   :elapsed-time
   ;; clang / clang-w-fodder global variables
   :fodder-database
   :mongo-database
   :db :host :port
   :mongo-middle-database
   :source-collection :cache-collection :middle-host :middle-port
   :json-database
   :find-snippets
   :find-types
   :sorted-snippets
   :*ancestor-logging*
   :*clang-full-stmt-bias*
   :*clang-same-class-bias*
   :*crossover-function-probability*
   :*fodder-selection-bias*
   :*clang-mutation-cdf*
   :*clang-crossover-cdf*
   :*free-var-decay-rate*
   :*matching-free-var-retains-name-bias*
   :*matching-free-function-retains-name-bias*
   :*allow-bindings-to-globals-bias*
   :*clang-format-after-mutation-chance*
   :*clang-json-required-fields*
   :*clang-json-required-aux*
   :*database*
   ;; evolution functions
   :incorporate
   :evict
   :tournament
   :mutant
   :crossed
   :new-individual
   :mcmc
   :evolve
   :generational-evolve
   ;; software backends
   :simple
   :light
   :sw-range
   :diff
   :original
   :asm
   :*asm-linker*
   :elf
   :elf-cisc
   :elf-csurf
   :elf-x86
   :elf-arm
   :elf-risc
   :elf-mips
   :genome-bytes
   :pad
   :nop-p
   :forth
   :lisp
   :clang
   :clang-w-fodder
   :clang-w-binary
   :clang-w-fodder-and-binary
   :bytes
   :diff-data
   :do-not-filter
   :with-class-filter
   :full-stmt-filter
   :recontextualize
   :rebind-uses
   :rebind-uses-in-snippet
   :delete-decl-stmt
   :rename-variable-near-use
   :nesting-depth
   :get-ast-text
   :full-stmt-p
   :enclosing-full-stmt
   :enclosing-block
   :block-successor
   :show-full-stmt
   :full-stmt-text
   :full-stmt-info
   :full-stmt-successors
   :prepare-code-snippet
   :cil
   :llvm
   :linker
   :flags
   :elf-risc-max-displacement
   :ops                      ; <- might want to fold this into `lines'
   ;; software backend specific methods
   :reference
   :base
   :disasm
   :addresses
   :instrument
   :clang-mito
   :add-macro
   :add-include
   :add-includes-for-function
   :add-type
   :union-mito
   :ignore-failed-mutation
   :fix-compilation
   :generational-evolve
   :simple-reproduce
   :simple-evaluate
   :simple-select
   :*target-fitness-p*
   :*worst-fitness-p*
   :worst-numeric-fitness
   :worst-numeric-fitness-p
   :lexicase-select
   :*lexicase-predicate*))
