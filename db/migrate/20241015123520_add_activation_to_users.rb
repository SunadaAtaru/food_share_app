class AddActivationToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :activation_digest, :string
    add_column :users, :activated, :boolean, default: false  # デフォルトで無効化
    add_column :users, :activated_at, :datetime
  end
end
