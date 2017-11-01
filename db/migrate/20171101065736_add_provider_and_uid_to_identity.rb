class AddProviderAndUidToIdentity < ActiveRecord::Migration
  def change
    add_column :identities, :provider, :string
    add_column :identities, :uid, :string
  end
end
