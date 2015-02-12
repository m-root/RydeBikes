class Interest < ActiveRecord::Base
	belongs_to :user
	belongs_to :location, class_name: "Coordinate"
end
