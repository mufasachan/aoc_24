# credit https://github.com/Janiczek/advent-of-code/blob/master/start.sh#L8-L11
day=$1
dayNoZero=${day#0}

# COOKIE_SESSION is defined
source .env

mkdir $day && cd $day
curl "https://adventofcode.com/2024/day/$dayNoZero/input" -H "cookie: session=$COOKIE_SESSION" -o input.txt
touch p1.sh p2.sh && chmod +x *.sh
nvim p1.sh p2.sh input.txt test.txt
