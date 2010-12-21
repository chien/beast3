# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

Role.create([{ :name => 'SuperAdmin'}, { :name => 'ForumAdmin'}, { :name => 'RegisteredUser'}])
User.create!({:email => "admin@test.com", :roles => [Role.find_by_name('SuperAdmin')], :password => "admin1234", :password_confirmation => "admin1234" })