#! /usr/bin/env bash

if [[ -f ~/.baskrc ]]; then
  . ~/.baskrc
else
  echo "Please run ./install.sh"
  exit
fi

function print_usage(){
  echo -e "Usage: $(basename $0)\n\t-a(dd) item\n\t-d(elete) item_id\n\t-c(omplete) item_id\n\t-r(eset) item_id\n\t-h(elp)"
  exit
}

function list_items(){
  id=0
  while read line; do
    id=$(( id + 1 ))
    echo -e "\t$id | $line"
  done < $todo_file
  echo -e "\n$color_pending$id items, $color_todo$(grep -c -v '[X]' $todo_file) pending, $color_done$(grep -c '[X]' $todo_file) done$reset"
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

if [ ! -f "$todo_file" ]; then
  echo -e "Welcome, let me get you started:\n"
  add_item "Create a new item!"
fi

while getopts ":a:d:c:r:h" flag; do
  case $flag in
    a)
      if [[ -z $OPTARG ]]; then
        print_usage
      else
        add_item "$OPTARG"
      fi
      ;;
    d)
      if [[ -z $OPTARG ]]; then
        print_usage
      else
        delete_item "$OPTARG"
      fi
      ;;
    c)
      if [[ -z $OPTARG ]]; then
        print_usage
      else
        complete_item "$OPTARG"
      fi
      ;;
    r)
      if [[ -z $OPTARG ]]; then
        print_usage
      else
        reset_item "$OPTARG"
      fi
      ;;
    *)
      print_usage
      ;;
  esac
done

list_items
