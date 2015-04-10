# td
A very simple todolist, initally inspired by https://github.com/Hypercubed/todo-md

Using githubs fancy pants todo's for future fun and profit.

The idea:
I have tried todoist, omnifocus, wunderlist, any.do and countless more todoapps. And I like most of them.
But they all require apps and most of them are paid, and sync usually sucks.
I don't need a fancy notification system, because I always ignore them.
I don't need fancy apps, because markdown works just fine.
I don't need deadlines, because calendars.
And i can put md files in dropbox or git for syncing profit.

So this is a list, or several lists. With a shellscriptwrapper. 

Basic usage:

![alt text](https://www.dropbox.com/s/h75xj21cigljuhm/Screenshot%202015-04-09%2015.45.50.png?dl=1)

```
Usage: td flags(optional) <action> <argument>
Flags:
	-h help
	-l list <listname>
	-a (list all tasks)
Actions:
	add <task name>
	rm <id>
	do <id>
	undo <id>
	log <id>
	mv <id> <list>
```


Things to do:
 - [X] Add, delete, complete, reset and list tasks
 - [X] Pretty print with colors and stuff
 - [X] Summary for each list
 - [X] Edit tasks
 - [X] Add install script and configfile
 - [ ] Add autocompletion
 - [X] Hide the sed backupfile
 - [X] Commit each change to git
 - [X] List history of a task
 - [ ] Publish to gist
 - [ ] Pull/Push changes from/to git
 - [X] Add support for multiple lists
 - [X] Allow moving tasks from inbox to some other list
 - [ ] Push Completed tasks to archivelist with timestamp from gitlog
 - [ ] Support todo.txt format
 - [ ] Support 'Projects' as folders td -l <project>/<list> add <new task> 


