# $1: array of integers
# return SUCCESS 	-> valid line
# return x 				-> index x is messed up
lineIsFaulty() {
	local -a numbers=("$@")

	local previous=${numbers[0]}
	local direction=0
	for ((iNumber = 1; iNumber < ${#numbers[@]}; iNumber++)); do
		local current=${numbers[iNumber]}

		local diff=$((current - previous))

		# Early stop, big diff
		if ((${diff#-} > 3 || diff == 0)); then 
			return 1
		fi

		# define derivative if not defined
		if (( direction == 0 )); then
			direction=$((diff > 0 ? 1 : -1))
		elif ((direction * diff <= 0)); then
			# if product is 0, diff is 0, numbers are equal
			# if product is negative, the trend is not respected
			return 1
		fi

		previous=$current
	done

	return 0
}


