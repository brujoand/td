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
  echo -e "Usage: $(basename $0) flags(optional) <action> <argument>\nFlags:\n\t-h help\n\t-l list <listname>\n\t-a (list all tasks)\nActions:\n\tadd <task name>\n\trm <id>\n\tdo <id>\n\tundo <id>\nmv <id> <list>"
  exit
}

function list_todos_for_list(){
  list=$1
  if [[ ! -f "$list" ]]; then
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
  for list in $todo_folder/*.md; do
    list_todos_for_list $list
  done
}

function get_task_text(){  
  echo $(sed -n "$1 p" $task_list)
}

function commit_changes(){
  (cd $todo_folder && git add *.md && git commit -m "$1" > /dev/null)
  (rm $todo_folder/*.md.bak > /dev/null 2>&1)
}

function add_task(){
  task_text=$1
  echo "- [ ] $1" >> $task_list
  commit_changes "Added '$task_text'"
}

function delete_task(){
  task_text=$(get_task_text $1)
  (sed -i.bak -e "$1 d" $task_list)
  commit_changes "Deleted '$task_text'"
}

function complete_task(){
  task_text=$(get_task_text $1)
  (sed -i.bak -e "$1 s/\[ \]/[X]/" $task_list)
  commit_changes "Completed '$task_text'"
}

function undo_task(){
  task_text=$(get_task_text $1)
  (sed -i.bak -e "$1 s/\[X\]/[ ]/" $task_list)
  commit_changes "Restarted '$task_text'"
}

function move_task(){
  id=$1
  target_list="$todo_folder/$2.md"
  task_text=$(get_task_text $1)
  (sed -n "$id p" $task_list >> "$target_list" && delete_task $id)  
  list_todos_for_list $target_list
  commit_changes "Moved '$task_text' from $task_list to $target_list"
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