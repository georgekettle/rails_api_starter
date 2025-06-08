class CreateSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token_digest, null: false
      t.datetime :last_seen_at, null: false
      t.string :user_agent
      t.string :ip_address
      t.datetime :expires_at
      t.boolean :active, default: true, null: false

      t.timestamps
    end
    add_index :sessions, :token_digest, unique: true
    add_index :sessions, :expires_at
    add_index :sessions, [:user_id, :active]
  end
end
