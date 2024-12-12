declare -a garden_=()
mapfile -t garden_ <"$1"
declare -i n_rows="${#garden_[@]}" n_cols="${#garden_[0]}"
declare -A garden
declare -i i=0 j=0
for ((i = 0; i < n_rows; i++)); do
	for ((j = 0; j < n_cols; j++)); do
		garden["$i,$j"]="${garden_[$i]:$j:1}"
	done
done
declare -A case_is_seen=()

declare -i i=0 row=0 col=0 area=0 perimeter=0 iqstart=0 iqend=0 rowq=0 colq=0 score=0
declare caseq_key="" case_key="" top="" bot="" left="" right="" region=""
declare -a queuerow=() queuecol=()
declare -A regions=()
while ((${#case_is_seen[@]} < n_rows * n_cols)); do
	((row = i / n_cols))
	((col = i % n_cols))
	case_key="$row,$col"
	# echo -n "Case: $case_key"

	if [[ -n ${case_is_seen[$case_key]:-} ]]; then
		# echo " (seen)"
		((i++))
		continue
	fi

	plant="${garden[$case_key]}"
	# echo " (new) $plant"
	area=0 perimeter=0
	case_is_seen[$case_key]=1
	queuerow=("$row")
	queuecol=("$col")
	iqstart=0 iqend=1
	regions=()

	while ((iqstart < iqend)); do
		rowq="${queuerow[$iqstart]}"
		colq="${queuecol[$iqstart]}"
		caseq_key="$rowq,$colq"
		# echo -ne "\tP:$perimeter C:$caseq_key"
		((iqstart++))

		if [[ -z "${garden[$caseq_key]:-}" ]]; then
			# echo -n " outOOB"
			# echo " (new)"
			((perimeter++))
			continue
		fi

		top="$((rowq - 1)),$colq"
		bot="$((rowq + 1)),$colq"
		left="$rowq,$((colq - 1))"
		right="$rowq,$((colq + 1))"
		if [[ "${garden[$caseq_key]}" == "$plant" ]]; then
			# echo -n " in ($caseq_key)"
			regions[$caseq_key]=1
			((area++))

			if [[ -z ${regions[$top]:-} ]]; then
				# echo -n " +top"
				queuerow[iqend]=$((rowq - 1))
				queuecol[iqend]="$colq"
				[[ "$plant" == "${garden[$top]}" ]] && regions[$top]=1
				((iqend++))
			fi
			if [[ -z "${regions[$bot]:-}" ]]; then
				# echo -n " +bot"
				queuerow[iqend]=$((rowq + 1))
				queuecol[iqend]="$colq"
				[[ "$plant" == "${garden[$bot]}" ]] && regions[$bot]=1
				((iqend++))
			fi
			if [[ -z "${regions[$left]:-}" ]]; then
				# echo -n " +left"
				queuerow[iqend]="$rowq"
				queuecol[iqend]="$((colq - 1))"
				[[ "$plant" == "${garden[$left]}" ]] && regions[$left]=1
				((iqend++))
			fi
			if [[ -z "${regions[$right]:-}" ]]; then
				# echo -n " +right"
				queuerow[iqend]="$rowq"
				queuecol[iqend]="$((colq + 1))"
				[[ "$plant" == "${garden[$right]}" ]] && regions[$right]=1
				((iqend++))
			fi
		else
			# perimeters+=("$caseq_key")
			((perimeter++))
			# echo -n " outQ"
			# echo -n " new!"
		fi
		# echo
	done
	# echo -e "\t$caseq_key"

	for region in "${!regions[@]}"; do
		case_is_seen[$region]=1
	done

	# echo "$plant: $perimeter * $area = $((perimeter * area))"
	# echo

	((i++))
	((score += perimeter * area))
done
echo $score
