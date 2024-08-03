#!/bin/bash

CONFIG_FILE="doomsday_config.txt"

save_doomsday_date() {
    echo "$1" > "$CONFIG_FILE"
}

load_doomsday_date() {
    if [ -f "$CONFIG_FILE" ]; then
        cat "$CONFIG_FILE"
    else
        echo ""
    fi
}

calculate_time_difference() {
    local now=$(date +%s)
    local doomsday=$(date -d "$1" +%s)
    echo $((doomsday - now))
}

format_time_difference() {
    local seconds=$1
    local days=$((seconds / 86400))
    local hours=$(( (seconds % 86400) / 3600))
    local minutes=$(( (seconds % 3600) / 60))
    local seconds=$((seconds % 60))
    printf "%03d:%02d:%02d:%02d" $days $hours $minutes $seconds
}

draw_clock() {
    local doomsday="$1"
    
    tput civis
    trap 'tput cnorm; exit' SIGINT SIGTERM EXIT
    trap 'draw_clock "$doomsday"' SIGWINCH
    
    while true; do
        local difference=$(calculate_time_difference "$doomsday")
        
        if [ "$difference" -le 0 ]; then
            clear
            tput cup $(($(tput lines) / 2)) $(($(tput cols) / 2 - 6))
            echo "000:00:00:00"
            break
        fi
        
        local time_str=$(format_time_difference "$difference")
        
        clear
        tput cup $(($(tput lines) / 2)) $(($(tput cols) / 2 - ${#time_str} / 2))
        echo "$time_str"
        
        sleep 1
    done
    
    tput cnorm
}

main() {
    local doomsday=$(load_doomsday_date)
    
    if [ -z "$doomsday" ]; then
        read -p "Enter the doomsday date (YYYY-MM-DD HH:MM:SS): " doomsday
        save_doomsday_date "$doomsday"
    fi
    
    draw_clock "$doomsday"
}

main
