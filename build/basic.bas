20 addr = 2 * 65536 + 4 * 4096
30 for ix = 0 to 8
40 print str$(ix+addr,16),str$(peek(ix+addr),16)
50 next ix
60 print

70 loke addr+2,-42

130 for ix = 0 to 8
140 print str$(ix+addr,16),str$(peek(ix+addr),16)
150 next ix

160 stop