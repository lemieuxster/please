#!/usr/bin/env ruby

require 'yaml'
yamldir = (ENV["PLEASEDIR"]) ? ENV["PLEASEDIR"] : "/usr/local/.please"
yamlfile = yamldir + "/please.yml"

if ARGV.length == 0
  puts "Please specify an alias or add a new one. --help for help."
  Process.exit
end

#ensure files presence
begin
  if !FileTest::directory?(yamldir)
    Dir::mkdir(yamldir)
  end
end

#load file
begin
  aliasmap = YAML.load_file yamlfile
rescue
  aliasmap = {}
end

if (!aliasmap)
  aliasmap = {}
end

#collect arguments
arguments = []
ARGV.each do|a|
  arguments.push(a)
  #puts arguments[arguments.length - 1];
end

if (arguments[0] === '--help')
  puts "\n"
  puts "Please (v0.0.2beta) - an alias manager by David LeMieux\n\n"
  puts "Commands:\n"
  puts "       --add 'new alias' 'aliased command' 'working dir'(optional)\n"
  puts "       --del 'new alias'"
  puts "       --list to see list of aliases\n"
  puts "\n"
  puts "You can store your please aliases in a custom directory by exporting PLEASEDIR\n"
  puts "\n"
  Process.exit
elsif (arguments[0] === '--list')
  aliasmap = aliasmap.sort {|a,b| a[0]<=>b[0]}
  aliasmap.each {|key, value|
    puts ">" + key.rjust(30) + " = " + value["command"]
  }
  Process.exit
elsif (arguments[0] === '--add')
  if (!arguments[1] || !arguments[2])
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
elsif (arguments[0] === '--del')
  if (!arguments[1])
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
  param_map = {}
  ignore_next = false
  name_count = 0;

  arguments.each_with_index do|arg, index|
    if arg.start_with? '-'
      param_map[arg.gsub(/\-/, '')] = arguments[index + 1]
      ignore_next = true
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

  #puts aliname
  #puts param_map
  ali = aliasmap[aliname]

  if (ali == nil)
    puts "No alias found."
    Process.exit
  end

  if (ali["dir"] && ali["dir"] != "")
    Dir.chdir(ali["dir"])
  end

  alicmd = ali["command"]
#  puts "Command to run #{alicmd}"

  #TODO loop over "tokens" in alicmd and ask for inputs
  inputs = alicmd.scan(/\{([^\}]+)\}/)
  inputs.each{|e|
    if param_map[e[0]] != nil
      input = param_map[e[0]]
    else
      printf "#{e[0]}: "
      input = $stdin.gets.chomp
    end
    alicmd = alicmd.gsub(/\{#{e[0]}\}/, input)
  }

  #puts "Final command #{alicmd}"

  exec( alicmd )
rescue Interrupt => interupt
  puts "\nAborted"
rescue StandardError => error
  puts "\nError executing alias."
  puts error
end
