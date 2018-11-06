#!/bin/bash

REGREX="(launch[[:space:]]?\(?([1-9]?[1-9]?[1-9])?\)?.jsp$)|(launch-[1-9]?[1-9]?[1-9].jsp$)" 
DOWNLOADS="$HOME/Downloads/"
CITRIX_PATH="/Applications/Citrix Receiver"

main () {
	file_path=$1
	file_name="${file_path##*/}"

	if [ "$file_path" = "$file_name" ]; then
		new_file_name="launch $file_name"

		if [[ $new_file_name =~ $REGREX ]]; then
			new_file_path="$DOWNLOADS$new_file_name"
			launch "$new_file_path"
		fi
	else		
		if [[ $file_name =~ $REGREX ]]; then
			launch "$file_path"
		fi
	fi
}

launch() {
	determine_state
	determine_app
	if [ "$state" = "on" ]; then
		close_citrix
	fi
	open "$1" -a "$CITRIX"
}

determine_state() {
	citrix_pid=$(ps aux | grep "$CITRIX_PATH" | grep -v "grep" | awk '{print $2}')
	if [ "$citrix_pid" = "" ]; then
		state="off"
	else
		state="on"
	fi
}

determine_app() {
	app = $(ls /Applications | grep "Citrix Workspace")
	if [ "$app" = "" ]; then
		CITRIX="Citrix Receiver"
	else
		CITRIX="Citrix Workspace"
	fi
} 

close_citrix() {
	killall "$CITRIX"
}

main "$1"
