#!/usr/bin/env janet

(use sh)
(import cmd)

(cmd/def word (required :string))

(def dict-result-peg
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


(defn get-flashcard-from-dict-result [def]
    (def result (peg/match
                 dict-result-peg def))
    (def gender (cond
                  (string/find "masc" (result 2)) "m"
                  (string/find "fem" (result 2)) "f"
                  ""))
    
    (string/format ```
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

(try
  (do
    (def def
      ($< dict -d fd-fra-eng ,word -f))
    (print (get-flashcard-from-dict-result def)))
  
  ([err fiber]
   (print "failed")))

# todo
# 1) take in multiple words, add mmultiple results
