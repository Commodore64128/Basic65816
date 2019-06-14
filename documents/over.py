for b in range(2,16+1):
	v = 0x7FFFFFFF
	m = 1
	while m < v:
		m = m * b
	print("{0:x} {1:x} {2:x}".format(v,m,m & 0xF80000000))