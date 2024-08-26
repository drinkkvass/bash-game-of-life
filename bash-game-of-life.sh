#!/bin/bash
print_pixel() {
echo -ne "\e[48;2;${1};${2};${3}m  \e[0m"
}
read -p "Welcome to the game of life! Press Enter to continue: "
xdotool key F11
clear
toilet "GAME OF LIFE" -f smmono12
read -p "Enter width: " width
read -p "Enter height: " height
read -p "Enter delay (milliseconds): " delay
seconds_delay=$(( $delay / 1000 ))
declare -A array
for ((i=0; i < width; i++)); do
for ((j=0; j < height; j++)); do
array[$i,$j]="-"
done
done
print_array() {
clear
for ((i=0; i < height; i++)); do
for ((j=0; j < width; j++)); do
if [ "${array[$j,$i]}" == "-" ]; then
if [ "$1" == "$j,$i" ]; then
print_pixel 50 50 50
else
#print_pixel 0 0 0
echo -n "  "
fi
elif [ "${array[$j,$i]}" == "+" ]; then
if [ "$1" == "$j,$i" ]; then
print_pixel 192 192 192
else
print_pixel 255 255 255
fi
fi
done
echo "⎸"
done
for ((i=0; i < $((width * 2)); i++)); do
echo -n "‾"
done
echo
}
clear
echo "Keypad Controls:"
echo "Use the arrows ←↑→↓ to move around the field."
echo "Press Enter or the Spacebar to change the state of the cell."
echo "Press the 1 button if you want to start the game (not here)."
print_pixel 255 255 255; echo " = live pixel."
#print_pixel 0 0 0; echo " = dead pixel."
echo "   = dead pixel."
print_pixel 50 50 50; echo " = selected dead pixel."
print_pixel 192 192 192; echo " = selected live pixel."
read -p "Press Enter if you understand: "
tput civis
#tput cnorm
pointer=0,0
print_array $pointer
while true; do
read -rsn1 input
case "$input" in
$'\x1b')
read -rsn2 input
case "$input" in
'[A')
# Up arrow
IFS=',' read -r pointer_width pointer_height <<< "$pointer"
if [ "$pointer_height" -gt 0 ]; then
pointer="${pointer_width},$((pointer_height - 1))"
print_array $pointer
fi
;;
'[B')
# Down arrow
IFS=',' read -r pointer_width pointer_height <<< "$pointer"
if [ "$pointer_height" -lt $((height - 1)) ]; then
pointer="${pointer_width},$((pointer_height + 1))"
print_array $pointer
fi
;;
'[C')
# Right arrow
IFS=',' read -r pointer_width pointer_height <<< "$pointer"
if [ "$pointer_width" -lt $((width - 1)) ]; then
pointer="$((pointer_width + 1)),${pointer_height}"
print_array $pointer
fi
;;
'[D')
# Left arrow
IFS=',' read -r pointer_width pointer_height <<< "$pointer"
if [ "$pointer_width" -gt 0 ]; then
pointer="$((pointer_width - 1)),${pointer_height}"
print_array $pointer
fi
;;
esac
;;
'1')
break
;;
$'\0')
if [ "${array[$pointer]}" == "-" ]; then
array[$pointer]="+"
elif [ "${array[$pointer]}" == "+" ]; then
array[$pointer]="-"
fi
print_array $pointer
;;
esac
done
print_array
live_neightbors() {
local x=$1
local y=$2
local res=0
for dx in {-1..1}; do
for dy in {-1..1}; do
nx=$(( x + dx ))
ny=$(( y + dy ))
if [[ $nx -lt 0 || $ny -lt 0 || $nx -ge $width || $ny -ge $height || ($dx -eq 0 && $dy -eq 0) ]]; then
continue
fi
if [[ "${array[$nx,$ny]}" == "+" ]]; then
(( res++ ))
fi
done
done
echo $res
}
while true; do
declare -A array2
for ((i=0; i < $width; i++)); do
for ((j=0; j < $height; j++)); do
neightbors=$(live_neightbors i j)
if [[ "${array[$i,$j]}" == "+" ]]; then
if [[ $neightbors == 2 || $neightbors == 3 ]]; then
array2[$i,$j]="+"
else
array2[$i,$j]="-"
fi
else
if [[ $neightbors == 3 ]]; then
array2[$i,$j]="+"
else
array2[$i,$j]="-"
fi
fi
done
done
for ((i=0;i < $width; i++)); do
for ((j=0; j < $height; j++)); do
array[$i,$j]="${array2[$i,$j]}"
done
done
print_array
sleep $seconds_delay
done
tput cnorm
