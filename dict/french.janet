#!/usr/bin/env janet

(use sh)

(def input-file "./input.txt")

# pull in words from input all at once :)
# todo: handle phrases, ie words with spaces
(def words-list
  (peg/match
   ~{
     :main (some (* :line "\n"))
     :line (<- (to :s))
    }
   (slurp input-file)))


(def dict-result-peg
  ~{
    :main  (* :found-line
              :info-line
              :definition-line
              :translation-line)
    :found-line (* :d+ " definition" (any "s") " found" :s)
    :info-line (* :words :s :d+ :s :words :s :words :s)
    :definition-line (* :s+ (<- :term) :s+ (<- :pronunciation)
                        :s+ (<- :pos) :s)
    :translation-line (* :s+ (<- (any 1)))
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
** Word Specifics
** Example Sentence
** Example Sentence Eng
** Example Sentence 2
** Example Sentence 2 Eng
** Example Sentence 3
** Example Sentence 3 Eng
** Recording
** Compound
** Plural
** Past Participle

``` (result 0)
                 (result 0)
                 (string/replace "  " "" (result 3))
                 gender
                 (result 1)))

# open our files
(def output (file/open "output.org" :w))
(def failures (file/open "failures.txt" :a))

# add the header to the output :)
(file/write output ```
:PROPERTIES:
:ANKI_DECK: 03 - French
:ANKI_TAGS: nf
:END:

```)

(each word words-list
  (print "trying " word ":")
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

# and, if we got this far without fail, erase input
(spit input-file "")

# todo
# 1) a way to handle inflections
# 2) ignore empty string
