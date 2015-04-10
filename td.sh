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
  echo -e "Usage: $(basename $0) flags(optional) <action> <argument>\nFlags:\n\t-h help\n\t-l list <listname>\n\t-a (list all tasks)\nActions:\n\tadd <task name>\n\trm <id>\n\tdo <id>\n\tundo <id>\n\tlog <id>\n\tedit <id>\n\tmv <id> <list>"
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
  done < "$list"
  echo -e "\n$color_pending$id tasks, $color_todo$(grep -c -v '[X]' $list) pending, $color_done$(grep -c '[X]' $list) done$color_reset"
}

function list_tasks_from_all_lists(){
  for list in $todo_folder/*.md; do
    list_todos_for_list "$list"
  done
}

function drop_list(){
  read -r -p "Permenantly remove list ${task_list##*/}? [y/N] " response
  if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
  then
      (cd $todo_folder && git rm ${task_list##*/})
      commit_changes "Deleted list ${task_list##*/}"
  else
      echo "doing nonthing.."
  fi
  exit
}

function get_task_text(){  # Not text, intire line. rename
  sed -n "$1 p" $task_list | sed 's/- \[.*\] //'
}

function commit_changes(){
  (cd "$todo_folder" && git add "*.md" && git commit -am "$1" > /dev/null)
  rm "$todo_folder/*.md.bak" > /dev/null 2>&1
}

function get_log_for_task(){  
  task_text=$(get_task_text "$1")     
  log=$(cd "$todo_folder" && git log --pretty=format:'%s - %ci' | grep "'$task_text'" | sed "s/ '$task_text'//" | column -t)  
  echo "${log}" # This look odd. fix
}

function add_task(){
  task_text=$1
  echo "- [ ] $1" >> "$task_list"
  commit_changes "Added '$task_text' in ${task_list##*/}"
}

function delete_task(){
  task_text=$(get_task_text "$1")
  (sed -i.bak -e "$1 d" "$task_list")
  commit_changes "Deleted '$task_text' in ${task_list##*/}"
}
    
function complete_task(){
  task_text=$(get_task_text "$1")
  (sed -i.bak -e "$1 s/\[ \]/[X]/" "$task_list")
  commit_changes "Completed '$task_text' in ${task_list##*/}"
}

function undo_task(){
  task_text=$(get_task_text "$1")
  sed -i.bak -e "$1 s/\[X\]/[ ]/" "$task_list"
  commit_changes "Restarted '$task_text' in ${task_list##*/}"
}

function edit_task(){
  #(read -e -i string) 
  task_text=$(get_task_text "$1")
  read -e -i "$task_text" new_text
  sed -i.bak -e "$1 s/$task_text/$new_text/" "$task_list"
}

function move_task(){
  id=$1
  target_list="$todo_folder/$2.md"
  src_list=$task_list
  
  task_text="$(get_task_text "$id")"

  sed -n "$id p" "$task_list" >> "$target_list" && sed -i.bak -e "$1 d" "$src_list"

  list_todos_for_list "$src_list"
  commit_changes "Moved '$task_text' to ${target_list##*/}"
  task_list=$target_list
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

if [[ "$#" -gt 1 ]]; then # larger than 1
  action=$1
  task_id=$2

  case $action in 
    'add')
      add_task "$task_id"
      ;;
    'rm')
      delete_task "$task_id"
      ;;
    'do')
      complete_task "$task_id"
      ;;
    'undo')      
      undo_task "$task_id"
      ;;
    'log')
      get_log_for_task "$task_id"
      ;;
    'edit')
      edit_task "$task_id"
      ;;
    'mv')
      if [[ ! -z $3 ]];then
        move_task "$task_id" "$3"
      else
        print_usage
      fi
      ;;
    'drop')
      drop_list
      ;;
    *)
      print_usage
      ;;  
  esac
fi  

list_todos_for_list "$task_list"