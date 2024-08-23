#!/bin/bash
qver="1.0.2"


RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
ORANGE='\033[0;33m'
NC='\033[0m'


printHelp() {
echo -e "USAGE: q [command] [...args]"

commands=(
    "=== -> Configuration and info"
    "update -> Updates script to the latest version"
    "space -> Show the plex server currently used, total and free space"

    "=== -> Docker Shortcuts"
    "ps -> Print currently running containers"

    "=== -> 2nd Category"
    "a -> print some yellow text :)"
    )

 for n in "${commands[@]}"; do
    arr=(${n//->/ })
    key="${arr[0]}"
    key=$(printf "%-5s" "$key")

    if [ ${key} == "===" ]; then
      printHeader "${arr[@]:1}"

    else
      echo -e "$GREEN${key}$NC - ${arr[@]:1}"
    fi

  done
}

printHeader() {
  echo -e "
    $BLUE[ ~~~ $@ ~~~ ]$NC"

}



function PrintColor() {

        case $1 in
                r|red)
		currentColor="\e[31m"
                ;;
                b|blue)
                currentColor="\e[34m"
                ;;
                g|green)
                currentColor="\e[32m"
                ;;
		y|yellow)
		currentColor="\e[33m"
		;;
		u|underline)
		currentColor="\e[4m"
        esac
	shift
	echo -e "${currentColor}${*}\e[0m"
}


function updateScript() {
    local url="https://raw.githubusercontent.com/Skipperia/q/main/q"
    
    local script_path=$(realpath "$0")
    
    curl -s -o "$script_path" "$url"
    
    if [[ $? -eq 0 ]]; then
        chmod +x "$script_path"
        echo -e "$GREEN Script updated successfully to version: $qver!$NC"
    else
        echo -e "$RED Failed to update the script. Please check your internet connection.$NC"
    fi
}


function printLogicalVolumeSpace() {
# Logical Volume Path
lv_path="/dev/mapper/vg_home-lv_home"

# Fetch Block Count and Free Block Count using tune2fs
block_count=$(sudo tune2fs -l $lv_path | grep "Block count" | awk '{print $3}')
free_blocks=$(sudo tune2fs -l $lv_path | grep "Free blocks" | awk '{print $3}')

# Block size in KB (assuming it's 4 KB for ext4, change if different)
block_size_kb=4

# Calculate Total, Used, and Free Space in KB
total_space_kb=$(($block_count * $block_size_kb))
free_space_kb=$(($free_blocks * $block_size_kb))
used_space_kb=$(($total_space_kb - $free_space_kb))

# Convert KB to GB
total_space_gb=$(echo "scale=2; $total_space_kb / 1024 / 1024" | bc)
free_space_gb=$(echo "scale=2; $free_space_kb / 1024 / 1024" | bc)
used_space_gb=$(echo "scale=2; $used_space_kb / 1024 / 1024" | bc)

# Print the results
echo "Logical Volume: $lv_path"
echo "Total Space: $total_space_gb GB"
echo "Used Space: $used_space_gb GB"
echo "Free Space: $free_space_gb GB"

}




if [[ $# -eq 0 || "$1" = "help" || "$1" = "--help" ]] ; then

    printHelp
    exit 0
fi


case $1 in
    ps)
        sudo docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}" | (read -r; printf "%s\n" "$REPLY"; sort -h -k7)
    ;;
    a)
        PrintColor yellow printing yellow text
    ;;
    space)
 	printLogicalVolumeSpace
    ;;
    update)
	updateScript
    ;;
    *)
    echo "Unknown option selected - $1"
        exit 2
    ;;
esac
exit 0
