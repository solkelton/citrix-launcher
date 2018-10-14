#!/bin/bash

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
					echo "NOT INSTALLING BREW"
					echo "Bye!"
				fi	  
			fi 
		else
			echo "NOT INSTALLING FSWATCH"
			echo "Bye!"
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
	nohup fswatch ~/downloads | xargs -n1 ./citrix-launcher-runner.sh 2> /dev/null &
	return 0 
}

main

