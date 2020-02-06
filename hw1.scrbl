#lang scribble/manual
@(require
   "lib.rkt"
   scribble/example)

@title[#:tag "" #:tag-prefix "hw:1"]{Homework 1 -- Practice Modeling a Language}

In this assignment, I ask you to model a non-trivial language.
The assignment is meant to be challenging, but it will not be marked harshly.
The assignment is meant to teach you, not assess what you've learned.
Don't be scared, but try your best.

You may use Redex if you like, and can find additional help on Redex at
@url{https://www.williamjbowman.com/doc/experimenting-with-redex/}.
This will introduce many features I haven't explained in class.
Restrict yourself only to defining judgments, and do not use
metafunctions or reduction relations from Redex.
You may use other features, such as pattern matching and testing features.

The assignment is due Jan. 24th at 11:59pm.
Send it to me by email, either as a plaintext document, a PDF, or a Redex
implementation with comments.

@section{Part 1: Define a collection of expressions}
Model the syntax and evaluation function for a simple language.

Your language should include
@itemlist[
  @item{A syntactic category ("judgment", but you can use BNF grammars) of
  inductively defined natural numbers.

  While you should model natural numbers inductively, you may use decimal
  notation in examples.
  If you need to use decimal numbers in Redex, you can use the following
  metafunction to convert between representations.
  @examples[
  (require redex/reduction-semantics)
  (define-language L)
  (define-metafunction L
    to-nat : number -> any
    [(to-nat 0)
     the-representation-of-zero]
    [(to-nat number_1)
     (the-representation-of-add1 (to-nat ,(sub1 (term number_1))))])
   (term (to-nat 0))
   (term (to-nat 5))
  ]
  A metafunction is a short-hand for a judgment with a clear interpretation as a
  recursive function for which we only care about the output.
  The evaluation function and substitution are examples of metafunctions.
  You can use a Redex metafunction in any place that Redex expects some Redex
  term.
  }
  @item{A syntactic category of boolean expressions.}
  @item{A syntactic category of expressions with:
  @itemlist[
    @item{Natural numbers. Note that these should be separately defined from the
    syntactic category of natural numbers. For example, the expression @tt{(s
    true)}.}
    @item{Booleans and If}
    @item{Functions and application}
    @item{Dictionaries: n-ary tuples of key/value pairs with key-based projections.

    Keys should be symbols, such as @tt{a} or @tt{b}, and values should be either
    natural numbers or booleans.

    Dictionaries should not have fixed sizes.
    The syntax should enable the user to add new key/value pairs to an existing
    dictionary, similar to how a user can add a new element to a linked list.

    The projection operation should work regardless of the size or length of the
    dictionary.
    }
    @item{@tt{nat-fold}: a fold (recursion) operator over natural numbers.

    @tt{nat-fold} should act similar to the functional programming @racket[foldr] construct on lists.
    @tt{nat-fold} takes three sub-expressions: @tt{@emph{e@sub{1}}},
    @tt{@emph{e@sub{2}}}, and @tt{@emph{e@sub{3}}}.
    @tt{@emph{e@sub{1}}} is expected to be an expression that produces a natural number.
    @tt{@emph{e@sub{2}}} is expected to be an arbitrary expression.
    @tt{@emph{e@sub{3}}} is expected to be an expression that produces a function
    that takes two arguments.

    For the reduction rules:
    When @tt{@emph{e@sub{1}}} is zero, the result of @tt{nat-fold} should be @tt{@emph{e@sub{2}}}.
    When @tt{@emph{e@sub{1}}} is @tt{(s @emph{e})}, the result should be @tt{@emph{e@sub{3}}} applied to
    @tt{@emph{e}} and a recursive application of @tt{nat-fold}
    to @tt{@emph{e}} as the first argument, @tt{@emph{e}@sub{2}} as the second
    argument, and @tt{@emph{e}@sub{3}} as the third argument.

    @tt{nat-fold} should implement recursion on natural numbers and allow you to
    write loops over natural numbers.}
    ]
  }
]

You should define this language either in Redex or on paper.
(I strongly recommend Redex.)

First, formally define the syntax using a BNF grammar.
Explain the grammar briefly in English.
Explain which expressions are introduction forms and which are elimination
forms.
Argue that the grammar is inductively well-defined.
Recall that a well-defined judgment has some measure that is smaller in the
self-referenencing premises than in the conclusion of the judgment.

@section{Part 2: Define operations on expressions}
Define the reduction relation, conversion relation, and evaluation function for this language.
You do not have to define capture-avoiding substitution.

@section{Part 3: Properties}
Explain whether all syntactic expressions are well-defined, in the sense that
they produce valid observations in the evaluation function.

@section{Part 4: Prove some stuff}
@subsection{About dictionaries}
Create a dictionary mapping the symbol @tt{a} to the value @tt{5}, @tt{b} to the
value @tt{120}, and @tt{c} to the value @tt{false}.

Prove that projecting @tt{b} from this dictionary evaluates to @tt{120}.

@subsection{About numbers}
Implement a function in your langauge called @tt{is-zero?}.
This will require writing an expression in your model, not adding new
expressions to your model.

The @tt{is-zero?} function takes one argument and evaluates to @tt{true} when
given @tt{0}, and @tt{false} when given @tt{(s @emph{e})}.

You might find the Redex function @racket[define-term] helpful.

Note that below I use decimal numbers, which you may need to translate into your
formal model.

Prove that @tt{eval (is-zero? 0) = true} by constructing derivation trees
showing each step of conversion or reduction.
If you use Redex, translate the derivation into on-paper notation.

Prove the following equationally, not with formal derivation trees.
Instead of writing formal derivations, write the series of reductions or
conversions, explaining which rules are required.
You may skip steps when there are multiple applications of the same rule or
uninteresting rules like transitivity, but be sure to list which rule you
elide.

@tt{eval (is-zero? 1) = false}

@tt{eval (is-zero? 2) = false}

Implement the addition function @tt{+}.
Note that you were not allowed to add @tt{+} to your model.

Prove that @tt{eval (+ 0 0) = 0} by giving derivation trees.

Prove the following equationally.
It may help to prove and reuse some lemmas.

@tt{eval (+ 0 1) = 1}

@tt{eval (+ 1 1) = 2}

@tt{eval (+ 1 2) = 3}

@tt{eval (+ 2 2) = 4}
