while true; do
	datetime=$(date '+%Y-%m-%d %H:%M:%S')
	buttery=$(acpi | cut -d ' ' -f 3-4)
	echo "$datetime $buttery"
	sleep 1
done
