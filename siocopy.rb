#!/usr/bin/ruby
# encoding: UTF-8
require 'date'
require 'fileutils'

YEAR  = Date.today.strftime("%Y")
DATE  = Date.today.strftime("%Y-%m-%d")

 # # # # # # # # #  For copying application files into sioapps  # # # # # # # # # # # # # 
#                                                                                         #
  DESC = <<-DESCRIPTION

    1. If [version] is not specified, get version from pom.xml in current directory.
    2. Create any missing directories for path: "sioapps/[project]/#{YEAR}/#{DATE}--[version]/
    3. Copy the specified [file] into this path
  DESCRIPTION
#                                                                                        #
 # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

def sio_copy!
	show_usage unless ARGV.size == 2 or ARGV.size == 3
	version_not_specified = ARGV.size == 2

	project = ARGV[0].upcase
	file    = "#{Dir.pwd}/#{ARGV[1]}"
	version = ARGV[2]
	volume 	= "sioapps"
	

	exit_if_not_mounted(volume)

	version = get_version_from_pom if version_not_specified

	create_any_missing_directories("/Volumes/sioapps", project, "#{DATE}--#{version}")
	
	copy_file from: file, to: "/Volumes/sioapps/#{project}/#{YEAR}/#{DATE}--#{version}"
	
	finish! "👍"
end


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

def exit_if_not_mounted(volume)
	puts "\n >> Checking for Volume: " << volume.pink
	unless Dir.exists? "/Volumes/#{volume}"
		puts "    > #{volume} was not found".red
		puts "    > make sure that #{volume} is mounted before running this script."
		finish!
	end
end

def get_version_from_pom()
	path = "#{Dir.pwd}/pom.xml"
	puts "\n >> Getting [version] from: " << path.pink
	unless File.exists? path
		error_message "File does not exist", path
		finish!
	end
	File.open(path) do |f|
  f.each_line do |line|
  	m = line.match(/<version>(.*)<\/version>/)
  	return m[1] if m
  end
end
	error_message "Could not find [version] from", path
	finish!
end

def create_any_missing_directories(root, project, destination_dir)
	puts "\n >> Navigating to: " << "#{root}/#{project}/#{YEAR}/#{destination_dir}".pink
	verify_or_make_dir "#{root}/#{project}", :with_prompt
	verify_or_make_dir "#{root}/#{project}/#{YEAR}"
	verify_or_make_dir "#{root}/#{project}/#{YEAR}/#{destination_dir}"
end

def verify_or_make_dir(path, option=nil)
	unless Dir.exists? path
		make_dir = "Yes"
		if option == :with_prompt
			error_message "Directory does not exist", path
			make_dir = prompt "   ?> Create this directory? [y/n] "
		end
		if make_dir =~ /^y$|^Y$|^yes$|^Yes$/
			Dir.mkdir path
	 		info_message "Created directory", path
 		else
			finish!
		end
	end
end

def copy_file(hsh = {})
	file 					= hsh[:from]
	destination 	= hsh[:to]
	puts "\n >> Copying file: " << "#{file}".pink
	unless File.exists? file
		error_message "File does not exist", file
		finish!
	end
	dest_file_name = "#{destination}/#{File.basename(file)}"
	if File.exists? dest_file_name
		error_message "File already exists", dest_file_name
		finish! unless prompt("   ?> Replace this file? [y/n] ") =~ /^y$|^Y$|^yes$|^Yes$/
	end
	FileUtils.cp file, destination
	info_message "Copied file to", dest_file_name
end

def prompt(*args)
    print(*args)
    $stdin.gets.chomp
end

def info_message(text, reason)
	puts "     > #{text}: [ ".yellow << "#{reason}".green << " ]".yellow
end

def error_message(text, reason)
	puts "   !> #{text}: [ ".red << "#{reason}" << " ]".red
end

def finish!(status="👎")
	puts "\n >> Done " << status
	exit
end

def show_usage
  puts <<-END

   #{"Please provide 2-3 parameters. Recieved #{ARGV.size} parameter(s).".red}

   #{"Usage:".yellow}
    siocopy [project] [file] (version)

    #{"e.g:".green} siocopy samba web/war/target/admin.web-2.7.3.war
    #{"e.g:".green} siocopy samba web/war/target/admin.web-2.7.3.war 2.7.3

   #{"This script will:".yellow} #{DESC}
   #{"Projects:".yellow}
   	ansattsøk	helse		studentliv
   	bris		idrett
   	basis		samba
   	
   END
   exit
end


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Colorization

class String
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

  def pink
    colorize(35)
  end
end

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

sio_copy!