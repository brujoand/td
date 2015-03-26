#! /usr/bin/env bash

#### Init ####

if [[ -f ~/.tdrc ]]; then
  . ~/.tdrc
else
  echo "Please run ./install.sh"
  exit
fi

todo_file="$todo_folder/$default_list.md"

#### Functions ####

function print_usage(){
  echo -e "Usage: $(basename $0) flags(optional) <action> <argument>\nFlags:\n\t-h help\n\t-l list <listname>\n\t-a (list all todos)\nActions:\n\tadd <task name>\n\trm <id>\n\tdo <id>\n\tundo <id>"
  exit
}

function list_items(){
  if [ ! -f "$todo_file" ]; then
  echo -e "Welcome, let me get you started:\n"
  add_item "Create a new item!"
  fi

  echo -e "\n$color_status$todo_file:$color_reset "

  id=0  
  while read line; do
    id=$(( id + 1 ))
    echo -e "\t$id | $line"
  done < $todo_file
  echo -e "\n$color_pending$id items, $color_todo$(grep -c -v '[X]' $todo_file) pending, $color_done$(grep -c '[X]' $todo_file) done$color_reset"
}

function list_items_all_lists(){
  for list in $(find $todo_folder -name "*.md"); do
    todo_file=$list # Fix by using parameter
    list_items
  done
}

function add_item(){
  item=$1
  echo "- [ ] $item" >> $todo_file
}

function delete_item(){
  id=$1
  (sed -i.bak -e "$id d" $todo_file)
}

function complete_item(){
  id=$1
  (sed -i.bak -e "$id s/\[ \]/[X]/" $todo_file)
}

function reset_item(){
  id=$1
  (sed -i.bak -e "$id s/\[X\]/[ ]/" $todo_file)
}

#### Handling Arguments ####
while getopts ":l:a" flag; do
  case $flag in
    l)
      if [[ -z $OPTARG ]]; then
        print_usage
      else
        todo_file="$todo_folder/$OPTARG.md"
      fi
      ;;
    a)
      list_items_all_lists      
      exit
      ;;
    *)
      print_usage
      ;;
  esac
  shift $((OPTIND-1)) 
done

if [[ "$#" -eq 2 ]]; then # larger than two
  action=$1
  action_arg=$2

  case $action in 
    add)
      add_item "$action_arg"
      ;;
    rm)
      delete_item "$action_arg"      
      ;;
    do)
      complete_item "$action_arg"
      ;;
    undo)      
      reset_item "$action_arg"
      ;;
  esac
fi

list_items
