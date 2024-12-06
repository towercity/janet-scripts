#!/usr/bin/env janet

(use sh)
(import cmd)

(cmd/def word (required :string))

(def def
  ($< dict -d fd-fra-eng ,word -f))

# (prin def)

(def peg
  ~{
    :main  (* :found-line :info-line :definition-line :translation-line)
    :found-line (* :d+ " definition" (any "s") " found" :s)
    :info-line (* :words :s :d+ :s :words :s :words :s)
    :definition-line (* :s+ (<- :term) :s+ (<- :pronunciation)
                         :s+ (<- :pos) :s)
    :translation-line (* :s+ (<- :a+))
    :term (to :s)
    :pronunciation (* "/" (to "/") "/")
    :pos (* "<" (to ">") ">")
    :words (any (+ :a :d "." "-" " "))
   })

(def result (peg/match
              peg def))
(def gender (cond
              (string/find "masc" (result 2)) "m"
              (string/find "fem" (result 2)) "f"
              ""))

(def flashcard (string/format ```
* %s
:PROPERTIES:
:ANKI_NOTE_TYPE: French
:END:
** Word
%s
** English
%s
** Gender
%s
** Pronunciation
%s
``` (result 0) (result 0) (result 3) gender (result 1)))

(print flashcard)

# todo
# 1) handle failed dict calls
# 2) take in multiple words, add mmultiple results
