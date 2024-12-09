declare disk
read -r disk <"$1"

n=$(wc -m < "$1")
i_block=0
declare -a stack
for ((i = 0; i < n-1; i++)); do
	width=${disk:i:1}
	stack[i]="$i_block,$width"
	((i_block+=width))
done

score=0
for ((i_file = ${#stack[@]} - 1; i_file >= 0; i_file-=2)); do
	((file_value=i_file/2))
	IFS=',' read -r i_file_block width_file <<<"${stack[i_file]}" 

	# Find a disk hole
	has_space=0
	for ((i_disk=1; i_disk < i_file; i_disk+=2)); do
		IFS=',' read -r i_disk_block width_disk <<<"${stack[i_disk]}" 

		# keep going if too small
		if (( width_disk < width_file )); then 
			continue
		fi

		for ((j = i_disk_block; j < i_disk_block + width_file; j++)); do
			((score+=file_value*j))
		done

		((width_disk-=width_file))
		((i_disk_block+=width_file))
		stack[i_disk]="$i_disk_block,$width_disk"
		has_space=1
		break
	done

	if ((has_space == 0)); then
		for ((j = i_file_block; j < i_file_block + width_file; j++)); do
			((score+=file_value*j)) 
	done

	fi
done

echo $score

