                      Russian Stress  with Ruby
                     (with Ruby187 on Windows Xp)

 This project is based on the work of Jan Daciuk (http://www.jandaciuk.pl/fsa.html). It's main goal  is to  help me learn russian. I wanted to add stress marks to webpages while reading them online. 

When the  stress position  depends on meaning, case, tense or other external factors, the task of assigning stress is best left to the human learner. 

Therefore,  the present  stress engine only deals  with context independent stress.

The   engine  has 3 parts:
1)  server.rb,  opens a webrick local server on port 8080
1)  dict.fsa,  a binary file, holds a list of accented word forms 
3)  accentuate.url, a  bookmarklet, sends requests to the server 

Warning: I use Firefox 52 on Windows Xp.  No attempt was made to adapt the bookmarlet to other browsers. 

How to install: 
1) keep server.rb and dict.fsa in the same folder
2) Click and drag accentuate.url to the Bookmarks Toolbar 

How to use:
1) launch  server.rb
2) open a web page  with Firefox (for instance, http://gippius.com/lib/short-story/gorny-kizil.html)
3) select text (word, sentence, paragraph or even the whole page ) 
4) click the bookmarklet (on the Bookmarks Toolbar)

Remarks.
1) The bookmarlet sends  "GET" requests to the server. Firefox 52 sets no limit on the length of  URLs. Hence, the length of  selected text doesn't matter.
2) The  binary file "dict.fsa"   is the serialization of a DAWG described in the  project "dawg-with-ruby" on github.
3) The folders "alternative_stress_engine, "post_request" and "stress_in_popups", are experiments with new ideas, "POST" requests,  tooltips and simple unsigned webextensions. 

To do:
1) Correct and complete the dictionary "dict.fsa".
2) A  dictionary of hints and reminders would be useful in those cases where the stress depends on context.



