namespace :passwords do
  desc "Create a password for every account"
  task create: :environment do
    begin
      puts "Creating passwords..."
      Account.all.each do |account|
        if account.users.first.active?
          new_password = SecureRandom.hex(8)
          account.password = new_password
          account.password_confirmation = new_password
          if account.save
            NewsMailer.new_password_email(account.users.first.id, new_password).deliver
          end
        end
      end
    rescue => err
      puts "Bummer, failed to create passwords: #{err}"
      # ExceptionNotifier.notify_exception(err)
    end
  end

end
