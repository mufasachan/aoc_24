file=$1

awk_file=$(dirname $0)/p1.awk

awk -f $awk_file $(dirname $0)/$file
