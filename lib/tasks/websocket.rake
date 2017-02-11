namespace :websocket do
  desc "Restart the websocket server"
  task restart: :environment do
    begin
      puts "Stopping websocket rails server ..."
      Rake::Task["websocket_rails:stop_server"].invoke
    rescue => err
      puts "Bummer, unable to stop: #{err} :'("
      # ExceptionNotifier.notify_exception(err)
    end
    begin
      puts "Starting websocket rails server ..."
      Rake::Task["websocket_rails:start_server"].invoke
    rescue => err
      puts "Bummer, unable to start: #{err} :'("
      # ExceptionNotifier.notify_exception(err)
    end
  end

end
