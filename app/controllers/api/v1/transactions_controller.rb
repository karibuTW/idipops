class Api::V1::TransactionsController < ApiController
	def index
		if signed_in?
			transactions = current_user.credit_transactions.with_done_state.order(created_at: :desc)
      render json: transactions, status: :ok
		else
			render json: nil, status: :unauthorized
		end
		
	end

	def create
    if signed_in?
      last_transaction = current_user.credit_transactions.with_done_state.order(created_at: :asc).last
      pricing = Pricing.active(params[:target])
      if pricing.present? && pricing.active?
        price_for_category = pricing.price_for_categories.find_by(pricing_category: current_user.primary_activity.pricing_category)
        if price_for_category.present?
          credit_amount = price_for_category.credit_amount
          amount_cents = price_for_category.amount_cents
          if params[:target] == 'change_rate'
            change_rate_pricing = Pricing.active('change_rate')
            if change_rate_pricing.present? && change_rate_pricing.active?
              change_rate_for_category = change_rate_pricing.price_for_categories.find_by(pricing_category: current_user.primary_activity.pricing_category)
              amount_cents = credit_amount / change_rate_for_category.credit_amount * change_rate_for_category.amount_cents
            else
              render json: nil, status: :unprocessable_entity
            end
          else
            if credit_amount != params[:credit_amount] || amount_cents != params[:amount_cents]
              render json: nil, status: :unprocessable_entity
              return
            end
          end
        else
          render json: nil, status: :not_found
        end
        transaction = CreditTransaction.create(user: current_user, description: params[:description], credit_amount: credit_amount)
        identifier = Rails.application.secrets.be2bill_id
        password = Rails.application.secrets.be2bill_password
        description = params[:target]
        amount = amount_cents * 100
        client_id = current_user.id
        client_email = current_user.account.account_emails.first.email
        hash = Digest::SHA256.hexdigest("#{password}AMOUNT=#{amount}#{password}CLIENTEMAIL=#{client_email}#{password}CLIENTIDENT=#{client_id}#{password}DESCRIPTION=#{description}#{password}IDENTIFIER=#{identifier}#{password}LANGUAGE=FR#{password}OPERATIONTYPE=payment#{password}ORDERID=#{transaction.id}#{password}VERSION=2.0#{password}")
        render json: { hash: hash, description: description, order_id: transaction.id, amount: amount, operation_type: "payment", version: "2.0", identifier: identifier, client_id: client_id, client_email: client_email }, status: :created
        # if transaction.update_attributes(transaction_params)
        #   render json: transaction, status: :created
        # else
        #   render json: transaction.errors, status: :unprocessable_entity
        # end
      else
        render json: nil, status: :not_found
      end
    else
      render json: nil, status: :unauthorized
    end
  end

  def generate_invoice
    if params.has_key?(:transaction_id)
      transaction = CreditTransaction.find(params[:transaction_id])
      if transaction.present?
        if transaction.description == 'credit_adding' && !transaction.invoice_uid.present?
          InvoicePdf.new([transaction]).store
          render json: transaction, status: :ok
        else
          render json: nil, status: :unprocessable_entity
        end
      else
        render json: nil, status: :not_found
      end
    end
  end


  private

  def transaction_params
    params.permit(
      :credit_amount,
      :amount_cents,
      :description
    )
  end
end