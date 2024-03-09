#!/bin/bash

(LABEL=$(uuidgen) && yabai -m signal --add event="window_created" label="$LABEL" app="^WezTerm$" action="yabai -m window \$YABAI_WINDOW_ID --focus && yabai -m signal --remove $LABEL") && (/Applications/WezTerm.app/Contents/MacOS/wezterm connect local || open -na /Applications/WezTerm.app)
