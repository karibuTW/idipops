namespace :post_categories do
  desc "Set up parent post categories"
  task create_parents: :environment do
    begin
      puts "Creating parent categories ..."
      Profession.roots.each do |profession|
        parent_post_category = PostCategory.new(name: profession.name, active: true )
        parent_post_category.professions << profession
        parent_post_category.save
      end
    rescue => err
      puts "Bummer, failed to create parents: #{err}"
      # ExceptionNotifier.notify_exception(err)
    end
  end

  desc "Upload post categories"
  task upload: :environment do
    begin
      puts "Uploading categories ..."
      CSV.foreach('db/post_categories.csv', headers: true, header_converters: :symbol, col_sep: ";") do |row|
        new_category = row.to_hash
        post_category = PostCategory.new(name: new_category[:category_name].strip, active: true )
        post_category.professions << Profession.find(new_category[:profession_id])
        post_category.parent_id = new_category[:parent_id]
        post_category.save
      end
    rescue => err
      puts "Bummer, failed to create categories: #{err}"
      # ExceptionNotifier.notify_exception(err)
    end
  end
end
