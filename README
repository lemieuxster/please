Please
======

Seriously, I've never used Ruby before. Don't judge.


Usage
-----

Use please to manage aliases in terminal so that

    $ tail -f /Users/username/Library/Preferences/Macromedia/Flash\ Player/Logs/flashlog.txt

becomes

    $ please tail flash log

or

    $ networksetup -setairportpower airport {on/off}

becomes

    $ please toggle wifi
    on/off: on


Commands
--------
--add "new alias" "command" \("working directory"\)
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

    sudo gem install please-command-alias-manager


Secret Hints
------------

When creating a new alias that requires arguments, you can use this syntax:
please --add "my new alias" "echo {one} {two} {three} {four}"

As this alias is executed, you will be propted by stdin to provide values for each variable, like so
one: Uno
two: Dos
three: Tres
four: Cuatro

And the output would like like this
Uno Dos Tres Cuatro

Because the command that was run was echo Uno Dos Tres Cuatro.

The list of aliases is kept in /usr/local/.please/please.yml and you can edit them there if you get really stuck.

Thanks.

