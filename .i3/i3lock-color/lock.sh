#!/bin/sh

B='#00000000'  # blank
C='#ffffff22'  # clear ish
D='#ffffffff'  # default
T='#009600ee'  # text
W='#880000bb'  # wrong
V='#00ff00bb'  # verifying
BB='#000000ff'

~/.i3/i3lock-color/i3lock       \
    --insidevercolor=$C   \
    --ringvercolor=$V     \
    \
    --insidewrongcolor=$C \
    --ringwrongcolor=$W   \
    \
    --insidecolor=$B      \
    --ringcolor=$D        \
    --linecolor=$B        \
    --separatorcolor=$D   \
    \
    --textcolor=$T        \
    --timecolor=$T        \
    --datecolor=$T        \
    --keyhlcolor=$T       \
    --bshlcolor=$T       \
    \
    --screen 0            \
    --blur 5              \
    --clock               \
    --indicator           \
    --timestr="%H:%M:%S"  \
    --datestr="%A, %m %Y" \
    && xset dpms force off \


    # --veriftext="Drinking verification can..."
    # --wrongtext="Nope!"
    # --textsize=20
    # --modsize=10
    # --timefont=comic-sans
    # --datefont=monofur
    # etc
