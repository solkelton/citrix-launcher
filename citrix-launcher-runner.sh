#!/bin/bash

#TODO: Determine launch state for Centrix Reciever, why errors are occuring on launch
main () {
	REGREX="launch[[:space:]]?\(?([1-9]?)?\)?.jsp"
	file_added=$1
	launcher_name="${file_added##*/}"

	if [ "$file_added" = "$launcher_name" ]; then
		download_path="$HOME/Downloads/"
		new_launcher_name="launch $launcher_name"

		if [[ $new_launcher_name =~ $REGREX ]]; then
			new_file_added="$download_path$new_launcher_name"
			open "$new_file_added" -a "Citrix Receiver"
		fi
	else
		if [[ $launcher_name =~ $REGREX ]]; then
			open $file_added -a "Citrix Receiver"
		fi
	
	fi

}

main "$1"



