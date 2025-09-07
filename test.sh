#!/bin/bash

$(find \"${XDG_CONFIG_HOME:-$HOME/.config}/fastfetch/pngs/\" -name \"*.png\" | shuf -n 1)
