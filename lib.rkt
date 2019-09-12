#lang racket/base

(require
 racket/function
 scribble/core
 scribble/manual
 scribble/html-properties)

(provide
 (all-defined-out))

(define box-style
  (make-style "fbox" (list (make-css-addition "fbox.css"))))

(define box
   (curry elem #:style box-style))

(define sub (curry elem #:style 'subscript))

