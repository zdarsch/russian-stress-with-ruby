#ruby187 on Windows Xp
require 'cgi'
require 'webrick'
include WEBrick
f=File.open("dict.fsa", "rb")
#The project uses the font "Timesse Russ" (http://www.cyrillic.com/),a modified version of "windows-1251" with accented vowels.
E={}
for i in (0 .. 255) do  E[i]= i end
E[129]=224  #a grave => a
E[131]=229  #je grave => je
E[140]=232  #i grave => i
E[144]=224  #a acute => a
E[154]=229  #je acute => je
E[156]=238  #o grave => o
E[157]=232  #i acute => i
E[158]=238  #o acute => o
E[159]=243  #u acute => u
E[161]=243  #u grave => u
E[165]=251  #y grave => y
E[178]=251  #y acute => y
E[179]=253  #e acute => e
E[184]=229  #jo => je
E[186]=254  #ju acute => ju
E[188]=253  #e grave => e 
E[189]=254  #ju grave => ju
E[190]=255  #ja grave => ja
E[191]=255  #ja acute => ja
 # hash to convert from windows-1251 to unicode
W2u=Hash.new(63)
W2u.store(168, 1025) # YO
W2u.store(184, 1105) # yo
W2u.store(185, 8470) # N°
W2u.store(150, 8211) # en dash
W2u.store(151, 8212) # em dash
W2u.store(133, 8230) # ellipsis
W2u.store(171, 171)   # <<
W2u.store(187, 187)   # >>
(0 .. 126).each{ |x| W2u.store(x, x) } # ascii
(192 .. 255).each{|x| W2u.store(x, x+848)}
 # hash to convert from unicode to standard "windows-1251".  
U2w=Hash.new(63)
U2w.store(1025, 168) # YO
U2w.store(1105, 184) # yo
U2w.store(8470, 185) # N°
U2w.store(8211, 150) # en dash
U2w.store(8212, 151) # em dash
U2w.store(8230, 133) # ellipsis
U2w.store(171, 171) # <<
U2w.store(187, 187) # >>
(0 .. 126).each{ |x| U2w.store(x, x) } # ascii
(1040 .. 1103).each{|x| U2w.store(x, x-848)}

class Node
attr_accessor  :edges 
def initialize	
	@edges=[]
end
end#Node

h = Hash.new { |hash, key| hash[key] = Node.new }
x, edge = 0, []
while s=f.read(4) do# s.length <= 4
if s[1]&4==4 then # target_is_next 
f.pos = f.pos - s.length + 2 # s.length <= 4 
edge=[ s[0], x+1, s[1]&7 ]
else
edge=[ s[0], (s[1]>>3) + (s[2]<<5) + (s[3]<<13), s[1]&7 ] 
end
h[x].edges << edge
x+=1 if s[1]&2==2# edge is last_in_node
end#while


$candidate=[]
$replacements=[]

def dfs(n, h, wd, level)
i=level
node=h[n]
node.edges.each do |edge|
	letter=edge[0]
if E[letter]==wd[i] then
        $candidate[i]=edge[0].chr
	if i+1==wd.length && edge[2]&1==1  then 
	$replacements<<$candidate.to_s
        else
         dfs(edge[1], h, wd, i+1)
        end#if2	
end#if1
end#each
end#dfs

server = WEBrick::HTTPServer.new(:Port => 8080)
server.mount_proc("/stress") do |request, response|
# request is a "post" request.

if request.body
    str = request.body
# The selected text was percent encoded by Firefox.
    str=CGI.unescape(str)

#conversion to windows 1251  
   str=str.unpack("U*").map{ |x| U2w[x] }.pack("C*")

# Prepare  response body
chunks=[]

# Add stress marks
s0="-\300-\377\250\270"
str.scan(/[#{s0}]+|[^#{s0}]+/m) do |wd|
(chunks<<wd ; next) if wd=~/[^#{s0}]+/ 
dfs(0, h, wd, 0)
if $replacements.empty? then chunks<<wd else chunks<< $replacements[0] end
$candidate.clear
$replacements.clear
end#scan

body=chunks.to_s

# Convert from "Timesse Russ" to standard "windows-1251". Stress marks are placed after the accented vowel. A single quote means main stress, a backtick means secondary stress.
s1 = "\220\232\235\236\237\262\263\272\277"
s2 = "\201\203\214\234\241\245\274\275\276"
s3 = "\340\345\350\356\363\373\375\376\377"
body= body.gsub(/[#{s1}]/){$&.tr(s1, s3)+"'"}
body= body.gsub(/[#{s2}]/){$&.tr(s2, s3)+"\`"}
# conversion back to unicode
body=body.unpack("C*").map{ |x| W2u[x] }.pack("U*")

    response.status = 200
    response.content_type = 'text/html'
    response.body = body
    end#if request.body
  end#mount_proc

  server.start


