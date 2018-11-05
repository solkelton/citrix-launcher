#!/bin/bash

REGREX="launch[[:space:]]?\(?([1-9]?)?\)?.jsp$"
DOWNLOADS="$HOME/Downloads/"
CITRIX="Citrix Receiver"
CITRIX_PATH="/Applications/Citrix Receiver"

main () {
	file_path=$1
	file_name="${file_path##*/}"

	echo "file_path"
	echo $file_path
	
	echo "file_name"
	echo $file_name

	if [ "$file_path" = "$file_name" ]; then
		echo "file_path matches file_name"
		new_file_name="launch $file_name"

		if [[ $new_file_name =~ $REGREX ]]; then
			echo "new_file_name matches REGREX"
			new_file_path="$DOWNLOADS$new_file_name"
			launch "$new_file_path"
		fi
	else		
		echo "file_path does not match file_name"
		if [[ $file_name =~ $REGREX ]]; then
			echo "file_name matches REGREX"
			launch "$file_path"
		fi
	fi
}

launch() {
	determine_state
	if [ "$state" = "on" ]; then
		echo "Citrix launcher: on"
		close_citrix
	fi
	echo "Citrix launcher: off"
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

close_citrix() {
	killall "$CITRIX"
}

main "$1"
