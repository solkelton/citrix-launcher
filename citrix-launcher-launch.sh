#!/bin/bash

main() {
	validate_fswatch=$(which fswatch 2>&1)
	if [ "$validate_fswatch" = "fswatch not found" ]; then #remove '!' for testing only
		fswatch_install_prompt
		
		while validate_installation 
		do 
			fswatch_install_prompt
		done
		
		if check_install; then
			validate_brew=$(which brew 2>&1)
			
			if [ "$validate_brew" = "brew not found" ]; then 
				brew_install_prompt

				while validate_installation
				do
					brew_install_prompt
				done

				if check_install; then
					brew_and_fswatch_install 
					deploy_citrix_launcher
				else
					echo "NOT INSTALLING BREW"
					echo "Bye!"
				fi
			else 
				fswatch_install
				deploy_citrix_launcher  
			fi 
		else
			echo "NOT INSTALLING FSWATCH"
			echo "Bye!"
		fi 
	else 
		deploy_citrix_launcher
	fi
}

fswatch_install_prompt() {
	echo "You do not have fswatch installed."
	read -p "Would you like to install fswatch [y/n]? " install 
}

brew_install_prompt() {
	echo "In order to download fswatch, you need brew."
	echo "You do not have brew installed"
	read -p "Would you like to install brew [y/n]? " install
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
	else
		return 1; 
	fi
}

brew_and_fswatch_install() {
	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null 2> /dev/null
	brew install fswatch
}

fswatch_install() {
	brew install fswatch
}

deploy_citrix_launcher() {
	echo "Deploying citrix_launcher..."
	nohup fswatch ~/downloads | xargs -n1 ./citrix-launcher-runner.sh 2> /dev/null &
	return 0 
}

main

