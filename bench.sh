# Need hyperfine, `cargo install hyperfine`
day=$1

if [[ ! -d $day ]];then
	echo "Folder $day does not exist"
	exit 1
fi

cd $day
hyperfine --warmup 5 './p1.sh input.txt'
hyperfine --warmup 5 './p2.sh input.txt'
