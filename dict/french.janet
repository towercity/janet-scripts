#!/usr/bin/env janet

(use sh)

# pull in words from input all at once :)
(def words-list
  (peg/match
   ~{
     :main (some (* :line "\n"))
     :line (<- (to :s))
    }
   (slurp "./input.txt")))


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

# open our files
(def output (file/open "output.org" :w))
(def failures (file/open "failures.txt" :w))

# add the header to the output :)
(file/write output ```
:PROPERTIES:
:ANKI_DECK: 03 - French
:ANKI_TAGS: nf
:END:

```)

(each word words-list
  (try
    (do
      (def def
        ($< dict -d fd-fra-eng ,word -f))
      (file/write
       output (get-flashcard-from-dict-result
               # getting the dict result all the way down here
               ($< dict -d fd-fra-eng ,word -f))))
    
    ([err fiber]
     (file/write failures
                 (string/format "%s\n" word)))))

(file/flush output)
(file/flush failures)
(file/close output)
(file/close failures)

# todo
# 1) take in multiple words, add mmultiple results
# 2) a way to handle inflections
