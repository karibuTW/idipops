class PaymentsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def notify
    transaction = CreditTransaction.find(params[:ORDERID])
    if transaction.present?
      if params.has_key?(:EXECCODE) && params[:EXECCODE].present?
        amount = params[:AMOUNT].to_i / 100
        transaction.amount_cents = amount
        transaction.ext_transaction_id = params[:TRANSACTIONID]
        transaction.accept!
        transaction.save
      else
        transaction.reject!
      end
    end
    render inline: "OK", status: :ok
  end

  def cancel
    transaction = CreditTransaction.find(params[:ORDERID])
    if transaction.present?
      transaction.cancel!
      transaction.save
    end
    redirect_to "/credits"
  end

end