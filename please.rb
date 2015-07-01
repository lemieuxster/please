#!/usr/bin/env ruby

require 'yaml'
require 'readline'

yamldir = (ENV["PLEASEDIR"]) ? ENV["PLEASEDIR"] : "/usr/local/.please"
yamlfile = yamldir + "/please.yml"

if ARGV.length == 0
  puts "Please specify an alias or add a new one. --help for help."
  Process.exit
end

#ensure files presence
begin
  Dir::mkdir(yamldir) unless FileTest::directory?(yamldir)
end

#load file
begin
  aliasmap = YAML.load_file yamlfile
rescue
  aliasmap = {}
end
aliasmap = {} unless aliasmap

#collect arguments
arguments = []
ARGV.each do|a|
  arguments.push(a)
  #puts arguments[arguments.length - 1];
end


def list(aliasmap, name = nil)
  aliasmap = aliasmap.sort {|a,b| a[0]<=>b[0]}

  if name != nil
    aliasmap = aliasmap.select {|k, v| k.match name or v["command"].match name }
  end

  aliasmap.each {|key, value|
    puts ">" + key.rjust(30) + " = " + value["command"]
  }
end

if arguments[0] === '--help'
  puts "\n"
  puts "Please (v0.0.3) - an alias manager by David LeMieux\n\n"
  puts "Commands:\n"
  puts "       --add 'new alias' 'aliased command' 'working dir'(optional)\n"
  puts "       --del 'new alias'"
  puts "       --list ('filter') to see list of aliases\n"
  puts "\n"
  puts "You can store your please aliases in a custom directory by exporting PLEASEDIR\n"
  puts "\n"
  Process.exit
elsif arguments[0] === '--list'
  list aliasmap, arguments[1]
  Process.exit
elsif arguments[0] === '--add'
  if arguments[1] == nil || arguments[2] == nil
    puts "Not enough arguments."
    Process.exit
  end

  begin
    newcommand = {"command"=>arguments[2],"dir"=>(arguments[3]||"")}
    aliasmap[arguments[1]] = newcommand
    File.open(yamlfile, "w") {|f| f.write((aliasmap.to_yaml()))}
  rescue
    puts "Error adding alias to file."
  end

  Process.exit
elsif arguments[0] === '--del'
  if arguments[1] === nil
    puts "Not enough arguments."
    Process.exit
  end

  begin
    aliasmap.delete(arguments[1])
    File.open(yamlfile, "w") {|f| f.write((aliasmap.to_yaml()))}
  rescue
    puts "Error deleting alias from file."
  end

  Process.exit
end

begin
  aliname = ""
  ignore_next = false
  name_count = 0

  aliases = []
  params = []

  arguments.each_with_index do|arg, index|
    if arg.start_with? '-'
      if params[aliases.length] == nil
        params[aliases.length] = {}
      end
      params[aliases.length][arg.gsub(/\-/, '')] = arguments[index + 1]
      ignore_next = true
    elsif arg == "then" && name_count > 0
      aliases.push(aliname)
      aliname = ""
      name_count = 0
    elsif !ignore_next
      if name_count > 0
        aliname << " "
      end
      aliname << arg
      name_count += 1
    else
      ignore_next = false
    end
  end

  aliases.push(aliname)

  aliases.each_with_index {|aliname, index|

    #puts aliname
    #puts index
    ali = aliasmap[aliname]
    param_map = params[index] || {}

    if ali == nil
      puts "No alias found."
      list aliasmap, aliname
      Process.exit
    end

    if ali["dir"] && ali["dir"] != ""
      dirstr = ali["dir"]
      dirs = dirstr.scan(/\$([^\s]+)/)
      dirs.each{|e|
        if ENV[e[0]] != nil
          dirstr = dirstr.gsub(/\$#{e[0]}/, ENV[e[0]])
        end
      }
      Dir.chdir(dirstr)
    end

    alicmd = ali["command"]
    #puts "Command to run #{alicmd}"

    #loop over "tokens" in alicmd and ask for inputs
    inputs = alicmd.scan(/\{([^\}]+)\}/)
    inputs.each{|e|
      if param_map[e[0]] != nil
        input = param_map[e[0]]
      else
        Readline.completion_append_character = ""
        input = Readline.readline("#{e[0]}: ", true)
      end
      alicmd = alicmd.gsub(/\{#{e[0]}\}/, input)
    }

    #puts "Final command #{alicmd}"
    pex = system( alicmd )
    puts "\nAborted" unless pex
    Process.exit unless pex
  }
rescue Interrupt => interrupt
  puts "\nAborted"
rescue StandardError => error
  puts "\nError executing alias."
  puts error
end
