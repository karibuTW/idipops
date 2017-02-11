# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160508102907) do

  create_table "account_emails", force: :cascade do |t|
    t.string   "email",      limit: 191
    t.integer  "account_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "account_emails", ["account_id"], name: "index_account_emails_on_account_id", using: :btree
  add_index "account_emails", ["email"], name: "index_account_emails_on_email", unique: true, using: :btree

  create_table "accounts", force: :cascade do |t|
    t.string   "password_digest", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "addresses", force: :cascade do |t|
    t.integer  "user_id",           limit: 4
    t.text     "formatted_address", limit: 16777215
    t.string   "place_id",          limit: 191
    t.decimal  "latitude",                           precision: 10, scale: 6
    t.decimal  "longitude",                          precision: 10, scale: 6
    t.integer  "action_range",      limit: 4,                                 default: 50
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "land_phone",        limit: 191
    t.string   "mobile_phone",      limit: 191
    t.string   "fax",               limit: 191
  end

  add_index "addresses", ["user_id"], name: "index_addresses_on_user_id", using: :btree

  create_table "addresses_deals", force: :cascade do |t|
    t.integer "deal_id",    limit: 4
    t.integer "address_id", limit: 4
  end

  add_index "addresses_deals", ["address_id"], name: "index_addresses_deals_on_address_id", using: :btree
  add_index "addresses_deals", ["deal_id"], name: "index_addresses_deals_on_deal_id", using: :btree

  create_table "authorizations", force: :cascade do |t|
    t.integer "credit_transaction_id", limit: 4
    t.integer "classified_ad_id",      limit: 4
  end

  add_index "authorizations", ["classified_ad_id"], name: "index_authorizations_on_classified_ad_id", using: :btree
  add_index "authorizations", ["credit_transaction_id"], name: "index_authorizations_on_credit_transaction_id", using: :btree

  create_table "classified_ad_photos", force: :cascade do |t|
    t.string   "attachment_uid",   limit: 191
    t.integer  "classified_ad_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "classified_ad_photos", ["classified_ad_id"], name: "index_classified_ad_photos_on_classified_ad_id", using: :btree

  create_table "classified_ads", force: :cascade do |t|
    t.string   "title",          limit: 191
    t.text     "description",    limit: 16777215
    t.datetime "start_date"
    t.integer  "user_id",        limit: 4
    t.integer  "place_id",       limit: 4
    t.string   "workflow_state", limit: 191
    t.text     "reject_reason",  limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "classified_ads", ["place_id"], name: "index_classified_ads_on_place_id", using: :btree
  add_index "classified_ads", ["user_id"], name: "index_classified_ads_on_user_id", using: :btree

  create_table "classified_ads_professions", force: :cascade do |t|
    t.integer "profession_id",    limit: 4
    t.integer "classified_ad_id", limit: 4
  end

  add_index "classified_ads_professions", ["classified_ad_id"], name: "index_classified_ads_professions_on_classified_ad_id", using: :btree
  add_index "classified_ads_professions", ["profession_id"], name: "index_classified_ads_professions_on_profession_id", using: :btree

  create_table "conversation_users", force: :cascade do |t|
    t.integer  "conversation_id", limit: 4
    t.integer  "user_id",         limit: 4
    t.boolean  "unread",                    default: false
    t.datetime "last_read_at"
    t.boolean  "notified",                  default: false
  end

  add_index "conversation_users", ["conversation_id"], name: "index_conversation_users_on_conversation_id", using: :btree
  add_index "conversation_users", ["user_id"], name: "index_conversation_users_on_user_id", using: :btree

  create_table "conversations", force: :cascade do |t|
    t.integer  "classified_ad_id", limit: 4
    t.string   "workflow_state",   limit: 191
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "conversations", ["classified_ad_id"], name: "index_conversations_on_classified_ad_id", using: :btree

  create_table "credit_transactions", force: :cascade do |t|
    t.string   "description",        limit: 191
    t.integer  "user_id",            limit: 4
    t.integer  "amount_cents",       limit: 4,   default: 0, null: false
    t.string   "amount_currency",    limit: 191
    t.integer  "credit_amount",      limit: 4
    t.string   "ext_transaction_id", limit: 191
    t.string   "workflow_state",     limit: 191
    t.string   "invoice_uid",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "credit_transactions", ["user_id"], name: "index_credit_transactions_on_user_id", using: :btree

  create_table "deal_promotions", force: :cascade do |t|
    t.integer  "deal_id",               limit: 4
    t.string   "display_location",      limit: 191
    t.integer  "initial_impressions",   limit: 4,   default: 0
    t.integer  "remaining_impressions", limit: 4,   default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "deal_promotions", ["deal_id"], name: "index_deal_promotions_on_deal_id", using: :btree

  create_table "deal_promotions_transactions", id: false, force: :cascade do |t|
    t.integer "deal_promotion_id",     limit: 4
    t.integer "credit_transaction_id", limit: 4
  end

  add_index "deal_promotions_transactions", ["credit_transaction_id"], name: "index_deal_promotions_transactions_on_credit_transaction_id", using: :btree
  add_index "deal_promotions_transactions", ["deal_promotion_id"], name: "index_deal_promotions_transactions_on_deal_promotion_id", using: :btree

  create_table "deals", force: :cascade do |t|
    t.string   "tagline",                    limit: 191
    t.text     "description",                limit: 16777215
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "user_id",                    limit: 4
    t.string   "featured_image_uid",         limit: 191
    t.string   "list_image_uid",             limit: 191
    t.integer  "users_favorite_deals_count", limit: 4,        default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "deals", ["user_id"], name: "index_deals_on_user_id", using: :btree

  create_table "email_templates", force: :cascade do |t|
    t.string   "name",       limit: 191
    t.string   "subject",    limit: 191
    t.text     "body",       limit: 16777215
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", force: :cascade do |t|
    t.integer  "conversation_id",  limit: 4
    t.integer  "user_id",          limit: 4
    t.boolean  "system_generated",                  default: false
    t.text     "content",          limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "messages", ["conversation_id"], name: "index_messages_on_conversation_id", using: :btree
  add_index "messages", ["user_id"], name: "index_messages_on_user_id", using: :btree

  create_table "opening_hours", force: :cascade do |t|
    t.integer  "address_id", limit: 4
    t.text     "days",       limit: 16777215
    t.text     "period",     limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "opening_hours", ["address_id"], name: "index_opening_hours_on_address_id", using: :btree

  create_table "places", force: :cascade do |t|
    t.string  "country_code", limit: 191
    t.string  "postal_code",  limit: 191
    t.string  "place_name",   limit: 191
    t.string  "admin_name1",  limit: 191
    t.string  "admin_code1",  limit: 191
    t.string  "admin_name2",  limit: 191
    t.string  "admin_code2",  limit: 191
    t.string  "admin_code3",  limit: 191
    t.decimal "latitude",                      precision: 10, scale: 6
    t.decimal "longitude",                     precision: 10, scale: 6
    t.string  "geo_point_2d", limit: 191
    t.text    "geo_shape",    limit: 16777215
  end

  create_table "places_users", force: :cascade do |t|
    t.integer "user_id",  limit: 4
    t.integer "place_id", limit: 4
  end

  add_index "places_users", ["place_id"], name: "index_places_users_on_place_id", using: :btree
  add_index "places_users", ["user_id"], name: "index_places_users_on_user_id", using: :btree

  create_table "post_author_subscriptions", force: :cascade do |t|
    t.integer  "user_id",      limit: 4
    t.integer  "author_id",    limit: 4
    t.datetime "last_read_at"
    t.boolean  "notified",               default: false
    t.boolean  "unread",                 default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "post_author_subscriptions", ["author_id"], name: "index_post_author_subscriptions_on_author_id", using: :btree
  add_index "post_author_subscriptions", ["user_id", "author_id"], name: "index_post_author_subscriptions_on_user_id_and_author_id", unique: true, using: :btree
  add_index "post_author_subscriptions", ["user_id"], name: "index_post_author_subscriptions_on_user_id", using: :btree

  create_table "post_categories", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.boolean  "active"
    t.string   "ancestry",       limit: 255
    t.integer  "ancestry_depth", limit: 4,   default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "post_categories_professions", force: :cascade do |t|
    t.integer "profession_id",    limit: 4
    t.integer "post_category_id", limit: 4
  end

  add_index "post_categories_professions", ["post_category_id"], name: "index_post_categories_professions_on_post_category_id", using: :btree
  add_index "post_categories_professions", ["profession_id"], name: "index_post_categories_professions_on_profession_id", using: :btree

  create_table "post_category_subscriptions", force: :cascade do |t|
    t.integer  "user_id",          limit: 4
    t.integer  "post_category_id", limit: 4
    t.datetime "last_read_at"
    t.boolean  "notified",                   default: false
    t.boolean  "unread",                     default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "post_category_subscriptions", ["post_category_id"], name: "index_post_category_subscriptions_on_post_category_id", using: :btree
  add_index "post_category_subscriptions", ["user_id"], name: "index_post_category_subscriptions_on_user_id", using: :btree

  create_table "post_comment_user_mentions", force: :cascade do |t|
    t.integer  "user_id",         limit: 4
    t.integer  "post_comment_id", limit: 4
    t.datetime "last_read_at"
    t.boolean  "notified",                  default: false
    t.boolean  "unread",                    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "post_comment_user_mentions", ["post_comment_id"], name: "index_post_comment_user_mentions_on_post_comment_id", using: :btree
  add_index "post_comment_user_mentions", ["user_id", "post_comment_id"], name: "index_post_comment_user_mentions_on_user_id_and_post_comment_id", unique: true, using: :btree
  add_index "post_comment_user_mentions", ["user_id"], name: "index_post_comment_user_mentions_on_user_id", using: :btree

  create_table "post_comments", force: :cascade do |t|
    t.integer  "user_id",      limit: 4
    t.integer  "post_id",      limit: 4
    t.text     "content",      limit: 65535
    t.datetime "last_read_at"
    t.boolean  "notified",                   default: false
    t.boolean  "unread",                     default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "post_comments", ["post_id"], name: "index_post_comments_on_post_id", using: :btree
  add_index "post_comments", ["user_id"], name: "index_post_comments_on_user_id", using: :btree

  create_table "post_photos", force: :cascade do |t|
    t.string   "attachment_uid", limit: 255
    t.integer  "post_id",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "post_photos", ["post_id"], name: "index_post_photos_on_post_id", using: :btree

  create_table "post_sponsorings", force: :cascade do |t|
    t.integer  "post_id",               limit: 4
    t.integer  "credit_transaction_id", limit: 4
    t.integer  "initial_impressions",   limit: 4,   default: 0
    t.integer  "remaining_impressions", limit: 4,   default: 0
    t.string   "display_location",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "post_sponsorings", ["credit_transaction_id"], name: "index_post_sponsorings_on_credit_transaction_id", using: :btree
  add_index "post_sponsorings", ["post_id"], name: "index_post_sponsorings_on_post_id", using: :btree

  create_table "post_user_mentions", force: :cascade do |t|
    t.integer  "user_id",      limit: 4
    t.integer  "post_id",      limit: 4
    t.boolean  "last_read_at",           default: false
    t.boolean  "notified",               default: false
    t.boolean  "unread",                 default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "post_user_mentions", ["post_id"], name: "index_post_user_mentions_on_post_id", using: :btree
  add_index "post_user_mentions", ["user_id", "post_id"], name: "index_post_user_mentions_on_user_id_and_post_id", unique: true, using: :btree
  add_index "post_user_mentions", ["user_id"], name: "index_post_user_mentions_on_user_id", using: :btree

  create_table "post_views", force: :cascade do |t|
    t.integer  "post_id",    limit: 4
    t.decimal  "latitude",             precision: 10, scale: 6
    t.decimal  "longitude",            precision: 10, scale: 6
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "post_views", ["post_id"], name: "index_post_views_on_post_id", using: :btree

  create_table "posts", force: :cascade do |t|
    t.string   "title",                      limit: 255
    t.string   "slug",                       limit: 255
    t.string   "post_type",                  limit: 255
    t.text     "description",                limit: 65535
    t.string   "featured_image_uid",         limit: 255
    t.integer  "user_id",                    limit: 4
    t.integer  "post_category_id",           limit: 4
    t.string   "workflow_state",             limit: 255,   default: "published"
    t.text     "reject_reason",              limit: 65535
    t.integer  "reporter_id",                limit: 4
    t.integer  "users_favorite_posts_count", limit: 4,     default: 0
    t.integer  "post_views_count",           limit: 4,     default: 0
    t.boolean  "premium",                                  default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "posts", ["post_category_id"], name: "index_posts_on_post_category_id", using: :btree
  add_index "posts", ["user_id"], name: "index_posts_on_user_id", using: :btree

  create_table "price_for_categories", force: :cascade do |t|
    t.integer  "credit_amount",       limit: 4
    t.integer  "amount_cents",        limit: 4,   default: 0, null: false
    t.string   "amount_currency",     limit: 191
    t.integer  "pricing_category_id", limit: 4
    t.integer  "pricing_id",          limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "price_for_categories", ["pricing_category_id"], name: "index_price_for_categories_on_pricing_category_id", using: :btree
  add_index "price_for_categories", ["pricing_id"], name: "index_price_for_categories_on_pricing_id", using: :btree

  create_table "pricing_categories", force: :cascade do |t|
    t.string   "name",       limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pricings", force: :cascade do |t|
    t.string   "target",     limit: 191
    t.datetime "start_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pro_ratings", force: :cascade do |t|
    t.integer  "rating",     limit: 4
    t.integer  "user_id",    limit: 4
    t.integer  "pro_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pro_ratings", ["user_id", "pro_id"], name: "index_pro_ratings_on_user_id_and_pro_id", unique: true, using: :btree

  create_table "pro_reviews", force: :cascade do |t|
    t.string   "content",    limit: 191
    t.integer  "user_id",    limit: 4
    t.integer  "pro_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pro_reviews", ["pro_id"], name: "index_pro_reviews_on_pro_id", using: :btree
  add_index "pro_reviews", ["user_id", "pro_id"], name: "index_pro_reviews_on_user_id_and_pro_id", unique: true, using: :btree
  add_index "pro_reviews", ["user_id"], name: "index_pro_reviews_on_user_id", using: :btree

  create_table "professions", force: :cascade do |t|
    t.string   "name",                          limit: 191
    t.text     "description",                   limit: 16777215
    t.boolean  "active"
    t.string   "ancestry",                      limit: 191
    t.integer  "ancestry_depth",                limit: 4,        default: 0
    t.integer  "quotation_request_template_id", limit: 4
    t.integer  "pricing_category_id",           limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_uid",                     limit: 255
  end

  add_index "professions", ["ancestry"], name: "index_professions_on_ancestry", using: :btree
  add_index "professions", ["pricing_category_id"], name: "index_professions_on_pricing_category_id", using: :btree
  add_index "professions", ["quotation_request_template_id"], name: "index_professions_on_quotation_request_template_id", using: :btree

  create_table "profile_sponsorings", force: :cascade do |t|
    t.integer  "credit_transaction_id", limit: 4
    t.integer  "user_id",               limit: 4
    t.integer  "initial_impressions",   limit: 4,   default: 0
    t.integer  "remaining_impressions", limit: 4,   default: 0
    t.string   "display_location",      limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "profile_sponsorings", ["credit_transaction_id"], name: "index_profile_sponsorings_on_credit_transaction_id", using: :btree
  add_index "profile_sponsorings", ["user_id"], name: "index_profile_sponsorings_on_user_id", using: :btree

  create_table "profile_views", force: :cascade do |t|
    t.decimal  "latitude",             precision: 10, scale: 6
    t.decimal  "longitude",            precision: 10, scale: 6
    t.integer  "user_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "profile_views", ["user_id"], name: "index_profile_views_on_user_id", using: :btree

  create_table "quotation_request_professionals", force: :cascade do |t|
    t.integer "quotation_request_id", limit: 4
    t.integer "user_id",              limit: 4
    t.string  "quotation_uid",        limit: 191
    t.string  "quotation_name",       limit: 191
  end

  add_index "quotation_request_professionals", ["quotation_request_id"], name: "index_quotation_request_professionals_on_quotation_request_id", using: :btree
  add_index "quotation_request_professionals", ["user_id"], name: "index_quotation_requests_professionals_on_professional_id", using: :btree

  create_table "quotation_request_templates", force: :cascade do |t|
    t.string   "name",       limit: 191
    t.text     "fields",     limit: 16777215
    t.text     "model",      limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "quotation_requests", force: :cascade do |t|
    t.integer  "customer_id",      limit: 4
    t.integer  "classified_ad_id", limit: 4
    t.text     "specific_fields",  limit: 16777215
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "quotation_requests", ["classified_ad_id"], name: "index_quotation_requests_on_classified_ad_id", using: :btree
  add_index "quotation_requests", ["customer_id"], name: "index_quotation_requests_on_customer_id", using: :btree

  create_table "referrals", force: :cascade do |t|
    t.integer  "customer_id",    limit: 4
    t.integer  "referrer_id",    limit: 4
    t.string   "email",          limit: 191
    t.float    "reward",         limit: 24
    t.string   "workflow_state", limit: 191
    t.datetime "accepted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id",        limit: 4
    t.integer  "taggable_id",   limit: 4
    t.string   "taggable_type", limit: 191
    t.integer  "tagger_id",     limit: 4
    t.string   "tagger_type",   limit: 191
    t.string   "context",       limit: 191
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name",           limit: 255
    t.integer "taggings_count", limit: 4,   default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "user_photos", force: :cascade do |t|
    t.string   "attachment_uid", limit: 191
    t.integer  "user_id",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.integer  "account_id",             limit: 4
    t.string   "company_name",           limit: 191
    t.string   "pretty_name",            limit: 191
    t.string   "first_name",             limit: 191
    t.string   "last_name",              limit: 191
    t.boolean  "name_is_public",                                                  default: true
    t.string   "user_type",              limit: 191
    t.date     "birthdate"
    t.string   "website",                limit: 191
    t.string   "siret",                  limit: 191
    t.boolean  "admin",                                                           default: false
    t.datetime "first_login"
    t.datetime "last_login"
    t.text     "short_description",      limit: 16777215
    t.text     "long_description",       limit: 16777215
    t.text     "client_references",      limit: 16777215
    t.text     "advantages",             limit: 16777215
    t.string   "land_phone",             limit: 191
    t.string   "mobile_phone",           limit: 191
    t.string   "avatar_uid",             limit: 191
    t.integer  "primary_activity_id",    limit: 4
    t.integer  "secondary_activity_id",  limit: 4
    t.integer  "tertiary_activity_id",   limit: 4
    t.integer  "quaternary_activity_id", limit: 4
    t.boolean  "prestation"
    t.boolean  "quotation"
    t.decimal  "hourly_rate",                             precision: 8, scale: 2, default: -1.0
    t.integer  "place_id",               limit: 4
    t.boolean  "online",                                                          default: false
    t.boolean  "newsletter",                                                      default: true
    t.boolean  "email_notifications",                                             default: true
    t.integer  "rating",                 limit: 4,                                default: 0
    t.boolean  "premium_posts",                                                   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token",                  limit: 191
    t.string   "workflow_state",         limit: 191
  end

  add_index "users", ["account_id"], name: "index_users_on_account_id", using: :btree
  add_index "users", ["place_id"], name: "index_users_on_place_id", using: :btree

  create_table "users_favorite_deals", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "deal_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users_favorite_deals", ["deal_id"], name: "index_users_favorite_deals_on_deal_id", using: :btree
  add_index "users_favorite_deals", ["user_id", "deal_id"], name: "index_users_favorite_deals_on_user_id_and_deal_id", unique: true, using: :btree
  add_index "users_favorite_deals", ["user_id"], name: "index_users_favorite_deals_on_user_id", using: :btree

  create_table "users_favorite_post_comments", force: :cascade do |t|
    t.integer  "user_id",         limit: 4
    t.integer  "post_comment_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users_favorite_post_comments", ["post_comment_id"], name: "index_users_favorite_post_comments_on_post_comment_id", using: :btree
  add_index "users_favorite_post_comments", ["user_id", "post_comment_id"], name: "index_users_favorite_post_comments_on_user_and_post_comment_ids", unique: true, using: :btree
  add_index "users_favorite_post_comments", ["user_id"], name: "index_users_favorite_post_comments_on_user_id", using: :btree

  create_table "users_favorite_posts", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "post_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users_favorite_posts", ["post_id"], name: "index_users_favorite_posts_on_post_id", using: :btree
  add_index "users_favorite_posts", ["user_id", "post_id"], name: "index_users_favorite_posts_on_user_id_and_post_id", unique: true, using: :btree
  add_index "users_favorite_posts", ["user_id"], name: "index_users_favorite_posts_on_user_id", using: :btree

  create_table "users_favorite_professionals", force: :cascade do |t|
    t.integer  "user_id",         limit: 4
    t.integer  "professional_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_foreign_key "post_author_subscriptions", "users"
  add_foreign_key "post_categories_professions", "post_categories"
  add_foreign_key "post_categories_professions", "professions"
  add_foreign_key "post_category_subscriptions", "post_categories"
  add_foreign_key "post_category_subscriptions", "users"
  add_foreign_key "post_comment_user_mentions", "post_comments"
  add_foreign_key "post_comment_user_mentions", "users"
  add_foreign_key "post_comments", "posts"
  add_foreign_key "post_comments", "users"
  add_foreign_key "post_photos", "posts"
  add_foreign_key "post_sponsorings", "credit_transactions"
  add_foreign_key "post_sponsorings", "posts"
  add_foreign_key "post_user_mentions", "posts"
  add_foreign_key "post_user_mentions", "users"
  add_foreign_key "post_views", "posts"
  add_foreign_key "posts", "post_categories"
  add_foreign_key "users_favorite_deals", "deals"
  add_foreign_key "users_favorite_deals", "users"
  add_foreign_key "users_favorite_post_comments", "post_comments"
  add_foreign_key "users_favorite_post_comments", "users"
  add_foreign_key "users_favorite_posts", "posts"
  add_foreign_key "users_favorite_posts", "users"
end
