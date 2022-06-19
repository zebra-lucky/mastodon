class CreateLnbitsWallets < ActiveRecord::Migration[6.1]
  def change
    create_table :lnbits_wallets do |t|
      t.string :readkey
      t.string :tipjar
      t.belongs_to :account, null: false, index: { unique: true }, foreign_key: true

      t.timestamps
    end
  end
end
