#!/usr/bin/env ruby

require 'yaml'
yamldir = "/usr/local/.please"
yamlfile = yamldir + "/please.yml"

if ARGV.length == 0
  puts "please specify an alias or add a new one"
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
  puts "--add 'new alias' 'aliased command' 'working dir'(optional)\n"
  puts "--del 'new alias'"
  puts "--list to see list of aliases\n"
  Process.exit
elsif (arguments[0] === '--list')
  aliasmap = aliasmap.sort {|a,b| a[0]<=>b[0]}
  aliasmap.each {|key, value|
    puts ">" + key.rjust(30) + " = " + value["command"]
  }
  Process.exit
elsif (arguments[0] === '--add')
  if (!arguments[1] || !arguments[2])
    puts "not enough arguments"
    Process.exit
  end

  begin
    newcommand = {"command"=>arguments[2],"dir"=>(arguments[3]||"")}
    aliasmap[arguments[1]] = newcommand
    File.open(yamlfile, "w") {|f| f.write((aliasmap.to_yaml()))}
  rescue
    puts "error adding alias to file"
  end

  Process.exit
elsif (arguments[0] === '--del')
  if (!arguments[1])
    puts "not enough arguments"
    Process.exit
  end

  begin
    aliasmap.delete(arguments[1])
    File.open(yamlfile, "w") {|f| f.write((aliasmap.to_yaml()))}
  rescue
    puts "error deleting alias from file"
  end

  Process.exit
end

begin
  aliname = ""
  arguments.each_with_index do|arg, index|
    aliname << arg
    if (index < arguments.length - 1)
      aliname << " "
    end
  end
  #puts aliname
  ali = aliasmap[aliname]
  alicmd = ali["dir"] + ali["command"]
  exec( alicmd )
rescue
  puts "could not execute alias"
end
