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

declare -i i=0 row=0 col=0 area=0 perimeter=0 iqstart=0 iqend=0 rowq=0 colq=0 score=0 r=0 c=0 x=0 dx=0 dy=0
declare caseq_key="" case_key="" top="" bot="" left="" right="" region="" perimeter_position=""
declare -a queuerow=() queuecol=()
declare -A regions=() gradients=() perimeters=()
while ((${#case_is_seen[@]} < n_rows * n_cols)); do
	((row = i / n_cols))
	((col = i % n_cols))
	case_key="$row,$col"

	if [[ -n ${case_is_seen[$case_key]:-} ]]; then
		((i++))
		continue
	fi

	plant="${garden[$case_key]}"
	area=0 perimeter=0
	case_is_seen[$case_key]=1
	queuerow=("$row")
	queuecol=("$col")
	iqstart=0 iqend=1
	regions=() gradients=() perimeters=()

	while ((iqstart < iqend)); do
		rowq="${queuerow[$iqstart]}"
		colq="${queuecol[$iqstart]}"
		caseq_key="$rowq,$colq"
		((iqstart++))

		top="$((rowq - 1)),$colq"
		bot="$((rowq + 1)),$colq"
		left="$rowq,$((colq - 1))"
		right="$rowq,$((colq + 1))"
		if [[ "${garden[$caseq_key]}" == "$plant" ]]; then
			regions[$caseq_key]=1
			((area++))

			if [[ -z ${regions[$top]:-} ]]; then
				queuerow[iqend]=$((rowq - 1))
				queuecol[iqend]="$colq"
				[[ "$plant" == "${garden[$top]}" ]] && regions[$top]=1
				((iqend++))
			fi
			if [[ -z "${regions[$bot]:-}" ]]; then
				queuerow[iqend]=$((rowq + 1))
				queuecol[iqend]="$colq"
				[[ "$plant" == "${garden[$bot]}" ]] && regions[$bot]=1
				((iqend++))
			fi
			if [[ -z "${regions[$left]:-}" ]]; then
				queuerow[iqend]="$rowq"
				queuecol[iqend]="$((colq - 1))"
				[[ "$plant" == "${garden[$left]}" ]] && regions[$left]=1
				((iqend++))
			fi
			if [[ -z "${regions[$right]:-}" ]]; then
				queuerow[iqend]="$rowq"
				queuecol[iqend]="$((colq + 1))"
				[[ "$plant" == "${garden[$right]}" ]] && regions[$right]=1
				((iqend++))
			fi
		else
			perimeters["$caseq_key"]=1
		fi
	done

	for region in "${!regions[@]}"; do
		case_is_seen[$region]=1
	done

	# Get parameter position to create the gradient.
	# gradient is "dx,dy,x" where x is orthogonal to the direction of the gradient.
	# Namely, each outside block from the same border has the same gradient value.
	# gradient is mapped to a list of perimeter. It is used after
	for perimeter_position in "${!perimeters[@]}"; do
		IFS=, read -r r c <<<"$perimeter_position"
		top="$((r - 1)),$c"
		bot="$((r + 1)),$c"
		left="$r,$((c - 1))"
		right="$r,$((c + 1))"

		if [[ -n ${regions[$top]:-} ]]; then
			gradients["-1,0,$r"]+="$perimeter_position:"
		fi
		if [[ -n ${regions[$bot]:-} ]]; then
			gradients["1,0,$r"]+="$perimeter_position:"
		fi
		if [[ -n ${regions[$left]:-} ]]; then
			gradients["0,-1,$c"]+="$perimeter_position:"
		fi
		if [[ -n ${regions[$right]:-} ]]; then
			gradients["0,1,$c"]+="$perimeter_position:"
		fi
	done

	declare -i n_edges=0 n_edges_=0
	for grad in "${!gradients[@]}"; do
		IFS=',' read -r dx dy _ <<<"$grad"

		# List of positions for the same gradient (= same border)
		declare -a gradient_positions=()
		IFS=':' read -ra gradient_positions <<<"${gradients[$grad]}"

		# List of the index that change from different positions in the same gradient.
		# For vertical gradient, it's the col
		# For horizontal gradient, it's the col
		declare -a ys=()

		case "$dx,$dy" in
		"-1,0" | "1,0")
			for p in "${gradient_positions[@]}"; do
				IFS=',' read -r _ y <<<"$p"
				ys+=("$y")
			done
			;;
		"0,1" | "0,-1")
			for p in "${gradient_positions[@]}"; do
				IFS=',' read -r y _ <<<"$p"
				ys+=("$y")
			done
			;;
		esac

		n_edges_=$(
			IFS=$'\n'
			echo "${ys[*]}" |
				sort --unique --numeric-sort |
				awk 'BEGIN {prev = 0; count = 0;} {diff = $1 - prev; prev = $1; if (diff > 1 && NR > 1) count++;} END { print count+1 }'
		)
		((n_edges += n_edges_))
	done

	((i++))
	((score += n_edges * area))
done
echo "score: $score"
