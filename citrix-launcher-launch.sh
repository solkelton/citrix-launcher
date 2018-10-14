#!/bin/bash

#TODO: prevent multiple instances of launcher from running 
main() {
	FSWATCH="/usr/local/bin/fswatch"
	BREW="/usr/local/bin/brew" 
	fswatch_status=$(which fswatch 2>&1)
	
	if [ "$fswatch_status" = "$FSWATCH" ]; then
		create_command_line_tool
		deploy_citrix_launcher
	else 
		install_logic fswatch_prompt 
		
		if check_install; then
			brew_status=$(which brew 2>&1)
			
			if [ "$brew_status" = "$BREW" ]; then 
				fswatch_install
				create_command_line_tool
				deploy_citrix_launcher
			else
				install_logic brew_prompt

				if check_install; then
					brew_install
					fswatch_install
					create_command_line_tool
					deploy_citrix_launcher
				else
					exit_message "NOT INSTALLING BREW"
				fi	  
			fi 
		else
			exit_message "NOT INSTALLING FSWATCH"
		fi 
	fi
}

fswatch_prompt() {
	echo "You do not have fswatch installed."
	read -p "Would you like to install fswatch [y/n]? " install 
}

brew_prompt() {
	echo "In order to download fswatch, you need brew."
	echo "You do not have brew installed"
	read -p "Would you like to install brew [y/n]? " install
}

install_logic() {
	$1
	while validate_installation
	do
		$1
	done
}

validate_installation() {
	if [ "$install" = "y" ] || [ "$install" = "n" ]; then 
		return 1; 
	else 
		return 0;  
	fi 
}

check_install() {
	if [ "$install" = "y" ]; then
		return 0;
	fi

	if ["$install" = "n" ]; then
		return 1; 
	fi
}

brew_install() {
	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null 2> /dev/null
}

fswatch_install() {
	brew install fswatch
}

create_command_line_tool() {
	cp ./citrix-launcher-launch.sh /usr/local/bin
	cp ./citrix-launcher-runner.sh /usr/local/bin
	mv /usr/local/bin/citrix-launcher-launch.sh /usr/local/bin/citrix-launcher-launch
	mv /usr/local/bin/citrix-launcher-runner.sh /usr/local/bin/citrix-launcher-runner
}

deploy_citrix_launcher() {
	echo "Deploying citrix_launcher..."

	fswatch_pid=$(ps aux | grep "fswatch" | grep -v "grep" | awk '{print $2}')
	xargs_pid=$(ps aux | grep "xargs" | grep -v "grep" | awk '{print $2}')
	
	if [ "$fswatch_pid" = "" ] && [ "$xargs_pid" = "" ]; then
		launch_runner
	else
		kill -9 $fswatch_pid
		kill -9 $xargs_pid
		launch_runner 
	fi
	echo "Done!"
	return 0
}

launch_runner() {
	nohup fswatch ~/downloads | xargs -n1 ./citrix-launcher-runner 2> /dev/null &
}

exit_message() {
	echo "$1"
	echo "Bye!"
}

main