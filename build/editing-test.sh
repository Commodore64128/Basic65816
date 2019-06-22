#
#		Do modification infinite loop
#
while true 
do
	sh exec.sh make_editor.py
	python ../scripts/check_editor.py
done

