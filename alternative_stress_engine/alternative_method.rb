# Ruby 1.8.7 on windows Xp

f=File.open("words_43kb.fsa", "rb")

class Node
attr_accessor  :edges 
def initialize	
	@edges=[]
end
end#class Node


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

# depth first search
def dfs(n, h, wd, level, index)
k=index # of a character
i=level # of depth
node=h[n]
node.edges.each do |edge|
letter=edge[0]
 case   letter
when  wd[k] 
	  $candidate[i]=letter.chr
	  if k+1==wd.length && edge[2]&1==1  then 
          $replacements<<$candidate.to_s
	  else
         dfs(edge[1], h, wd, i+1, k+1)
         end#if
        
when 34, 39, 96  # diaeresis, acute, grave
        $candidate[i]=letter.chr
        if  k==wd.length && edge[2]&1==1  then
	$replacements<<$candidate.to_s
	else
       dfs(edge[1], h, wd, i+1, k)
        end#if
end#case
end#each
end#dfs

words=File.readlines("words_5856.txt")
words.each do |word| 
wd=word.strip.gsub(/[\042\047\140]/, "") # delete stress marks	
 dfs(0, h, wd, 0, 0)
 
puts $replacements 
$candidate.clear
$replacements.clear
end#
 