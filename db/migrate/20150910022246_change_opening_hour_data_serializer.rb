class ChangeOpeningHourDataSerializer < ActiveRecord::Migration
  def change
  	ActiveRecord::Base.connection.execute("UPDATE `opening_hours` SET `opening_hours`.`days` = '[{\"label\":1,\"value\":true},{\"label\":2,\"value\":true},{\"label\":3,\"value\":true},{\"label\":4,\"value\":true},{\"label\":5,\"value\":true},{\"label\":6,\"value\":false},{\"label\":0,\"value\":false},{\"label\":7,\"value\":false}]' , `opening_hours`.`period` = '{\"open\":\"2015-02-01T05:45:00.000Z\",\"close\":\"2015-02-01T11:45:00.000Z\"}' ")
  end
end
