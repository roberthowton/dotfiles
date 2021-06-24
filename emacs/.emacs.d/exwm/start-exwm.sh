#!/bin/sh
# Set the screen DPI
xrdb ~/.emacs.d/exwm/Xresources

# Run the screen compositor
picom &

# Enable screen locking on suspend
xss-lock -- slock &

# Fire it up
# exec dbus-launch --exit-with-session emacs -mm --debug-init
exec dbus-launch --exit-with-session emacs -mm --debug-init -l ~/.emacs.d/desktop.el
# emacs -mm --debug-init -l ~/.emacs.d/desktop.el
