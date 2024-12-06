#!/usr/bin/env janet

(use sh)
(import cmd)

# (cmd/def word (required :string))

# (def definition
#   ($< dict -d fd-fra-eng ,word -f))

# (prin definition)

(def test-def ```
1 definition found
dict.org	2628	fd-fra-eng	French-English FreeDict Dictionary ver. 0.4.1
  je /ʒə/ <pron>
  I
```)

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
              peg test-def))

(pp result)
(print (result 1))
