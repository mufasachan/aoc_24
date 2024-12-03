BEGIN {
	sum = 0
	enabled = 1

	patternMul = "mul\\(([0-9]+),([0-9]+)\\)"
	patternDo = "do\\(\\)"
	patternDont = "don't\\(\\)"
	pattern = patternMul "|" patternDo "|" patternDont
}
{
	line = $0

	while (match(line,pattern, results)) {
		result = substr(line, RSTART, RLENGTH)

		if(results[1]) {
			sum += enabled * results[1] * results[2]
		} 
		else if (result == "do()") {
			enabled = 1
		}
		else  {
			enabled = 0
		}

		line = substr(line,RSTART+RLENGTH)
	}
}

END {
	print sum
}

