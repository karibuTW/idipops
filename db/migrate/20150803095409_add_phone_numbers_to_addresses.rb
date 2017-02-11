class AddPhoneNumbersToAddresses < ActiveRecord::Migration
  def change
    add_column :addresses, :land_phone, :string
    add_column :addresses, :mobile_phone, :string
    add_column :addresses, :fax, :string
  end
end
