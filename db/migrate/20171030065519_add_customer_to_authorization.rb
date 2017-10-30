class AddCustomerToAuthorization < ActiveRecord::Migration
  def change
    add_reference :authorizations, :customer, index: true, foreign_key: true
  end
end
