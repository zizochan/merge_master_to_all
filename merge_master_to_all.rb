#!/usr/bin/env ruby

def git_featch
  system("git checkout master")
  system("git fetch")
end

def get_all_branches
  [].tap{|branches|
    lines = open('| git branch -r | grep -v "origin/master\|sandbox\|develop"')
    while !lines.eof
      branches.push lines.gets.chomp.lstrip.gsub(/origin\//, "")
    end
    lines.close
  }
end

def merge_master_branch(branch)
  return unless input_y_key("merge master to #{branch} ?")
  system("git checkout #{branch}")
  system("git pull origin #{branch}")
  system("git merge origin/master -m 'master merge'")

  if input_y_key("push #{branch} ?")
    system("git push origin #{branch}")
  else
    print "no merge....\n"
  end
end

def input_y_key(prompt)
  print prompt + " [y/n]\n"
  response = STDIN.gets

  case response
  when /^[yY]/
    true
  else
    false
  end
end

def get_repository_dir
  dir = ARGV[0] || raise("gitリポジトリのフォルダを第一引数で指定して下さい")
  raise "#{dir} is not exists" unless Dir.exists?(dir)
  dir
end

def change_current_dir
  dir = get_repository_dir
  Dir::chdir(dir)
  print "change dir to #{dir}"
end

def main
  change_current_dir
  git_featch

  branches = get_all_branches
  raise "is not git directory" if branches.empty?

  branches.each do |branch|
    merge_master_branch(branch)
  end
  print "COMPLETE!\n"
end

main
