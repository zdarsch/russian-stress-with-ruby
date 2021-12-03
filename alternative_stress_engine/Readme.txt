

"words_5856.txt" is a lexicographically sorted list of 5856 stressed russian word forms without repetitions. The stress marks  ( acute, grave, diaeresis) follow the vowel. The minimal fsa "words_43kb.fsa" recognizes the list. 

The script "alternative_method.rb" takes each word, deletes the stress marks and feeds the word to the stress engine. 

The deletion of stress marks made repetitions appear in the list. No wonder that the output of the stress engine  contains even more repetitions.


