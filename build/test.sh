#
#		Runs the basic tests .... until you get bored or the lack of Garbage collection (at the time of writing)
#		causes chaos.
#
while true; do
	sh exec.sh test_creation.py
	sh exec.sh test_comparison.py
	sh exec.sh test_func.py
	sh exec.sh test_maths.py
	sh exec.sh test_change.py
done
#sh exec.sh make_gc.py
#python ../scripts/showdump.py gc

