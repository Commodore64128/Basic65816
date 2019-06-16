while true
do
	sh exec.sh test_creation.py
	sh exec.sh test_comparison.py
	sh exec.sh test_func.py
	sh exec.sh test_maths.py
	sh exec.sh test_change.py
	sh exec.sh make_gc.py
	python ../scripts/showdump.py gc
	sh exec.sh make_tok.py
done

