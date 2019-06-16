#
#		Runs the garbage collect test for ever.
#
while true
do
	#
	#		Creates a basic script with garbage collectable strings by
	#		using "asdas"+"" then makes sure none of the G/C stuff should
	#		be there after G/C. The script checks the strings are the
	#		same, the following call checks there is no "garbage" left over.
	#
	sh exec.sh make_gc.py
	#
	#		This checks that there is no text that should have been
	# 		collected away.
	#
	python ../scripts/showdump.py gc
done
