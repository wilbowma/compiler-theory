#lang scribble/manual
@(require
  "lib.rkt"
  scribble/example)

@title[#:tag "" #:tag-prefix "hw:2"]{Homework 2 -- Practice with Type Systems}

You should complete this homework on paper and submit as a PDF.
You may use Redex to help you, but be sure to translate to on-paper notation.

@section{Type Systems}
Extend your model from HW1 with a type system.
This should include:
@itemlist[
@item{A syntactic category for types.}
@item{A type for nat, bool, functions, and records.}
@item{A syntactic category for typing environments.}
@item{Typing rules.}
]

@section{Proof by Induction/Type Safety}
Prove the following cases of progress and preservation:
@itemlist[
@item{lambda and application}
@item{bool and if}
@item{dictionary formation and projection}
]

Note that the formal statements below are somewhat different from what we proved
in class.
The versions presented in class are the intuitive statements we got to from first principles.
The versions below should be sufficient.

If you find you need any additional lemmas, you may state them and use them
without proof (as long as they are not substantially similar to the lemma you
are trying to prove).

@emph{Lemma 1 (Progress)}: If @tt{· ⊢ e : A} then either @tt{e} is an @tt{o}, or @tt{e → e'}.

@emph{Lemma 2 (Preservation)}: If @tt{· ⊢ e : A} and @tt{e → e'} then @tt{· ⊢ e' : A}.

The canonical forms lemma is a commonly used lemma that simplifies some reasoning:

@emph{Lemma 3 (Canonical Forms)}: If @tt{· ⊢ e : A} then either
@itemlist[
@item{@tt{A = Nat} and @tt{e = z}, or}
@item{@tt{A = Nat} and @tt{e = (s n)}, or}
@item{@tt{A = A -> B'} and @tt{e = λx.e'}, or}
@item{@tt{A = Bool} and @tt{e = true}, or}
@item{@tt{A = Bool} and @tt{e = false}}
]

Prove type safety, using the previous lemmas.
This will not be an inductive proof; despite the generic meta-variables, we can
build derivations by appealing to the previous lemmas.

@emph{Theorem (Type Safety): If @tt{· ⊢ e : A} then @tt{eval(e) = o}.} 