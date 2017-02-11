class CreditTransactionSerializer < BaseSerializer

  attributes :id,
             :amount_cents,
             :amount_currency,
             :created_at,
             :credit_amount,
             :description,
             :invoice_url,
             :can_have_invoice

  def invoice_url
  	if object.invoice_uid.present?
      object.invoice.remote_url
    else
      nil
    end
  end

  def can_have_invoice
  	object.description == 'credit_adding' && !object.invoice_uid.present?
  end

end