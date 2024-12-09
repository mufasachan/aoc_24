declare disk
read -r disk <"$1"
echo "$disk"
# stack from left to right of the element
# file_stack only have element (digit) and disk_stack only have position
declare -a file_stack disk_stack

count_file=0
n=$(wc -c < "$1")
for ((i = 0; i < n; i++)); do
	input_value=${disk:i:1}
	# odd = disk_stack
	if ((i % 2)); then
		disk_stack[i / 2]=$input_value
	else
		# even = file_stack
		n_files=${disk:i:1}
		for ((j = count_file; j < count_file + n_files; j++)); do
			((file_stack[j]=i/2))
		done
		((count_file+=n_files))
	fi
done

echo "F: ${file_stack[*]}"
echo "D: ${disk_stack[*]}"

# for i in 0 n_stack final_disk
# 	if i is even (file_stack)
# 		append file_stack
# 	else
# 		append the corresponding number of disk_stack[i] from the top of final stack
declare -a final_disk
i_start_files=0 start_file_id=0 
((i_end_files=${#file_stack[@]} - 1))
for (( i = 0; i < n; i++)); do
	# odd = fill empty space
	if ((i%2)); then
		for ((j = 0; j < disk_stack[i / 2]; j++)); do
			final_disk+=("${file_stack[$i_end_files]}")
			((i_end_files--))
			((i_start_files > i_end_files)) && break
		done
	else
		while ((file_stack[i_start_files] == start_file_id && i_start_files <= i_end_files)); do
			final_disk+=("${file_stack[$i_start_files]}")
			((i_start_files++))
		done
		start_file_id=${file_stack[i_start_files]}
	fi
	((i_start_files > i_end_files)) && break
done

echo "F: ${final_disk[*]}"

score=0
for (( i = 0 ; i < ${#final_disk[@]}; i++)); do
	((score+=i*final_disk[i]))
done
echo $score
