#!/usr/bin/env ruby

require 'yaml'
require 'logger'
require 'git'
require "tk"
require 'date'

$file = "conf"
$repos = {"attend" => {"path" => "/home/sadiq-sons/Dropbox/code/php/attend","branch" => "maker"} \
           ,"fitter" => {"path" => "/home/sadiq-sons/Dropbox/code/php/fitter","branch" => "fitter"}}
$repository = nil
$cont  = "y"

def write_to 
 File.write($file, $repos.to_yaml)
end

#write_to();

def read_to
  $repos = YAML.load_file($file)
end

def get_time
  d = DateTime.now
  d.strftime("%d/%m/%Y %H:%M")
end

def select_repo (index)
  repo = $repos[$repos.keys[index]]
  $repository = Git.open(repo["path"], :log => Logger.new(STDOUT))
  $repository.branch(repo["branch"]).checkout
end

def repo_name (index)
   $repos.keys[index]
end


def scan_repo
  loop do
    unless $repository.diff.patch == ""
      $repository.add(:all=>true)
      $repository.commit(get_time())
      $repository.push("origin",$repository.current_branch)
    end
    sleep(5)
  end
end



def main

  read_to
  select_repo(0)
  thr = Thread.new do
    scan_repo
  end
    
  $list = TkVariable.new($repos.keys)
  
  root = TkRoot.new {title "Git Runner"}
  top = TkFrame.new(root) do
    pady 8
    grid('row'=>0, 'column'=>0)
  end
  
 # delete window event
  root.protocol "WM_DELETE_WINDOW", proc { puts "It's time to say goodbye.";
    Thread.kill(thr);
    root.destroy
  }

  # file opne label
  top_lable_val = TkVariable.new
  lbl = TkLabel.new(top) do
    textvariable top_lable_val
    grid('row'=>0, 'column'=>0)
  end
  
  top_lable_val.value = "Add Repository:"
  
  ### file open
  open_button = TkButton.new(top) do
    text "Select directory"
    grid('row'=>0, 'column'=>1)
  end

  $dir = nil
  # open directory event
  open_button.comman = Proc.new  { $dir = Tk.chooseDirectory; }
 #   Tk.messageBox ({'type' => "ok", 'icon' => "info",'title' => "Directory", 'message' => dir}  )}
 
  # list frame
 
  list_frame = TkFrame.new(root) do
    padx 8
    grid('row'=>1, 'column'=>0)
  end
  
  list = TkListbox.new(list_frame) do
    width 40
    height 20
    setgrid 1
    selectmode 'single'
    listvariable $list
    grid('row'=>0, 'column'=>0)
  end
  
   # file open label
  list_lable_val = TkVariable.new
  lbl_list = TkLabel.new(list_frame) do
    textvariable list_lable_val
    grid('row'=>1, 'column'=>0)
  end
  list_lable_val.value  = repo_name(0)
  
  
  list.bind('<ListboxSelect>', proc { index = list.curselection[0].to_i;
              select_repo(index);
              list_lable_val.value = repo_name(index)  })

  
  
  Tk.mainloop
  

end



# start
main
