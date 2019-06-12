10 	x = 0
20 	cls:print "X is now ";x
25  c = 1:gosub 100
27  c = 2:gosub 100
28  c = 3:gosub 100
30  let x = x + 1
40 	goto 20

100 print "In subroutine #";c
110 return
