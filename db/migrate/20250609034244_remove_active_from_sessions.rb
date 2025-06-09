class RemoveActiveFromSessions < ActiveRecord::Migration[8.0]
  def change
    remove_column :sessions, :active, :boolean
  end
end
