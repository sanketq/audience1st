class AddCustomerToIdentity < ActiveRecord::Migration
  def change
    add_reference :identities, :customer, index: true, foreign_key: true
  end
end
