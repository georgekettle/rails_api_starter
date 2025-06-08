class RenameTokenDigestColumns < ActiveRecord::Migration[8.0]
  def change
    rename_column :password_reset_tokens, :token_digest, :token
    rename_column :sessions, :token_digest, :token
  end
end 