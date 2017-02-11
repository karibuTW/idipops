class CorrectTransactionDescriptionForCreditAdding < ActiveRecord::Migration
  def up
  	CreditTransaction.where(description: "Ajout de flèches").update_all(description: "credit_adding")
  end

  def down
  	CreditTransaction.where(description: "credit_adding").update_all(description: "Ajout de flèches")
  end
end
