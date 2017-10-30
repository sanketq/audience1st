class CreateIdentities < ActiveRecord::Migration
  def change
  	drop_table :identities
    create_table :identities do |t|
      t.string :name
      t.string :email
      t.string :password_digest

      t.timestamps null: false
    end
  end
end
