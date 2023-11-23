#!/bin/bash

function get_pixel_color() {
    scrot -o screenshot.png
    color=$(convert screenshot.png -crop 1x1+$1+$2 -format '%[pixel:p{0,0}]' info:-)
    echo "$color"
}

function check_pixel_color() {

    color=$(get_pixel_color "$2" "$3")
    if [ "$color" = "$1" ]; then
            echo "Color: $1 - found at ($2, $3)"
        return 0
    fi
    echo "Color: $1 - not found at ($2, $3)"
    return 1
}

function check_multiple_pixels_colors() {
    local args=("$@")
    local len=${#args[@]}
    local result=true

    for ((i=0; i<len; i+=3)); do
        if ! check_pixel_color "${args[i]}" "${args[i+1]}" "${args[i+2]}"; then
          return 1
        fi
    done
    echo "All colors found"
    return 0

}

function click() {
    xdotool mousemove "$1" "$2"
    default_sleep
    xdotool click 1
    default_sleep
    echo "Click ($1, $2)"
}

function click_if_color() {
    color=$(get_pixel_color "$2" "$3")
    echo "Click if color - color: $color / expected: $1"
    if [ "$color" = "$1" ]; then
        click "$2" "$3"
        return 0
    fi
    echo "No click ($2, $3) - color not found: $1"
    return 1
}

function default_sleep() {
    random_milliseconds_sleep 300 700
}

function hold_mouse() {
    echo "Hold mouse ($1, $2) for $3 seconds"
    xdotool mousemove "$1" "$2"
    default_sleep
    xdotool mousedown 1
    sleep "$3"
    xdotool mouseup 1
    echo "Finished holding mouse ($1, $2) for $3 seconds"
}


function hold_mouse_until_color_at() {
    echo "Hold mouse ($2, $3) until color: $1"
    xdotool mousemove "$2" "$3"
    default_sleep
    xdotool mousedown 1
    wait_until_color_at "$1" "$2" "$3" "$4"
    xdotool mouseup 1
    echo "Finished holding mouse ($2, $3) until color: $1"
}


function keypress() {
    echo "$1 press for $2 seconds"
    xdotool keydown "$1"
    sleep "$2"
    xdotool keyup "$1"
    echo "$1 finished pressing for $2 seconds"
    default_sleep
}


function keypress_until_color() {
    echo "$4 press until color: $1"
    xdotool keydown "$4"
    wait_until_color_at "$1" "$2" "$3" "$5"
    xdotool keyup "$4"
    echo "$4 finished pressing until color: $1 at ($2, $3)"
}

function random() {
    echo $(("$1" + RANDOM%(("$2" - "$1"))))
}

function random_milliseconds() {
    delay=$(awk "BEGIN {print $(random "$1" "$2") / 1000 }")
    echo "$delay"
}


function random_milliseconds_sleep() {
    sleep $(random_milliseconds "$1" "$2")
}


function wait_until_color_at() {
    color=$(get_pixel_color "$2" "$3")
    SECONDS=0
    while [ "$color" != "$1" ]; do
        sleep 1
        color=$(get_pixel_color "$2" "$3")
        echo "Wait until - Current color: $color / Waiting to change to: $1 at ( $2, $3)"
        if (( SECONDS > "$4" )); then
            echo "Timout - Color $1 not found at ($2, $3) in $4 seconds"
            return 1
        fi
    done
    echo "Color $1 found at ($2, $3)"
}


function wait_until_not_color_at() {
    color=$(get_pixel_color "$2" "$3")
    SECONDS=0
    while [ "$color" = "$1" ]; do
        sleep 1
        color=$(get_pixel_color "$2" "$3")
        echo "Wait until not - Current color: $color / Waiting to change to another color other than: $1 at ($2, $3)"
        if (( SECONDS > "$4" )); then
            echo "Timout - color $1 didn't change at ($2, $3) in $4 seconds"
            break
        fi
    done
}
