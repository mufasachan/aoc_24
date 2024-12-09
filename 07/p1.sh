declare -r ADD=0 MUL=1

increment_operators() {
	local -n operators_ref=$1
	local i_step=$2
	local -n i_operator_changed_max_ref=$3

	local remainder=1
	while ((i_step >= 0 && remainder)); do
		case "${operators_ref[i_step]}" in
		"$MUL")
			operators_ref[i_step]=$ADD
			remainder=1
			;;
		*)
			((operators_ref[i_step]++))
			remainder=0
			;;
		esac
		((i_step--))
	done
	((i_operator_changed_max_ref = i_step + 1))
}

compute_operation() {
	local lmember=$1 op=$2 rmember=$3
	local -n out=$4

	case "$op" in
	"$ADD")
		((out = lmember + rmember))
		;;
	"$MUL")
		((out = lmember * rmember))
		;;
	esac
}

score=0
while read -r line; do
	result="${line%:*}"
	read -ra numbers <<<"${line#[0-9]*:}"

	((n_operators = ${#numbers[@]} - 1))
	((i_last_operator = n_operators - 1))
	((operators_max = 2 ** (n_operators)))
	count_operators=0

	declare -a result_cum operators
	for ((i = 0; i < n_operators; i++)); do
		operators[i]=0
		if ((i == 0)); then
			compute_operation ${numbers[i]} $ADD ${numbers[i + 1]} result_cum[i]
		else
			compute_operation ${result_cum[i - 1]} $ADD ${numbers[i + 1]} result_cum[i]
		fi
	done

	if ((result_cum[i_last_operator] == result)); then
		((score += result))
		continue
	fi

	declare i_operator_changed_max
	((i_step = i_last_operator))
	operators_can_do=0
	while ((count_operators < operators_max)); do
		# Increment by the step
		increment_operators operators $i_step i_operator_changed_max
		((count_operators += 2 ** (i_last_operator - i_step)))

		cum_sum_too_big=0
		for ((i = i_operator_changed_max; i < n_operators; i++)); do
			if ((i == 0)); then
				compute_operation "${numbers[i]}" "${operators[i]}" "${numbers[i + 1]}" result_cum[i]
			else
				compute_operation "${result_cum[i - 1]}" "${operators[i]}" "${numbers[i + 1]}" result_cum[i]
			fi

			if ((result_cum[i] > result)); then
				((cum_sum_too_big = 1))
				((i_step = i))
				break
			fi
		done

		((cum_sum_too_big)) && continue
		# next operator should just change by one
		((i_step = i_last_operator))

		if ((result_cum[i_last_operator] == result)); then
			operators_can_do=1
			break
		fi

	done

	if ((operators_can_do)); then
		((score += result))
	fi

	unset operators result_cum
done <"$1"

echo $score
