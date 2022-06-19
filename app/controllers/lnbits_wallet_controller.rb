# frozen_string_literal: true

class LnbitsWalletController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!
  before_action :set_lnbits_wallet
  before_action :set_body_classes

  def show
    if @lnbits_wallet.readkey != ""
      @wallet_details = Request.new(:get, wallet_details_api)
        .add_headers('X-Api-Key' => @lnbits_wallet.readkey)
        .perform do |res|
          details = body_to_json(res.body_with_limit) if res.code == 200
          if details
            wallet_name = details['name']
            wallet_balance = details['balance'] / 1000
            "Wallet #{wallet_name} has balance of #{wallet_balance} sats"
          else
            "Wallet with #{@lnbits_wallet.readkey} Invoice/Read key  not found"
          end
      end
    end
  rescue => e
    @wallet_details = e.to_s
  end

  def update
    if @lnbits_wallet.update(resource_params)
      @lnbits_wallet.save
      redirect_to lnbits_wallet_path,
        notice: I18n.t('generic.changes_saved_msg')
    else
      render action: :show
    end
  rescue ActionController::ParameterMissing
    # Do nothing
  end

  private

  def body_to_json(body)
    body.is_a?(String) ? Oj.load(body, mode: :strict) : body
  rescue Oj::ParseError
    nil
  end

  def wallet_url
    url = ENV['LNBITS_WALLET_URL'] || Rails.configuration.x.lnbits_wallet_url
    url.end_with?('/') ? url.chop : url
  end

  def wallet_details_api
    api_path = ENV['LNBITS_WALLET_DETAILS_API'] ||
      Rails.configuration.x.lnbits_wallet_details_api
    api_path = api_path.start_with?('/') ? api_path : "/#{api_path}"
    wallet_url + api_path
  end

  def set_lnbits_wallet
    @lnbits_wallet = LnbitsWallet.find_or_create_by!(account: current_account)
  end

  def resource_params
    params.require(:lnbits_wallet).permit(:readkey, :tipjar)
  end

  def set_body_classes
    @body_classes = 'admin'
  end
end
