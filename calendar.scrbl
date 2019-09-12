#lang scribble/manual

@title{Course Calendar}
We list some important dates on this calendar for your reference.
This calendar is subject to change.

@(define dates
   '("Monday, Jan. 6, 2020"
     "Wednesday, Jan. 8, 2020"
     "Monday, Jan. 13, 2020"
     "Tuesday, Jan. 14, 2020"
     "Wednesday, Jan. 15, 2020"
     "Monday, Jan. 20, 2020"
     "Wednesday, Jan. 22, 2020"
     "Friday, Jan. 24, 2020"
     "Monday, Jan. 27, 2020"
     "Wednesday, Jan. 29, 2020"
     "Monday, Feb. 3, 2020"
     "Monday, Feb. 3, 2020"
     "Wednesday, Feb. 5, 2020"
     "Monday, Feb. 10, 2020"
     "Wednesday, Feb. 12, 2020"
     "Monday, Feb. 17, 2020"
     "Wednesday, Feb. 19, 2020"
     "Monday, Feb. 24, 2020"
     "Monday, Feb. 24, 2020"
     "Monday, Feb. 24, 2020"
     "Wednesday, Feb. 26, 2020"
     "Wednesday, Feb. 26, 2020"
     "Monday, Mar. 2, 2020"
     "Wednesday, Mar. 4, 2020"
     "Monday, Mar. 9, 2020"
     "Wednesday, Mar. 11, 2020"
     "Monday, Mar. 16, 2020"
     "Wednesday, Mar. 18, 2020"
     "Monday, Mar. 23, 2020"
     "Wednesday, Mar. 25, 2020"
     "Monday, Mar. 30, 2020"
     "Wednesday, Apr. 1, 2020"
     "Monday, Apr. 6, 2020"
     "Wednesday, Apr. 8, 2020"
     "Wednesday, Apr. 8, 2020"
     "Wednesday, Apr. 15, 2020"))

@(define activity
   '("Syllabus, Math, and Rebuilding the Universe"
    "Modeling Languages"
    "Modeling Languages"
    "Homework 1 Assigned"
    "SNOW DAY"
    "POPL DAY"
    "POPL DAY"
    "Homework 1 Due"
    "Homework 1 Review; Modeling imperative features, modeling type systems"
    "Proof by Induction, and more Type Systems!"
    "Type system for imperative languages, and more type safety!"
    "Homework 2 Assigned!"
    "Type safety is weak; program equivalence, logical relations!"
    "Modeling Compilers!"
    "CPS and Closure Conversion!"
    "READING BREAK!"
    "READING BREAK!"
    "Homework 2 Due!"
    "Compiler Correctness Theorems!"
    "Project Assigned!"
    "Begin Seminar on Compiler Correctness"
    "From System F to Typed Assembly Language"
    "TIL: A type-directed optimizing compiler for ML"
    "Proof Carrying Code"
    "Dependently Typed Assembly Language"
    "Bringing the Web up to Speed with WebAssembly"
    "Formal Certification of a Compiler Back-end"
    "Compositional CompCert"
    "Lightweight Verification of Separate Compilation"
    "CompCertM: CompCert with C-Assembly Linking and Lightweight Modular Verification"
    "Typed Closure Conversion Preserves Observational Equivalence"
    "The Correctness Security Gap in Compiler Optimization"
    "Securing the .NET Programming Model"
    "CT-wasm: Type-driven Secure Cryptography for the Web Ecosystem"
    "Projects Write-up Due."
    "Project Critiques Due."))

@(unless (equal? (length dates) (length activity))
   (error "You fucked up the calendar"))

@tabular[
  #:style 'boxed
  #:column-properties '(left right)
  #:row-properties '(bottom-border ())
  (append
    (list
      (list @bold{Date} @bold{Note}))
    (map (lambda (x y)
           (list x y))
         dates
         activity))]

