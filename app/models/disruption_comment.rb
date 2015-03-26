class DisruptionComment < ActiveRecord::Base
  self.table_name = "DisruptionComments"
  belongs_to :disruption, :class_name => "Disruptions", :foreign_key => "id", :primary_key => "disruptionId"
end