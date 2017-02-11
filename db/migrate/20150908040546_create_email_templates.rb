class CreateEmailTemplates < ActiveRecord::Migration
  def change
    create_table :email_templates do |t|
      t.string :name
      t.string :subject
      t.text :body
      t.boolean :active
      t.timestamps
    end

    EmailTemplate.create(
    	name: "referral_template",
    	subject: "Une de vos offres a été acceptée sur Uneo.fr",
      active: true,
    	body: "<h2>Bonjour,</h2><p>Cher utilisateur,</p><p>{user_pretty_name} wants you to try Uneo!. Uneo lets you bring all your products or services and share them easily.Plus, you'll both get {reward} of extra arrow if you get started through this email.Thanks!</p><a href='{referral_link}' style='font-size:15px;color:#FFFFFF;border:1px #1373b5 solid;text-decoration:none;padding:14px 7px 14px 7px;width:280px;font-family: arial, verdana, tahoma, sans-serif;margin:6px auto;background-color:#007ee6;text-align:center;'>Accept invite</a><p>- The Uneo Team</p>")
  end
end
