file=$1

awk_file=$(dirname "$0")/p2.awk

awk -f "$awk_file" "$(dirname "$0")/$file"

