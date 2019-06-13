
10 	x = 1
20	repeat
25 		print "X = ";x
28 		on x goto 100,200,300,400
30		x = x + 1
40	until x = 5
50 	stop

100	print "100":goto 30
200	print "200":goto 30
300	print "300":goto 30
400	print "400":goto 30
