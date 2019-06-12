while true; do
	sh exec.sh make_gc.py
	python ../scripts/showdump.py gc
done