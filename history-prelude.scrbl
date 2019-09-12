#lang scribble/manual

@title{Interlude 1: A History of Syntax}
Into the 70s and 80, denotational semantics were the primary method used for
modeling programming languages.
These techniques essentially compiled a programming language model into math,
allowing programming language theorists to reuse the theories and theorems from
contemporary mathematics.

.. examples ...

However, these techniques had limits.
PL theorists struggled to provide denotations for complex language features,
such as control effects and state.
PL theorists still struggle to give good denotational models of these features,
although they do exist now.

In the 90s, purely syntactic approaches to common theorems, such as type
soundness, and to modeling complex language features, such as control effects,
started to appear.
Syntactic approachs were required no background knowledge of contemporary
mathematics, modeled programming reasoning, and were scaling better than
denotational approaches.
However, they also made theory and theorem reuse difficult.
In the United States, where they first appeared, they became and remain the
dominant method for modeling programming languages.

In recent years, syntactic approach have (at least in part) been responsible for
confusion in programming language theory.
When using syntactic approaches, we can easily confuse proof for truth.
The syntactic model corresponds to a particular proof theory.
A meta-theorem about that proof theory doesn't necessarily tell us anything
about ground truth.

...

In this book, I describe a syntactic approach to programming language theory.
I don't do this asserting that it is the best approach.
In fact, I often wish I were better at denotational approaches.
I've seen colleagues leverage denotational semantics to great effect, importing
theories and theorems and applying them to solve problems.
But syntactic approaches are powerful, more accessible (I think), and allow the
theorist to provide a model a programmer can easily use.
