#!/usr/bin/env janet

(use sh)
(import cmd)

(cmd/def word (required :string))

(def def
  ($< dict -d fd-fra-eng ,word -f))

(prin def)

(def peg
  ~{
    :main  (* :found-line :info-line :definition-line :translation-line)
    :found-line (* :d+ " definition" (any "s") " found" :s)
    :info-line (* :words :s :d+ :s :words :s :words :s)
    :definition-line (* :s+ (<- :term) :s+ (<- :pronunciation)
                         :s+ (<- :pos) :s)
    :translation-line (* :s+ (<- :a+))
    :term (any (+ :a "-"))
    :pronunciation (* "/" (to "/") "/")
    :pos (* "<" :a+ ">")
    :words (any (+ :a :d "." "-" " "))
   })

(def result (peg/match
              peg def))

(pp result)
(print (result 1))
