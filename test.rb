#!/usr/bin/env ruby
require 'yaml'

class Reviewlette
  attr_accessor :name
  attr_accessor :activity
  def namereturn
    'jschmid'
  end
  def readfromfile
    config = YAML.load_file("names.yml")
    @allnames = config
    @name = @allnames.sample
  end
  def namecall
  readfromfile unless @name
   "its your turn #{@name}"
   "do you have time for this? #{@name}" 
   "Yes or No. Type in y or n"
  end 
  def activitystodo
    config = YAML.load_file("activitys.yml")
    @allactivity = config
    @activity = @allactivity.new
  end
  def askuser
   response = gets 
   response = response.chomp
   readfromfile unless @activity
   if response == "y" then
    "Well then #{@activity}"
   else
   "Oke bring me someone else"
   end 
  end
end

roulette= Reviewlette.new
roulette.readfromfile
roulette.activitystodo
puts roulette.namecall
puts roulette.askuser



#do the yml file handling with an api -> next step 
#see git-review 
	


