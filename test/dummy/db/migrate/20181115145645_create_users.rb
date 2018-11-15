class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.binary :password_encrypted
      t.binary :password_iv
      t.binary :date_of_birth_encrypted
      t.binary :date_of_birth_iv

      t.timestamps
    end
  end
end
