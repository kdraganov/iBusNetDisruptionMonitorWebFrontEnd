class BusStop < ActiveRecord::Base
  self.table_name = "BusStops"
  belongs_to  :fromStop, :class_name => "Disruption", :foreign_key => "fromStopLBSLCode"
  belongs_to  :toStop, :class_name => "Disruption", :foreign_key =>"toStopLBSLCode"

end
