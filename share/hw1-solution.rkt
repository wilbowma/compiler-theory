#lang racket

(require redex/reduction-semantics)

(define-language L
  [b ::= true false]
  [n ::= z (s n)]
  [v ::= n b]
  [e ::= b
     z (s e)
     (if e then e else e)
     (λ x e) (e e) x
     (make-dict)
     (dict-set (k v) e)
     (dict-ref k e)
     ;; Alternative n-ary dictionary syntax
     (dict (k e) ...)
     (nat-fold e e e)]
  [x k ::= variable-not-otherwise-mentioned]
  #:binding-forms
  (λ x e #:refers-to x))

#|
Part 1:
This grammar defines a collection of expressions `e` with booleans `true` and
`false, natural numbers `z` and `(s e)`, functions `(λ x e)`, application `(e
e)`, if expressions `(if e then e else e)`, variables `x`, dictionaries made by
either the empty dictionary `(make-dict)` or adding a key/value mapping `(k v)` to a
dictionary `(dict-set (k v) e)`, an operation `(dict-ref k e)` which projects
the value mapped to by key `k` in dictionary `e`, and primitive recursion over
natural numbers `(nat-fold e e e)`.

The introduction forms are `z`, `s e`, `true`, `false`, `(dict (k v) ...)`, and `(λ x e)`.
The elimination forms are `(if e then e else e)`, `(e e)`, `(dict-ref k e)`, and
`(nat-fold e e e)`.

The grammars are well-defined since each recursive use of a grammar is guarded
by some constructor, thus the size of the term as measured by the number of symbols in it gets smaller.
|#

(define-metafunction L
  to-nat : number -> any
  [(to-nat 0)
   z]
  [(to-nat number_1)
   (s (to-nat ,(sub1 (term number_1))))])

(define-metafunction L
  [(different k_1 k_1) #f]
  [(different k_1 k_2) #t])

(define-judgment-form L
  #:contract (→ e e)
  #:mode (→ I O)

  [-------------------------------------- "Step-If-True"
   (→ (if true then e_1 else e_2) e_1)]

  [-------------------------------------- "Step-If-False"
   (→ (if false then e_1 else e_2) e_2)]

  [------------------------------- "Step-App"
   (→ ((λ x e) e_2) (substitute e x e_2))]

  [------------------------------- "Step-In-Dict"
   (→ (dict-ref k (dict-set (k v) e)) v)]

  [(where #t (different k_1 k_2))
   ------------------------------- "Step-Next-Dict"
   (→ (dict-ref k_1 (dict-set (k_2 v) e)) (dict-ref k_1 e))]

  ;; Alternative projection from n-ary dictionary
  ;; Undefined behavior is the same key is mapped multiple times.
  [------------------------------- "Step-Dict-nary"
   (→ (dict-ref k_1 (dict (k v) ... (k_1 v_1) (k_2 v_2) ...)) v_1)]

  [----------------------------- "Step-Fold-Z"
   (→ (nat-fold z e_2 e_3) e_2)]

  [------------------------------- "Step-Fold-S"
   (→ (nat-fold (s e_1) e_2 e_3) ((e_3 e_1) (nat-fold e_1 e_2 e_3)))])

(define-judgment-form L
  #:contract (->+ e e)
  #:mode (->+ I O)
  [(→ e_1 e_2)
   ---------------- "Step"
   (->+ e_1 e_2)]

  [(->+ e_1 e_2)
   ----------------------- "S-Cong"
   (->+ (s e_1) (s e_2))]

  [(->+ e_1 e_11)
   ------------------------------- "If-Cong-e1"
   (->+ (if e_1 then e_2 else e_3) (if e_11 then e_2 else e_3))]

  [(->+ e_2 e_21)
   ------------------------------- "If-Cong-e2"
   (->+ (if e_1 then e_2 else e_3) (if e_1 then e_21 else e_3))]

  [(->+ e_3 e_31)
   ------------------------------- "If-Cong-e3"
   (->+ (if e_1 then e_2 else e_3) (if e_1 then e_2 else e_31))]

  [(->+ e_1 e_11)
   ------------------------------- "App-Cong-e1"
   (->+ (e_1 e_2) (e_11 e_2))]

  [(->+ e_2 e_21)
   ------------------------------- "App-Cong-e2"
   (->+ (e_1 e_2) (e_1 e_21))]

  [(->+ e_1 e_11)
   ------------------------------- "DictAdd-Cong-e1"
   (->+ (dict-set (k v) e_1) (dict-set (k v) e_11))]

  [(->+ e_1 e_11)
   ------------------------------- "DictGet-Cong-e1"
   (->+ (dict-ref k e_1) (dict-ref k e_11))]

  [(->+ e e_1) ...
   ------------------------------- "Dict-Nary-Cong"
   (->+ (dict (k e) ...) (dict (k e_1) ...))]

  [(->+ e_1 e_11)
   ------------------------------- "NatFold-Cong-e1"
   (->+ (nat-fold e_1 e_2  e_3) (nat-fold e_11 e_2 e_3))]

  [(->+ e_2 e_21)
   ------------------------------- "NatFold-Cong-e2"
   (->+ (nat-fold e_1 e_2 e_3) (nat-fold e_1 e_21 e_3))]

  [(->+ e_3 e_31)
   ------------------------------- "NatFold-Cong-e3"
   (->+ (nat-fold e_1 e_2 e_3) (nat-fold e_1 e_2 e_31))])

(define-judgment-form L
  #:contract (->* e e)
  #:mode (->* I O)

  [----------- "Refl"
   (->* e e)]

  [(->+ e_1 e_2) (->* e_2 e_3)
   --------------- "Trans"
   (->* e_1 e_3)])

;; eval
(define-judgment-form L
  #:contract (eval e e)
  #:mode (eval I O)

  [(->* e v)
   ---------- "eval"
   (eval e v)])

#|
Part 2:
The nat-fold rules essentially implement pattern matching plus recursion on
natural numbers.
If the number is zero, then "Step-Fold-Z" essentially jumps to its second
argument.
If the number is matches the pattern `(s e)`, then the third argument is called
with `e` and a recursive pattern match on `e`.

Each of the above rules with "Cong" in the name are congruence rules.
|#

#|
Part 3:
Not all syntactic expressions are well-defined.
For example, (s true) does not evaluate to a value
|#
(judgment-holds (eval (s true) v))

;; Part 4
(define-term dict-6.4.1
  (dict-set (a (to-nat 5))
            (dict-set (b (to-nat 120))
                      (dict-set (c false)
                                (make-dict)))))

(build-derivations
 (eval (dict-ref b dict-6.4.1) (to-nat 120)))

;; Part 5
(define-term is-zero? (λ x (nat-fold x true (λ x (λ rec false)))))

(build-derivations
 (eval (is-zero? z) true))

#|
(is-zero? 1)
= (nat-fold (s z) true (λ x (λ rec false))))
  by definition of is-zero?
= (((λ x (λ rec false)) z) (nat-fold z true (λ x (λ rec false))))
  by Step-Fold-S (and Trans and Step)
= false
  by two applications of Step-App (and Trans and Step)
|#

#|
(is-zero? 2)
= (nat-fold (s (s z)) true (λ x (λ rec false))))
by definition of is-zero?
= (((λ x (λ rec false)) (s z)) (nat-fold (s z) true (λ x (λ rec false))))
by Step-Fold-S (and Trans and Step)
= false
by two applications of Step-App (and Trans and Step)
|#

;; Part 6
(define-term + (λ n (λ m (nat-fold n m (λ e (λ rec (s rec)))))))

(build-derivations
 (eval ((+ z) z) z))

#|
I implicitly appeal to Trans and Step below without mentioning it.

eval (+ 0 1)
= (((λ n (λ m (nat-fold n m (λ e (λ rec (s rec)))))) 0) 1)
  by definition of +
= (nat-fold 0 1 (λ e (λ rec (s rec))))
  by two uses of Step-App
= 1
  by Step-Fold-Z

eval (+ 1 1) = 2
= (((λ n (λ m (nat-fold n m (λ e (λ rec (s rec)))))) 1) 1)
  by definition of +
= (nat-fold 1 1 (λ e (λ rec (s rec))))
  by two uses of Step-App
= (((λ e (λ rec (s rec))) 0) (nat-fold 0 1 (λ e (λ rec (s rec)))))
  by Step-Fold-S
= (s (nat-fold 0 1 (λ e (λ rec (s rec)))))
  by two uses of Step-App
= (s 1)
  by step three of the previous proof.
= 2
  by definition

eval (+ 1 2)
= (((λ n (λ m (nat-fold n m (λ e (λ rec (s rec)))))) 1) 2)
  by definition of +
= (nat-fold 1 2 (λ e (λ rec (s rec))))
  by two uses of Step-App
= (((λ e (λ rec (s rec))) 0) (nat-fold 0 2 (λ e (λ rec (s rec)))))
  by Step-Fold-S
= (s (nat-fold 0 2 (λ e (λ rec (s rec)))))
  by two uses of Step-App
= (s 2)
  by Step-Fold-Z and S-Cong
= 3
  by definition
|#
(test-equal
 (first (judgment-holds (eval ((+ (to-nat 2)) (to-nat 2)) v) v))
 (term (to-nat 4)))
