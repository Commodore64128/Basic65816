
100 for i = 1 to 9
110 	print i,i*i,i*i*i
120 next i
122 x = 4
123 while x > 0
125 gosub 140:gosub 140
127 x = x-1
128 wend
129 end
130 stop
140 print "Hello, world!",x
150 return