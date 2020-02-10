#lang scribble/manual

@title{CPSC 539B -- Compiler Theory}

Compilers are responsible for writing almost all of the programs that get
executed. Like all programs, compilers have bugs. But unlike most programs, when
compilers have bugs, they can insert bugs into other peoples’ code and give
programmers little recourse.

All compilers have bugs, and this course will teach you what a compiler bug is,
how to reason about compilers so you better understand where the bugs are and
how to prevent bugs if you ever write a compiler. This course will introduce
some techniques of formal reasoning about programs, programming languages, and
compilers. The course will then review recent compiler correctness research, and
study the different ways a compiler can be correct, or incorrect, and how to
implement a correct compiler and prove that it’s correct.

My goals with this course are:

@itemlist[
@item{Introduce students to reasoning about programs and program transformations.}
@item{Introduce students to space of compiler correctness.}
@item{Convince students to think about compilers in terms of judgments preserved.}
]

@(local-table-of-contents)

@section{Announcements and Changes}

@subsection{Announcements}
@itemlist[
@item{Feb. 10, 2020 11:01 -- Remove logical relations from calendar; replace by linking and assembly, which actually happened.}
@item{Feb. 5, 2020 21:57 -- Added Lecture 5 notes (part 1 of proof by induction).}
@item{Feb. 3, 2020 21:40 -- Added homework two, due Feb 24, 2020 23:59 by email.}
@item{Feb. 3, 2020 21:21 -- Added live code from Lecture 6. @url{share/lecture6-live-code.rkt}.}
@item{Jan. 29, 2020 22:28 -- Added homework one complete on-paper solution @url{share/hw1-solution-on-paper.pdf}.}
@item{Jan. 29, 2020 20:33 -- Added Lecture 4 notes.}
@item{Jan. 29, 2020 19:35 -- Added homework one solution for written proofs @url{share/hw1-solution.pdf}.}
@item{Jan. 29, 2020 15:55 -- Added calendar.}
@item{Jan. 28, 2020 22:39 -- Added homework one solution @url{share/hw1-solution.rkt}.}
@item{Jan. 14, 2020 20:41 -- Added homework one, due Jan. 24, 2020 23:59 by email.}
@item{Jan. 14, 2020 20:41 -- Added lectures notes for Lecture 3. These include important additional material that was not in the lectures.}
@item{Jan. 14, 2020 13:59 -- Uploaded code from Lecture 3. @url{share/lecture3-live-code.rkt}}
@item{Jan. 12, 2020 17:11 -- Updated Lecture 2 notes with on-paper notation version of final proof.}
@item{Jan. 11, 2020 19:20 -- Added lecture notes for Lecture 2.}
@item{Jan. 8, 2020 17:03 -- Uploaded code from Lecture 2. @url{share/lecture2-live-code.rkt}}
@item{Jan. 7, 2020 18:11 -- There will be no class nor office hours Jan 20--Jan 24 as I will be attending a POPL.}
@item{Jan. 6, 2020 22:24 -- Added lecture notes for Lecture 1.}
]

@subsection{Changes}
@itemlist[
@item{Jan. 7, 2020 18:11 -- Changed Tuesday office hours to Thursday.}
@item{Jan. 7, 2020 19:46 -- Finished notes for Lecture 1: More details about judgments, in derivations Lecture 1 notes. Finished modeling a language's collection of expressions.}
]

@include-section{syllabus.scrbl}
@;include-section{history-prelude.scrbl}
@include-section{calendar.scrbl}
@include-section{lecture1.scrbl}
@include-section{lecture2.scrbl}
@include-section{lecture3.scrbl}
@include-section{hw1.scrbl}
@include-section{lecture4.scrbl}
@include-section{hw2.scrbl}
@include-section{lecture5.scrbl}
