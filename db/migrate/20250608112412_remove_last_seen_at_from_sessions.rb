class RemoveLastSeenAtFromSessions < ActiveRecord::Migration[8.0]
  def change
    remove_column :sessions, :last_seen_at, :datetime
  end
end
