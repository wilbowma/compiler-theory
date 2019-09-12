#lang scribble/manual
@(require
  "lib.rkt"
  racket/sandbox
  scribble/example)

@title[#:tag "" #:tag-prefix "notes:lec3"]{Lecture 3 -- The First Complete Model of a Language}

@section{To a Model of an Interpreter}
So far, we've seen how to model (1) a collection of expressions (2) a reduction
judgment @tt{→} which performs obvious computations (3) a conversion judgment
@tt{→*} which applies reduction transitivily and under all sub-expressions.

The conversion judgment is ... similar to an interpreter, but isn't quite.
The problem is that it does not necessarily run out program "to completion".
We can construct derivations that convert out program to a new expression after
0 steps, or 1 step, or 5 steps of reduction.
But an interpreter should run a program until it is complete, and there are no
more reduction steps possible.

To model an interpreter, we need to define what it means for a program to be
complete.
In most programming language implementations, we want our program to run until
there are no more instructions to perform and then return a value, or print
something to the screen, or some other way of giving a result to the user.
We model this by defining some notion of @emph{observation}.
The interpreter is then the function that returns an observation after
converting a program until there are no reductions possible and an observation
is reached.

First, we define observations.
In PL theory, we usually consider observations to be first-order values.
In our running example language, this means booleans and natural numbers.
@racketgrammar*[
[o b n]
]

Then, we model the evaluation function as follows.

@box{eval(@emph{e}) = @emph{o}}
@verbatim{

@emph{e} →* @emph{o}
------------
eval(@emph{e}) = @emph{o}
}
@margin-note{For judgment of the shape @tt{... = any}, @emph{i.e.}, those
judgment that simply equal some meta-variable, it is common to use them
"inline". For example, I could write @tt{eval(((s z) + (s z)))} to mean @tt{(s
(s z))}, without bothering to say "the observation @tt{@emph{o}} such that
@tt{eval((s z) + (s z)) = @emph{o}}".}

This specifies that @tt{eval} is the function that returns an observation @tt{@emph{o}}
of some program @tt{@emph{e}} such that @tt{@emph{e}} is convertible to
@tt{@emph{o}}.
In this language, since @tt{@emph{o}} is a first-order value, it has no
reductions left and the program must be complete.
While the conversion judgment is non-deterministic, we require as a premise to
@tt{eval} that we be given the particular derivation that ends in an
observation, not any of the conversions that fail to finish reducing the
expression.

This only gives us a model of the interpreter.
We still have to provide the derivation proving that any @tt{e} converts to an
observation.
But now we have a complete model of a language.
We can ask, and prove, that the expression @tt{((s z) + (s z))}, when run in any
correct interpreter, will in the observation @tt{(s (s z))}.

This also gives us the starting point for how we know a compiler correct: since
expressions now have meaning, "running them in the interpreter", we can start
asking whether that meaning is preserved.

Note that so far, we have very few guarantees about our language.
The interpreter is only defined for some expressions.
For example, the interpretation of @tt{(true + false)} is completely undefined.
The @tt{eval} function gives no result for this expression, since conversion
never reduces it to an observation.
When we start modeling compilation, we will see why undefined behavior is so
pernicious: we can have a completely correct compiler, since it preserves the
meaning of every expression (that, by definition, has a meaning), but could do
anything for other expressions @emph{and still be proven correct}.

@;We cannot easily "run" the conversion judgment, and the reason is not only that
@;it is non-deterministic.
@;The problem is the rule @tt{[Trans]} that violated our rule of thumb about
@;something getting smaller in judgment premises.
@;If the premises of a judgment always get smaller, it's easy to interpret as a
@;recursive function that produces a derivation.
@;Without that rule of thumb, we have to do work to translate the judgment into a
@;recursive function.

@section{Modeling Functions, and a useful pattern for adding new features}
So far we've been working with a trivial language of booleans and natural
numbers.
But the lessons and the general strategy apply to pretty much every language
we'll model.
So let's add first-class functions!

First-class functions ("functions", from now on) are popular in PL theory
because they are a single feature that can represent many features in a small
model.
We can encode objects, threads, co-routines, loops, actors, etc all using
first-class functions.
This means we can do a relatively small amount of math and apply it to a large
number of programming language features.

Unfortunately, first-class functions are pretty tricky.

So when modeling a new feature, where should we start?
We know we need some expression that we can write, and we'll need to give them
some reduction rules.
But how do we pick some expressions, and then how do we choose reduction rules?

In the previous examples, there was a pattern that we can extend.
We started with booleans and we added two expressions, @tt{true} and @tt{false},
that represent the boolean values, and one expression, @tt{if}, that used the
boolean values.
When we added natural numbers, we added a way of @emph{building} natural
numbers, @tt{z} and @tt{s}, and a way of @emph{using} natural numbers, @tt{+}.

In general, programming language models add features by adding some
@deftech{introduction forms} that allow the user to build some kind of data, and
@deftech{elimination forms} that allow the user to that data to perform some
computation.
We start by adding the syntax of the @tech{introduction forms} and
@tech{elimination forms}.
Then we add a single reduction rule for each @tech{elimnation form} applied to
each @tech{introduction form}.
We can predict how many reduction rules we should have: there ought to be
@racket[n*m] rules, where we have @racket[n] @tech{introduction forms} and
@racket[m] @tech{elimination forms}.
For example, we had two @tech{introduction forms} for booleans, and one
@tech{elimination form}, so we had two reduction rules related to booleans.
The same with the natural numbers.
Each reduction rule has a predictable pattern: start with the @tech{elimination
form} and pattern match on the sub-expression that is an @tech{introduction form}.
All @tt{if} does is pattern match on its first sub-expression.
The same with @tt{+}.

The pattern doesn't tell us everything.
We still need to pick forms and rules that match our intuition for what we're trying to model.
But it gives us a place to start.

Applying this pattern, we start by modeling functions.
We expected to add some introduction forms, and elimination forms.
Intuitively, we want to be able to define functions, and call functions.
That sounds like two different forms.
@racketgrammar*[
[e .... (λx.e) (e_1 e_2) x]
]
We add the @tech{introduction form} @tt{(λx.e)} to define a function of one
argument, named @tt{x}, which can be used in the body of the function @tt{e}.
We also add a way to call functions with an argument, @tt{(e_1 e_2)}, which
calls (or, "applies") the function @tt{e_1} to the argument @tt{e_2}.

In a small deviation from the pattern, we also add @tt{x} as an expression.
We need this in order to reference function arguments, but it is not clearly
either an elimination form or an introduction form.
In general, names are complicated, and this is not the last time we'll look at
them askance.

Next, we move on to reduction rules.
The pattern tells us we should have one new reduction rule, since we have one
@tech{elimination form} that can be applied to one @tech{introduction form}
(@racket[1*1] = @racket[1]).
We start by applying the pattern: the conclusion of the rule should be the
@tech{elimination form} pattern matching on the @tech{introduction form}:

@verbatim{
??
---------------
((λx.e) e_2) → ??
}

Now, for what the rule should do.
We're trying to model "calling a function".
Intuitively, we want this to start executing the body of the function,
@tt{@emph{e}}, but with all instances of the argument name @tt{x} replaced by
the argument @tt{e_2}.
But how do we model that idea formally?
Well, we don't know how to do it with anything we've seen so far, and we have
only one way to add new things to our universe: we make a new judgment.

The new rule will be

@verbatim{
---------------
((λx.e) e_2) → e[e_2/x]
}

Where the right-hand side is the @emph{capture-avoiding substitution judgment}.

@subsection{Capture-Avoiding Substitution}
The judgment we need has a special name: substitution.
Sometimes, it is written like @tt{e[e_2/x] = e'}, meaning that the expressions
@tt{e'} that results from replacing all occurances of the name @tt{@emph{x}} in
@tt{@emph{e}} by the expression @tt{@emph{e@sub{2}}}.
@margin-note{Following the convention from earlier, we can just write
@tt{e[e_2/x]} to refer to @tt{e'}.}
This is the most common version used.
Unfortunately, PL theorists are sloppy, and it is also written as @tt{e[x/e_2]},
@tt{e[x := e_2]}, @tt{[e_2/x]e}, @tt{[x/e_2]e}, and about 15 different other
ways to date.

The idea for the judgment is simple: pattern match on an expression and, if it
is equal to @tt{x}, replace it.
We can start with the simple values for which the answer is obvious.

@box{e[e/x] = e}
@verbatim{

---------------- [Subst-True]
true[e/x] = true

---------------- [Subst-False]
false[e/x] = false

---------------- [Subst-Zero]
z[e/x] = z
}

@tt{true}, @tt{false}, and @tt{z} cannot possibly have any references to the
name @tt{x}, so substitution on them just equals the original term.

Another (sort of) easy one is the case for names @tt{x}.
There is a trick to this one, though.
@verbatim{

---------------- [Subst-X1]
x_1[e/x_1] = e

---------------- [Subst-X2]
x_2[e/x_1] = x_2
}

We have to split it into two cases: either we're at a name that is exactly the
same as the one we're trying to replace, and we replace it, or not and we leave
it alone.
These are rules are the heart of the idea of substitution: replace the name for
an argument by the argument.

Next we get to harder rules, like those with sub-expressions.
@verbatim{

??
---------------- [Subst-Plus]
(e_1 + e_2)[e/x] = ??

??
---------------- [Subst-If]
(if e_1 then e_2 else e_3)[e/x] = ??
}

Intuitively, we just want to keep replacing all the occurances of @tt{x} by @tt{e}.
So these are just recursive on the syntax of the expressions
@verbatim{

e_1[e/x] = e_1'    e_2[e/x] = e_2'
---------------- [Subst-Plus]
(e_1 + e_2)[e/x] = (e_1' + e_2')

e_1[e/x] = e_1'
e_2[e/x] = e_2'
e_3[e/x] = e_3'
---------------- [Subst-If]
(if e_1 then e_2 else e_3)[e/x] = (if e_1' then e_2' else e_3')
}

Finally, our new features: function and application.
@verbatim{

---------------- [Subst-Fun]
(λx.e_1)[e/x] = ??

---------------- [Subst-App]
(e_1 e_2)[e/x] = ??
}

At first glance, these look like more expressions with sub-expressions, so we
can just recursively substitute.

@verbatim{

e_1[e/x] = e_1'
---------------- [Subst-Fun-Wrong]
((λx.e_1) e_2)[e/x] = (λx.e_1')

---------------- [Subst-App]
(e_1 e_2)[e/x] = ((e_1[e/x]) (e_2[e/x]))
}
@margin-note{I use substitution infix in the @tt{[Subst-App]} rule, to give you
practice reading it.}

This is okay for the application case, but it is subtly wrong for the function case.
To see why, it helps to step through some examples.
Using our new rule,

@verbatim{
---------------
((λx.e) e_2) → e[e_2/x]
}

and our current definition of substitution, we can reduce some simple examples as follows.

@verbatim{
(λx.x) 0            -> 0
(λx.x) (λx.x)       -> (λx.x)
(λx.λy.x) false     -> λy.false
(λy.false) true     -> false
}

This seems to behave about right.
If we apply the identity function to 0, we get 0.
If we apply the identity function to another identity function, we the identity
function.
When we apply a function that returns another function whose body simply
references the first argument, we get back a new function whose body is the
first argument.

But these examples don't test an important case that is legal, but most
programmers would never consider.
What if we apply a function to a free variable?
This is not legal in most programming languages, but it is in our model.

@verbatim{
(λx.λy.x) y     -> λy.y
}

The problem is that now the binding structure has changed.
Previously, one could never refer to the value of the argument named @tt{y}.
The expression @tt{λx.λy.x} modeled a function of two argumenst that throws out
the second argument and returns the first.
But with our definition of substitution, we can access that second argument.

@verbatim{
(λx.λy.x) false true   ->* false
(λx.λy.x) y true       ->* true
}

Perverse programmers that write free variables are not the real problem.
Free variable can pop up naturally when reasoning about a program.
For instance, many optimizations and refactorings happen in the precense of free
variables, and we would like our reduction and conversion judgments to be able
to validate these rewrites.

To solve this, we have to make substitution avoid capturing even when substiting
a free variable into an expression.
The way we model this is easy: just rename a bound variable to a fresh one that
is never used anywhere else, then substitute.

@verbatim{
z is fresh
e_1[z/x] = e_2
e_2[e/x] = e_3
---------------- [Subst-Fun]
(λx.e_1)[e/x] = (λz.e_3)
}

It's hard to say exactly, formally, what we mean by "is fresh".
But we just suppose there is some infinite set of names to draw from, and we
know which ones have never been used.

You don't need to think about this capture-avoiding nonsense too hard, though.
Most programming languages people totally ignore the problem.
They know the problem exists, and they know a solution exists.
So we all just pretend like variable behave, and we avoid ever writing examples
for which there will be a problem.

@section{Computing with Judgments}
Now that we have a model of a realish language, we're like to be able to do
things with it.
Our judgments, when carefully designed, correspond to easily to recursive
functions.
Redex can automatically compute derivations for us for such judgments.
This is Extremely Handy, since writing derivations is tedious.

We'll start by modeling our new language in Redex.
The problems involved in modeling functions are so well understood that Redex
can solve them for you.
When writing a language in Redex, we just tell Redex which expressions should be
able to "refer to" names, and Redex will figure out how to implement
substitution for us.

@(define eg
  (make-base-eval "(require redex/reduction-semantics)"))
@examples[#:eval eg
(define-language L
  [b ::= true false]
  [n ::= z (s n)]
  [e ::= b n (e + e) (if e then e else e) (λ x e) (e e) x]
  [o ::= b n]
  [x ::= variable-not-otherwise-mentioned]
  #:binding-forms
  (λ x e #:refers-to x))

(code:comment "Tell Redex which language we mean when we don't say.")
(default-language L)

(term (substitute (λ y x) x y))
(term (substitute (λ y x) x true))
]

With substitution formally defined, our model of functions is pretty much done.
We can write our reduction judgment and start writing examples.

@examples[#:eval eg
(define-judgment-form L
  #:contract (→ e e)
  #:mode (→ I O)

  [-------------- "Step-Add-Zero"
   (→ (z + e) e)]

  [-------------------------------------------- "Step-Add-Add1"
   (→ ((s any_1) + any_2) (any_1 + (s any_2)))]

  [----------------- "Step-If-True"
   (→ (if true then any_1 else any_2) any_1)]

  [----------------- "Step-If-False"
   (→ (if false then any_1 else any_2) any_2)]

  [------------------------------- "Step-App"
   (→ ((λ x e) e_2) (substitute e x e_2))])
]

In this judgment, I introduce @emph{moded judgments} using the new form
@racket[#:mode (→ I O)].
This tells Redex that I expect the first expression to be an @emph{I}nput, and
the second to be an @emph{O}utput.

To ask Redex to compute the output of a judgment, we pass a meta-variable in the
output position, and use @racket[judgment-holds] like this:

@examples[#:eval eg
(judgment-holds (→ ((λ x x) false) e)
                e)
]

Since judgments can be non-deterministic, Redex returns a list of possible answers.
In this case, there is one answer.

To build the whole derivation, we use @racket[build-derivations].
We similarly get back a list of possible derivations.

@examples[#:eval eg
(build-derivations (→ ((λ x x) false) e))
]

Recall that our conversion judgment did not follow the rule about inductive
judgments getting smaller in the premises.
The consequences comes now.
@examples[#:eval eg
(define-judgment-form L
  #:contract (→*-unfortunate e_1 e_2)
  #:mode (→*-unfortunate I O)

  [(→ e_1 e_2)
   ----------------- "Step"
   (→*-unfortunate e_1 e_2)]

  [------------- "Refl"
   (→*-unfortunate e_1 e_1)]

  [(→*-unfortunate e_1 e_2)
   (→*-unfortunate e_2 e_3)
   ------------------ "Trans"
   (→*-unfortunate e_1 e_3)]

  [(→*-unfortunate e_1 e_11)
   ------------------- "If-Compat-e1"
   (→*-unfortunate (if e_1 then e_2 else e_3) (if e_11 then e_2 else e_3))]

  [(→*-unfortunate e_2 e_21)
   ------------------- "If-Compat-e2"
   (→*-unfortunate (if e_1 then e_2 else e_3) (if e_1 then e_21 else e_3))]

  [(→*-unfortunate e_3 e_31)
   ------------------- "If-Compat-e3"
   (→*-unfortunate (if e_1 then e_2 else e_3) (if e_1 then e_2 else e_31))]

  [(→*-unfortunate e_1 e_11)
   --------------------- "Plus-Compat-e1"
   (→*-unfortunate (e_1 + e_2) (e_11 + e_2))]

  [(→*-unfortunate e_2 e_21)
   --------------------- "Plus-Compat-e2"
   (→*-unfortunate (e_1 + e_2) (e_1 + e_21))]

  [(→*-unfortunate e_1 e_11)
   (code:comment "Oh look, a free variable")
   --------------------- "Fun-Compat"
   (→*-unfortunate (λ x e_1) (λ x e_11))]

  [(→*-unfortunate e_1 e_11)
   --------------------- "App-Compat-e1"
   (→*-unfortunate (e_1 e_2) (e_11 e_2))]

  [(→*-unfortunate e_2 e_21)
   --------------------- "App-Compat-e2"
   (→*-unfortunate (e_1 e_2) (e_1 e_21))])
(require racket/sandbox)
(eval:error
 (with-limits
  5 (code:comment "seconds")
  512 (code:comment "mbytes")
  (judgment-holds (→*-unfortunate ((λ x (x + (s z))) (s z)) e) e)))
]

We try to turn this into a moded judgment, but Redex fails to find a derivation
within 5 seconds.
Redex infinitely searches for a derivation by infinitely applying the
@racket["Trans"] rule.
The judgment does not easily correspond to a simple recursive function, so Redex
does not know what else to do.
We have to do work to translate this into a nice computable judgment.

This applies more generally in PL theory.
If a judgment is not obviously a recursive function, then it is @emph{only} a
specification, and does not necessarily yield an implementation.
Any proof about that judgment may require @emph{more work} before it can be
applied to any real implementation.

Thankfully, for our conversion judgment, the work is relatively simple.
We force @emph{something} to always get smaller.
We split the judgment into two: one that either reduces something or
(recursively) reduces some sub-expression, and one with the reflexivity and
transitivity rules.


@examples[#:eval eg
(define-judgment-form L
  #:contract (→+ e_1 e_2)
  #:mode (→+ I O)

  [(→ e_1 e_2)
   ----------------- "Step"
   (→+ e_1 e_2)]

  [(→+ e_1 e_11)
   ------------------- "If-Compat-e1"
   (→+ (if e_1 then e_2 else e_3) (if e_11 then e_2 else e_3))]

  [(→+ e_2 e_21)
   ------------------- "If-Compat-e2"
   (→+ (if e_1 then e_2 else e_3) (if e_1 then e_21 else e_3))]

  [(→+ e_3 e_31)
   ------------------- "If-Compat-e3"
   (→+ (if e_1 then e_2 else e_3) (if e_1 then e_2 else e_31))]

  [(→+ e_1 e_11)
   --------------------- "Plus-Compat-e1"
   (→+ (e_1 + e_2) (e_11 + e_2))]

  [(→+ e_2 e_21)
   --------------------- "Plus-Compat-e2"
   (→+ (e_1 + e_2) (e_1 + e_21))]

  [(→+ e_1 e_11)
   (code:comment "Oh look, a free variable")
   --------------------- "Fun-Compat"
   (→+ (λ x e_1) (λ x e_11))]

  [(→+ e_1 e_11)
   --------------------- "App-Compat-e1"
   (→+ (e_1 e_2) (e_11 e_2))]

  [(→+ e_2 e_21)
   --------------------- "App-Compat-e2"
   (→+ (e_1 e_2) (e_1 e_21))])

(define-judgment-form L
  #:contract (→* e_1 e_2)
  #:mode (→* I O)

  [------------- "Refl"
   (→* e_1 e_1)]

  [(→+ e_1 e_2)
   (→* e_2 e_3)
   ------------------ "Trans"
   (→* e_1 e_3)])

(judgment-holds (→* ((λ x (x + (s z))) (s z)) e) e)
]

Now we can finish our evaluation function, and we get a runnable model of an interpreter.
@examples[#:eval eg
(define-judgment-form L
  #:contract (eval e o)
  #:mode (eval I O)

  [(→* e o)
   ----------
   (eval e o)])

(judgment-holds (eval ((λ x (x + (s z))) (s z)) o) o)
]
