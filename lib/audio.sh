#!/bin/bash


get_volume() {
    amixer sget Master | grep -o "[0-9]*%" | head -1 | tr -d '%'
}


is_muted() {
    amixer sget Master | grep -o "\[off\]" | head -1
}


show_audio_menu() {
    local selected=$1
    local vol=$(get_volume)
    local mute_status=$(is_muted)
    local items=("Volume Up (+5%)" "Volume Down (-5%)" "Toggle Mute" "Back to Main Menu")
    
    
    local bar_length=20
    local filled_len=$((vol * bar_length / 100))
    local bar=""
    for ((i=0; i<filled_len; i++)); do bar="${bar}█"; done
    for ((i=filled_len; i<bar_length; i++)); do bar="${bar}░"; done

    clear
    echo "╔════════════════════════════════════╗"
    echo "║          AUDIO CONTROLS            ║"
    echo "╚════════════════════════════════════╝"
    
    if [ "$mute_status" == "[off]" ]; then
        echo "   Status: 🔇 MUTED"
    else
        echo "   Status: 🔊 $vol%"
    fi
    echo "   Level:  [$bar]"
    echo ""

    for i in "${!items[@]}"; do
        if [ $i -eq $selected ]; then
            echo "  ▶ ${items[$i]}"
        else
            echo "    ${items[$i]}"
        fi
    done
}

audio_menu() {
    local selected=0
    local num_items=4

    while true; do
        show_audio_menu $selected
        
      
        read -rsn1 key
        if [ "$key" = $'\x1b' ]; then
            read -rsn2 key
            case "$key" in
                '[A') 
                    ((selected--))
                    if [ $selected -lt 0 ]; then selected=$((num_items - 1)); fi
                    ;;
                '[B') 
                    ((selected++))
                    if [ $selected -ge $num_items ]; then selected=0; fi
                    ;;
            esac
        elif [ "$key" = "" ]; then
            case $selected in
                0) amixer sset Master 5%+ > /dev/null ;;
                1) amixer sset Master 5%- > /dev/null ;;
                2) amixer sset Master toggle > /dev/null ;;
                3) return 0 ;; # Exit function, goes back to main
            esac
        fi
    done
}
