class ConvertDatabaseToUtf8Mb4 < ActiveRecord::Migration
  def change

    execute "ALTER TABLE `account_emails` CHANGE `email` `email` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"

    execute "ALTER TABLE `addresses` CHANGE `place_id` `place_id` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    execute "ALTER TABLE `addresses` CHANGE `land_phone` `land_phone` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    execute "ALTER TABLE `addresses` CHANGE `mobile_phone` `mobile_phone` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    execute "ALTER TABLE `addresses` CHANGE `fax` `fax` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    
    execute "ALTER TABLE `classified_ads` CHANGE `title` `title` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    execute "ALTER TABLE `classified_ads` CHANGE `workflow_state` `workflow_state` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"

    execute "ALTER TABLE `classified_ad_photos` CHANGE `attachment_uid` `attachment_uid` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"

    execute "ALTER TABLE `conversations` CHANGE `workflow_state` `workflow_state` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"

    execute "ALTER TABLE `credit_transactions` CHANGE `description` `description` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    execute "ALTER TABLE `credit_transactions` CHANGE `amount_currency` `amount_currency` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    execute "ALTER TABLE `credit_transactions` CHANGE `ext_transaction_id` `ext_transaction_id` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    execute "ALTER TABLE `credit_transactions` CHANGE `workflow_state` `workflow_state` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"

    execute "ALTER TABLE `deals` CHANGE `tagline` `tagline` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    execute "ALTER TABLE `deals` CHANGE `featured_image_uid` `featured_image_uid` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    execute "ALTER TABLE `deals` CHANGE `list_image_uid` `list_image_uid` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
            
    execute "ALTER TABLE `deal_promotions` CHANGE `display_location` `display_location` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    
    execute "ALTER TABLE `email_templates` CHANGE `name` `name` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    execute "ALTER TABLE `email_templates` CHANGE `subject` `subject` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"

    execute "ALTER TABLE `places` CHANGE `country_code` `country_code` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    execute "ALTER TABLE `places` CHANGE `postal_code` `postal_code` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    execute "ALTER TABLE `places` CHANGE `place_name` `place_name` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    execute "ALTER TABLE `places` CHANGE `admin_name1` `admin_name1` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    execute "ALTER TABLE `places` CHANGE `admin_code1` `admin_code1` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    execute "ALTER TABLE `places` CHANGE `admin_name2` `admin_name2` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    execute "ALTER TABLE `places` CHANGE `admin_code2` `admin_code2` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    execute "ALTER TABLE `places` CHANGE `admin_code3` `admin_code3` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    execute "ALTER TABLE `places` CHANGE `geo_point_2d` `geo_point_2d` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"

    execute "ALTER TABLE `schema_migrations` CHANGE `version` `version` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"

    execute "ALTER TABLE `price_for_categories` CHANGE `amount_currency` `amount_currency` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"

    execute "ALTER TABLE `pricings` CHANGE `target` `target` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"

    execute "ALTER TABLE `pricing_categories` CHANGE `name` `name` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"

    execute "ALTER TABLE `professions` CHANGE `name` `name` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    execute "ALTER TABLE `professions` CHANGE `ancestry` `ancestry` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"

    execute "ALTER TABLE `profile_sponsorings` CHANGE `display_location` `display_location` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"

    execute "ALTER TABLE `pro_reviews` CHANGE `content` `content` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"

    execute "ALTER TABLE `quotation_request_professionals` CHANGE `quotation_uid` `quotation_uid` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    execute "ALTER TABLE `quotation_request_professionals` CHANGE `quotation_name` `quotation_name` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
                                              
    execute "ALTER TABLE `quotation_request_templates` CHANGE `name` `name` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    
    execute "ALTER TABLE `referrals` CHANGE `email` `email` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    execute "ALTER TABLE `referrals` CHANGE `workflow_state` `workflow_state` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"

    execute "ALTER TABLE `taggings` CHANGE `taggable_type` `taggable_type` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    execute "ALTER TABLE `taggings` CHANGE `tagger_type` `tagger_type` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    execute "ALTER TABLE `taggings` CHANGE `context` `context` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
                                              
    execute "ALTER TABLE `tags` CHANGE `name` `name` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
                                              
    execute "ALTER TABLE `users` CHANGE `company_name` `company_name` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"                              
    execute "ALTER TABLE `users` CHANGE `pretty_name` `pretty_name` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"                              
    execute "ALTER TABLE `users` CHANGE `first_name` `first_name` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"                              
    execute "ALTER TABLE `users` CHANGE `last_name` `last_name` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"                              
    execute "ALTER TABLE `users` CHANGE `user_type` `user_type` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"                              
    execute "ALTER TABLE `users` CHANGE `website` `website` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"                              
    execute "ALTER TABLE `users` CHANGE `siret` `siret` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"                              
    execute "ALTER TABLE `users` CHANGE `land_phone` `land_phone` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"                              
    execute "ALTER TABLE `users` CHANGE `mobile_phone` `mobile_phone` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"                              
    execute "ALTER TABLE `users` CHANGE `avatar_uid` `avatar_uid` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"                              
    execute "ALTER TABLE `users` CHANGE `token` `token` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"                              
    execute "ALTER TABLE `users` CHANGE `workflow_state` `workflow_state` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"

    execute "ALTER TABLE `user_photos` CHANGE `attachment_uid` `attachment_uid` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    
    # for each table that will store unicode execute:
    ['accounts','account_emails','addresses','addresses_deals','authorizations','classified_ads','classified_ads_professions','classified_ad_photos','conversations','conversation_users','credit_transactions','deals','deal_promotions','deal_promotions_transactions','schema_migrations','email_templates','messages','opening_hours','places', 'places_users', 'price_for_categories', 'pricings', 'pricing_categories', 'professions', 'profile_sponsorings', 'profile_views', 'pro_ratings', 'pro_reviews', 'quotation_requests', 'quotation_request_professionals', 'quotation_request_templates', 'referrals', 'taggings', 'tags', 'users', 'users_favorite_professionals', 'user_photos'].each do |t|
      execute "ALTER TABLE `#{t}` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
      execute "REPAIR TABLE `#{t}`"
      execute "OPTIMIZE TABLE `#{t}`"
    end
  end
end

