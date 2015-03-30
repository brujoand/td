#! /usr/bin/env bash

#### Init ####

if [[ -f ~/.tdrc ]]; then
  . ~/.tdrc
else
  echo "Please run ./install.sh"
  exit
fi

task_list="$todo_folder/$default_list.md"

#### Functions ####

function print_usage(){
  echo -e "Usage: $(basename $0) flags(optional) <action> <argument>\nFlags:\n\t-h help\n\t-l list <listname>\n\t-a (list all tasks)\nActions:\n\tadd <task name>\n\trm <id>\n\tdo <id>\n\tundo <id>"
  exit
}

function list_todos_for_list(){
  list=$1
  if [ ! -f "$list" ]; then
  echo -e "Welcome, let me get you started:\n"
  add_task "Create a new task!"
  fi

  echo -e "\n$color_status$list:$color_reset "

  id=0  
  while read line; do
    id=$(( id + 1 ))
    echo -e "\t$id | $line"
  done < $list
  echo -e "\n$color_pending$id tasks, $color_todo$(grep -c -v '[X]' $list) pending, $color_done$(grep -c '[X]' $list) done$color_reset"
}

function list_tasks_from_all_lists(){
  for list in $(find $todo_folder -name "*.md"); do
    list_todos_for_list $list
  done
}

function add_task(){
  echo "- [ ] $1" >> $task_list
}

function delete_task(){
  (sed -i.bak -e "$1 d" $task_list)
}

function complete_task(){
  (sed -i.bak -e "$1 s/\[ \]/[X]/" $task_list)
}

function undo_task(){
  (sed -i.bak -e "$1 s/\[X\]/[ ]/" $task_list)
}

function move_task(){
  id=$1
  target_list="$todo_folder/$1.md"
  (sed -n "$id p" $task_list >> "$target_list" && delete_task $id)
  list_todos_for_list $target_list
}

#### Handling Arguments ####
while getopts ":l:a" flag; do
  case $flag in
    l)
      if [[ -z $OPTARG ]]; then
        print_usage
      else
        task_list="$todo_folder/$OPTARG.md"
      fi
      ;;
    a)
      list_tasks_from_all_lists
      exit
      ;;
    *)
      print_usage
      ;;
  esac
  shift $((OPTIND-1)) 
done

if [[ "$#" -gt 1 ]]; then # larger than two
  action=$1
  task_id=$2

  case $action in 
    add)
      add_task "$task_id"
      ;;
    rm)
      delete_task "$task_id"
      ;;
    do)
      complete_task "$task_id"
      ;;
    undo)      
      undo_task "$task_id"
      ;;
    mv)
      if [[ ! -z $3 ]];then
        move_task "$task_id" "$3"
      else
        print_usage
      fi
      ;;
    *)
      print_usage
      ;;  
  esac
fi  

list_todos_for_list $task_list