# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		calctime.py
#		Purpose :	Calculate approx time from CPU Instructions Executed
#		Date :		13th June 2019
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

mips = 3.1 					
cycles = int(open("cpu.count").readline())
print("Executed {0}k CPU Cycles".format(int(cycles/1024)))
print("65816 at 14Mhz is {0} MIPS".format(mips))
time = cycles/(mips * 1000000)
print("Elapsed time is {0:.2f} secs".format(time))