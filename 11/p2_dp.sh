process_stone() {
	local stone="$1" n="$2"
	local -n score_stone="$3"

	if ((n == 0)); then
		((score_stone++))
		return
	fi

	local key_cache="$stone,$n"
	if ((cache[$key_cache])); then
		((score_stone += cache[$key_cache]))
		return
	fi

	((n--))
	local -i score_memory
	((score_memory = score_stone))
	local length=${#stone}

	local -i left=0 right=0
	if ((stone == 0)); then
		process_stone 1 $n $3
	elif (((length % 2) == 0)); then
		((left="${stone:0:length/2}"))
		((right="10#${stone:length/2}"))

		process_stone $left $n $3
		process_stone $right $n $3
	else
		((left = 2024 * stone))
		process_stone $left $n $3
	fi

	((cache[$key_cache] = score_stone - score_memory))
}

n_blinks=75
read -ra stones <"$1"
declare -A cache=()

declare -i score=0
for stone in "${stones[@]}"; do
	process_stone $stone $n_blinks score
done
echo $score
