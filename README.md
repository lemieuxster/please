Please
======

Seriously, I've never used Ruby before. Don't judge.


Usage
-----

Use please to manage aliases in terminal so that

tail -f /Users/username/Library/Preferences/Macromedia/Flash\ Player/Logs/flashlog.txt

becomes

please tail flash log

SO MUCH EASIER.


Commands
--------
--add "new alias" "command" "working directory"(optional)
    this adds a new alias to please to handle the command that will work out of the working directory
    for example --add "tail flash log" "tail -f /Users/username/Library/Preferences/Macromedia/Flash\ Player/Logs/flashlog.txt"
    or --add "run some script" "scriptName.sh" "/dir/to/script/"

--del "new alias"
    this removes the alias

--list
    this shows a list of aliases

--help
    shows help


Installation
------------

I could make this a "gem" or "something" but for now...
sudo cp please.rb /usr/local/bin/please && sudo chmod 755 /usr/local/bin/please

USE THIS AT YOUR OWN RISK.

HUZZAH!                cd ~