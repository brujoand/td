#! /usr/bin/env bash

function write_config(){
  cat << EOF > $config_file
  ## Autogenerated - change what you want ##
  todo_folder=$todo_folder
  default_list=$default_list
  color_reset='\033[0m'
  color_todo='\033[01;31m'
  color_done='\033[01;32m'
  color_pending='\033[01;33m'
  color_status='\033[01;34m' 
EOF
  echo "Config written to $config_file"
}

read -e -p "Where should we store your todoslists?: " -i "$HOME/" -e todo_folder
todo_folder=${todo_folder%/}

default_list=inbox
config_file=~/.tdrc
target_install="/usr/local/bin/td"

if [[ ! -d "$todo_folder" ]]; then
	mkdir -p "$todo_folder" > /dev/null && echo -e "Created dir $todo_folder \n"
  (cd "$todo_folder" && git init)
else
  echo "$todo_folder already exists"
  if [[ ! -d "$todo_folder/.git" ]]; then
    (cd "$todo_folder" && git init)
  fi
fi

if [[ ! -f "$config_file" ]]; then
  write_config
else
  read -e -p "\n$config_file exists, overwrite? [y/n]: " overwrite
  if [[ $overwrite == "y" ]]; then 
  	write_config
  else
  	echo "Leaving $config_file as is.."
  fi
fi

if [[ ! -f "$target_install" ]]; then
  ln -s "$(pwd)/td.sh" $target_install
  echo -e "\nSymlink created $target_install -> $(pwd)/td.sh"
else
  echo -e "\nSymlink already in place at $target_install -> $(pwd)/td.sh"
fi
