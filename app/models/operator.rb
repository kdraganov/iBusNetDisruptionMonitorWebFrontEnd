class Operator < ActiveRecord::Base
  self.table_name = "Operators"
  has_many :disruption_comments, :class_name => "DisruptionComment", :foreign_key => "operatorId", :primary_key => "id"
end