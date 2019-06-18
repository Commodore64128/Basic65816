5 rem "A test program 2"
10 cls
15 screenRam = 15 * 65536
20 for i = 0 to 255
30 poke screenRam+4*64+i,i
40 next i
50 end
