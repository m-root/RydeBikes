class Ride < ActiveRecord::Base
	STATUS = {
		:progress => "in progress",
		:complete => "complete"
	}

	validates_presence_of :bike_id, :start_location_id, :start_time
	validates_presence_of :stop_location_id, :stop_time, if: :status_complete?

	has_one :trans, class_name: "Transaction"
	belongs_to :bike
	belongs_to :user
	belongs_to :start_location, class_name: 'Coordinate', foreign_key: "start_location_id"
	belongs_to :stop_location, class_name: 'Coordinate', foreign_key: "stop_location_id"

	# this should be put into the validation if
	def status_complete?
		return (self.status == STATUS[:complete])
	end

	def calculate_cost
		return (self.stop_time - self.start_time) * 24 * 60 * COST_PER_MINUTE
	end

	def summary
		# TODO: return json of summary of ride, miles, etc.
		@summary = {
			:duration => (self.stop_time - self.start_time),
			:miles 	  => 1 # distance(self.start_location - self.stop_location)
		}
		return @summary.merge(self.to_json)
	end

	def serializable_hash(options={})
		super({
			:only => [:id, :bike_id, :start_time, :stop_time, :status, :transaction_id], 
			:include => {
				:user => {:only => [:name, :email]}, 
				:start_location => {:only => [:name]}, 
				:stop_location => {:only => [:name]}
			}
		}.merge(options || {}))
	end
end