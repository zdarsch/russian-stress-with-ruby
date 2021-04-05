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

class Node
attr_accessor  :edges 
def initialize	
	@edges=[]
end
end#Node


class String
# (2<= (string.length) <=4)	
def label
return self[0]
end

def flags
return self[1]&7
end

def node_final?
return self[1]&2==2
end

def target_is_next?
return self[1]&4==4
end
	
def target
return  (self[1]>>3) + (self[2]<<5) + (self[3]<<13)
end

end#String

h = Hash.new { |hash, key| hash[key] = Node.new }
x, edge = 0, []
while s=f.read(4) do# s.length <= 4
if s.target_is_next? then 
f.pos = f.pos - s.length + 2 # s.length <= 4 
edge=[ s.label, x+1, s.flags ]
else
edge=[ s.label, s.target, s.flags ] 
end
h[x].edges << edge
x+=1 if s.node_final?
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
    server.mount_proc("/accent") do |request, response|
# request is a "get" request.
     if selection = request.query['text'] then
# The selected text was percent encoded by Firefox.
    selection=CGI.unescape(selection)
#Convert from utf-8 to standard "windows-1251".
 a=selection.unpack('U*')
chars=[]
a.each{|i| 
case i
when 0 .. 127, 171, 187        then   chars<<i.chr
when 1040 .. 1103                then   i=i-848; chars<<i.chr 
when 1105                            then    chars<<"\270"   # yo
when 1025                            then    chars<<"\250"    # YO
when 8470                            then     chars<<"\271"    # N°
when 8211                            then     chars<<"\226"    # en dash
when 8212, 8213                  then     chars<<"\227"    # em dash
when 8230                            then     chars<<"\205"    # ellipsis
end
}
# Selected text in standard "windows-1251" encoding:
selection=chars.to_s

# Prepare the response body
chunks=[]
chunks<<"<body style=\"background-color:#f8f8f8;color:#000050\">\n"

# Add stress marks
selection.scan(/[-À-ÿ¨¸]+|[^-À-ÿ¨¸]+/m) do |wd|
(chunks<<wd ; next) if wd=~/[^-À-ÿ¨¸]+/ 
dfs(0, h, wd, 0)
if $replacements.empty? then chunks<<wd else chunks<< $replacements[0] end
$candidate.clear
$replacements.clear
end#scan

chunks<<"\n</body>"
body=chunks.to_s

# Convert from "Timesse Russ" to standard "windows-1251". Stress marks are placed after the accented vowel. A single quote means main stress, a backtick means secondary stress.
s1, s2, s3 = "šŸ²³º¿", "ƒŒœ¡¥¼½¾", "àåèîóûışÿ"
body= body.gsub(/[#{s1}]/){$&.tr(s1, s3)+"'"}
body= body.gsub(/[#{s2}]/){$&.tr(s2, s3)+"\`"}
# If "Timesse Russ" is installed, the three preceding 
# lines can be deleted.

    response.status = 200
    response.content_type = 'text/html; charset=windows-1251'
    response.body = body
    end#if selection=request.query['text']
  end#mount_proc

  server.start


