#!/bin/bash


figletType() {
	pattern=$1
	if [ ! -d /usr/share/figlet ]; then
		fontType=""
	elif [ -z $pattern ]; then
		count=$(expr $(ls -lA /usr/share/figlet | wc -l) - 1)
		val=$((2 + $RANDOM % $count))
		fontType=$(ls -lA /usr/share/figlet | head -n $val | tail -n 1 | tr -s " " | cut -d " " -f 9)
	else
		types=$(ls -lA /usr/share/figlet | awk 'NR>1 && $9~"^sm.*\.(flf|tlf)$"{print $9}')
		count=$(echo $types | awk 'NR=1{print NF}')
		val=$((1 + $RANDOM % $count))
		fontType=$(echo $types | awk -v a=$val 'NR=1{print $a}')
	fi
}

figletDisplay() {
	if hash figlet 2>/dev/null; then
		figletType $3
		if [ -z $fontType ]; then
			figlet -tF $2 $1
		else
			figlet -tF $2 -f $fontType $1
		fi
	else
		echo "$1"
	fi
}

cowsayDisplay() {
	if hash cowsay 2>/dev/null; then
		cowsay -f $2 "$1"
	else
		echo "$1"
	fi
}

handler() {
	echo -e "\n"
	cowsayDisplay "You Imbecile! Stop trying to get out and try to answer the riddle!" "daemon"
	echo -e "\n"
}


file="$(dirname "$0")/riddles.txt"

if [ ! -f $file ]; then
	echo "Riddles not found"
	exit 1
fi


trap handler SIGINT

clear

echo -e "\n"

figletDisplay "Hello $(whoami)" "gay"

echo -e "\n"
cowsayDisplay "You need to answer a riddle to enter...." "dragon"
echo -e "\n"

read -p "Press enter to proceed...."


clear

lineNumber=$((1 + $RANDOM % $(cat $file | wc -l)))

line=$(cat $file | head -n $lineNumber | tail -n 1)
riddle=$(echo $line | cut -d "|" -f 1)
answer=$(echo $line | cut -d "|" -f 2)


cowsayDisplay "$riddle" turtle
echo ""


ans=""
tries=0

while [[ $ans == "" || $(echo "$answer" | grep -ic "$ans") -eq 0 ]]; do
	if [ $tries -ne 0 ]; then
		clear
		echo -e "\n"
		figletDisplay "Incorrect answer try again!" "metal" "sm"
		echo ""
		cowsayDisplay "$riddle" turtle
		echo -e "\n"
	fi
	read -p "Enter your answer: " ans
	tries=$(expr $tries + 1)
done

echo -e "\n"


if [ $tries -eq 1 ]; then
	cowsayDisplay "Marvellous! You truly are a genius! Please enter sir...." "stegosaurus"
elif [ $tries -le 5 ]; then
	cowsayDisplay "Fine you may enter...." "stegosaurus"
else
	cowsayDisplay "You idiot! It took you $tries tries to answer this simple riddle! Enter and get out of my sight!!!!" "stegosaurus"
fi

echo -e "\n"
