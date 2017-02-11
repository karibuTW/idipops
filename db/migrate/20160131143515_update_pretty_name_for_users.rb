class UpdatePrettyNameForUsers < ActiveRecord::Migration
  def change
  	User.all.each do |user|
	  	if !user.pretty_name.present?
		    user.pretty_name = user.display_name.parameterize
		    i = 1
		    while !user.valid? do
		    	if user.errors[:pretty_name].empty?
		    		break
		    	else
			    	user.pretty_name = user.display_name.parameterize + i.to_s
			    	i += 1
			    end
		    end
		    user.save
		    say "User #{user.id} is now known as #{user.pretty_name}"
		  end
		end
  end
end
