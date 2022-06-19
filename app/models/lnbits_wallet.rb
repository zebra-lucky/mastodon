# == Schema Information
#
# Table name: lnbits_wallets
#
#  id         :bigint(8)        not null, primary key
#  readkey    :string
#  tipjar     :string
#  account_id :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class LnbitsWalletValidator < ActiveModel::Validator
  def validate(record)
    validate_tipjar(record)
    validate_readkey(record)
  end

  def validate_tipjar(record)
    if not record.tipjar
        return
    end

    url = ENV['LNBITS_WALLET_URL'] || Rails.configuration.x.lnbits_wallet_url
    url = url.end_with?('/') ? url.chop : url
    tipjar_url = "#{url}/tipjar/"

    if not record.tipjar.start_with?(tipjar_url)
      record.errors.add :tipjar, "Tip Jar link must start with #{tipjar_url}"
      return
    end

    tipjar_num = record.tipjar[tipjar_url.length...]
    if not tipjar_num.to_i.to_s == tipjar_num
      record.errors.add :tipjar, "Wrong Tip Jar link"
      return
    end
  end

  def validate_readkey(record)
    if not record.readkey
        return
    end
    if record.readkey.length != 32
      record.errors.add :readkey, "Wrong Invoice/Read key length"
      return
    end
    if not !record.readkey[/\H/]
      record.errors.add :readkey, "Invoice/Read key must be hex string"
      return
    end
  end
end

class LnbitsWallet < ApplicationRecord
  validates_with LnbitsWalletValidator
  belongs_to :account
end
