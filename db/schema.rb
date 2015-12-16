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

ActiveRecord::Schema.define(version: 20151216085249) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_trgm"
  enable_extension "unaccent"
  enable_extension "pgcrypto"
  enable_extension "uuid-ossp"

  create_table "oauth_providers", force: true do |t|
    t.text     "name",       null: false
    t.text     "key",        null: false
    t.text     "secret",     null: false
    t.text     "scope"
    t.integer  "order"
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.text     "strategy"
    t.text     "path"
    t.index ["name"], :name => "oauth_providers_name_unique", :unique => true
  end

  create_table "channels", force: true do |t|
    t.text     "name",              null: false
    t.text     "description",       null: false
    t.text     "permalink",         null: false
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.text     "twitter"
    t.text     "facebook"
    t.text     "email"
    t.text     "image"
    t.text     "website"
    t.text     "video_url"
    t.text     "how_it_works"
    t.text     "how_it_works_html"
    t.string   "terms_url"
    t.text     "video_embed_url"
    t.text     "ga_code"
    t.index ["permalink"], :name => "index_channels_on_permalink", :unique => true
  end

  create_table "countries", force: true do |t|
    t.text     "name",       null: false
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.text     "email"
    t.text     "name"
    t.boolean  "newsletter",                              default: false
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.boolean  "admin",                                   default: false
    t.text     "address_street"
    t.text     "address_number"
    t.text     "address_complement"
    t.text     "address_neighbourhood"
    t.text     "address_city"
    t.text     "address_state"
    t.text     "address_zip_code"
    t.text     "phone_number"
    t.text     "locale",                                  default: "pt",  null: false
    t.text     "cpf"
    t.string   "encrypted_password",          limit: 128, default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                           default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "twitter"
    t.string   "facebook_link"
    t.string   "other_link"
    t.text     "uploaded_image"
    t.string   "moip_login"
    t.string   "state_inscription"
    t.integer  "channel_id"
    t.datetime "deactivated_at"
    t.text     "reactivate_token"
    t.text     "address_country"
    t.integer  "country_id"
    t.text     "authentication_token", :default => { :expr => "md5(((random())::text || (clock_timestamp())::text))" },                                    null: false
    t.boolean  "zero_credits",                            default: false
    t.text     "about_html"
    t.text     "cover_image"
    t.text     "permalink"
    t.boolean  "subscribed_to_project_posts",             default: true
    t.index ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
    t.index ["channel_id"], :name => "fk__users_channel_id"
    t.index ["country_id"], :name => "fk__users_country_id"
    t.index ["email"], :name => "index_users_on_email", :unique => true
    t.index ["name"], :name => "index_users_on_name"
    t.index ["permalink"], :name => "index_users_on_permalink", :unique => true
    t.index ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
    t.foreign_key ["channel_id"], "channels", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_users_channel_id"
    t.foreign_key ["country_id"], "countries", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_users_country_id"
  end

  create_table "authorizations", force: true do |t|
    t.integer  "oauth_provider_id", null: false
    t.integer  "user_id",           null: false
    t.text     "uid",               null: false
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.index ["oauth_provider_id", "user_id"], :name => "index_authorizations_on_oauth_provider_id_and_user_id", :unique => true
    t.index ["oauth_provider_id"], :name => "fk__authorizations_oauth_provider_id"
    t.index ["uid", "oauth_provider_id"], :name => "index_authorizations_on_uid_and_oauth_provider_id", :unique => true
    t.index ["user_id"], :name => "fk__authorizations_user_id"
    t.foreign_key ["oauth_provider_id"], "oauth_providers", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_authorizations_oauth_provider_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_authorizations_user_id"
  end

  create_table "banks", force: true do |t|
    t.text     "name",       null: false
    t.text     "code",       null: false
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.index ["code"], :name => "index_banks_on_code", :unique => true
  end

  create_table "bank_accounts", force: true do |t|
    t.integer  "user_id"
    t.text     "account",        null: false
    t.text     "agency",         null: false
    t.text     "owner_name",     null: false
    t.text     "owner_document", null: false
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.text     "account_digit",  null: false
    t.text     "agency_digit"
    t.integer  "bank_id",        null: false
    t.index ["bank_id"], :name => "fk__bank_accounts_bank_id"
    t.index ["user_id"], :name => "index_bank_accounts_on_user_id"
    t.foreign_key ["bank_id"], "banks", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_bank_accounts_bank_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_bank_accounts_user_id"
  end

  create_table "categories", force: true do |t|
    t.text     "name_pt",    null: false
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.string   "name_en"
    t.string   "name_fr"
    t.index ["name_pt"], :name => "categories_name_unique", :unique => true
    t.index ["name_pt"], :name => "index_categories_on_name_pt"
  end

  create_table "category_followers", force: true do |t|
    t.integer  "category_id", null: false
    t.integer  "user_id",     null: false
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.index ["category_id"], :name => "index_category_followers_on_category_id"
    t.index ["user_id"], :name => "index_category_followers_on_user_id"
    t.foreign_key ["category_id"], "categories", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_category_followers_category_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_category_followers_user_id"
  end

  create_table "category_notifications", force: true do |t|
    t.integer  "user_id",       null: false
    t.integer  "category_id",   null: false
    t.text     "from_email",    null: false
    t.text     "from_name",     null: false
    t.text     "template_name", null: false
    t.text     "locale",        null: false
    t.datetime "sent_at"
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.datetime "deliver_at", :default => { :expr => "now()" }
    t.index ["category_id"], :name => "fk__category_notifications_category_id"
    t.index ["user_id"], :name => "fk__category_notifications_user_id"
    t.foreign_key ["category_id"], "categories", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_category_notifications_category_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_category_notifications_user_id"
  end

  create_table "channel_partners", force: true do |t|
    t.text     "url",        null: false
    t.text     "image",      null: false
    t.integer  "channel_id", null: false
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.index ["channel_id"], :name => "fk__channel_partners_channel_id"
    t.foreign_key ["channel_id"], "channels", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_channel_partners_channel_id"
  end

  create_table "channel_posts", force: true do |t|
    t.text     "title",                        null: false
    t.text     "body",                         null: false
    t.text     "body_html",                    null: false
    t.integer  "channel_id",                   null: false
    t.integer  "user_id",                      null: false
    t.boolean  "visible",      default: false, null: false
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.datetime "published_at"
    t.index ["channel_id"], :name => "index_channel_posts_on_channel_id"
    t.index ["user_id"], :name => "index_channel_posts_on_user_id"
    t.foreign_key ["channel_id"], "channels", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_channel_posts_channel_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_channel_posts_user_id"
  end

  create_table "channel_post_notifications", force: true do |t|
    t.integer  "user_id",         null: false
    t.integer  "channel_post_id", null: false
    t.text     "from_email",      null: false
    t.text     "from_name",       null: false
    t.text     "template_name",   null: false
    t.text     "locale",          null: false
    t.datetime "sent_at"
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.datetime "deliver_at", :default => { :expr => "now()" }
    t.index ["channel_post_id"], :name => "fk__channel_post_notifications_channel_post_id"
    t.index ["user_id"], :name => "fk__channel_post_notifications_user_id"
    t.foreign_key ["channel_post_id"], "channel_posts", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_channel_post_notifications_channel_post_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_channel_post_notifications_user_id"
  end

  create_table "cities", force: true do |t|
    t.string   "name",       null: false
    t.string   "acronym",    null: false
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.index ["acronym"], :name => "cities_acronym_unique", :unique => true
    t.index ["name"], :name => "cities_name_unique", :unique => true
  end

  create_table "genres", force: true do |t|
    t.text     "name_pt",    null: false
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.string   "name_en"
    t.string   "name_fr"
    t.index ["name_pt"], :name => "index_genres_on_name_pt"
  end

  create_table "states", force: true do |t|
    t.string   "name",       null: false
    t.string   "acronym",    null: false
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.index ["acronym"], :name => "states_acronym_unique", :unique => true
    t.index ["name"], :name => "states_name_unique", :unique => true
  end

  create_table "projects", force: true do |t|
    t.text     "name",                                      null: false
    t.integer  "user_id",                                   null: false
    t.integer  "category_id",                               null: false
    t.decimal  "goal"
    t.text     "headline"
    t.text     "video_url"
    t.text     "short_url"
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.text     "about_html"
    t.boolean  "recommended",               default: false
    t.text     "home_page_comment"
    t.text     "permalink",                                 null: false
    t.text     "video_thumbnail"
    t.string   "state"
    t.integer  "online_days"
    t.datetime "online_date"
    t.text     "more_links"
    t.text     "first_contributions"
    t.string   "uploaded_image"
    t.string   "video_embed_url"
    t.text     "referral_link"
    t.datetime "sent_to_analysis_at"
    t.text     "audited_user_name"
    t.text     "audited_user_cpf"
    t.text     "audited_user_moip_login"
    t.text     "audited_user_phone_number"
    t.datetime "sent_to_draft_at"
    t.datetime "rejected_at"
    t.text     "traffic_sources"
    t.text     "budget"
    t.tsvector "full_text_index"
    t.text     "budget_html"
    t.datetime "expires_at"
    t.text     "tagline"
    t.datetime "project_start_date"
    t.datetime "project_end_date"
    t.integer  "city_id"
    t.integer  "country_id"
    t.integer  "state_id"
    t.integer  "genre_id"
    t.index ["category_id"], :name => "index_projects_on_category_id"
    t.index ["city_id"], :name => "fk__projects_city_id"
    t.index ["country_id"], :name => "fk__projects_country_id"
    t.index ["full_text_index"], :name => "projects_full_text_index_ix", :kind => "gin"
    t.index ["genre_id"], :name => "fk__projects_genre_id"
    t.index ["name"], :name => "index_projects_on_name"
    t.index ["permalink"], :name => "index_projects_on_permalink", :unique => true, :case_sensitive => false
    t.index ["state_id"], :name => "fk__projects_state_id"
    t.index ["user_id"], :name => "index_projects_on_user_id"
    t.foreign_key ["category_id"], "categories", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "projects_category_id_reference"
    t.foreign_key ["city_id"], "cities", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_projects_city_id"
    t.foreign_key ["country_id"], "countries", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_projects_country_id"
    t.foreign_key ["genre_id"], "genres", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_projects_genre_id"
    t.foreign_key ["state_id"], "states", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_projects_state_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "projects_user_id_reference"
  end

  create_table "channels_projects", force: true do |t|
    t.integer "channel_id"
    t.integer "project_id"
    t.index ["channel_id", "project_id"], :name => "index_channels_projects_on_channel_id_and_project_id", :unique => true
    t.index ["project_id"], :name => "index_channels_projects_on_project_id"
    t.foreign_key ["channel_id"], "channels", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_channels_projects_channel_id"
    t.foreign_key ["project_id"], "projects", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_channels_projects_project_id"
  end

  create_table "channels_subscribers", force: true do |t|
    t.integer "user_id",    null: false
    t.integer "channel_id", null: false
    t.index ["channel_id"], :name => "fk__channels_subscribers_channel_id"
    t.index ["user_id", "channel_id"], :name => "index_channels_subscribers_on_user_id_and_channel_id", :unique => true
    t.index ["user_id"], :name => "fk__channels_subscribers_user_id"
    t.foreign_key ["channel_id"], "channels", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_channels_subscribers_channel_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_channels_subscribers_user_id"
  end

  create_table "rewards", force: true do |t|
    t.integer  "project_id",            null: false
    t.decimal  "minimum_value",         null: false
    t.integer  "maximum_contributions"
    t.text     "description",           null: false
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.integer  "row_order"
    t.text     "last_changes"
    t.datetime "deliver_at"
    t.index ["project_id"], :name => "index_rewards_on_project_id"
    t.foreign_key ["project_id"], "projects", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "rewards_project_id_reference"
  end

  create_table "contributions", force: true do |t|
    t.integer  "project_id",                            null: false
    t.integer  "user_id",                               null: false
    t.integer  "reward_id"
    t.decimal  "value",                                 null: false
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.boolean  "anonymous",             default: false, null: false
    t.boolean  "notified_finish",       default: false
    t.text     "payer_name"
    t.text     "payer_email",                           null: false
    t.text     "payer_document"
    t.text     "address_street"
    t.text     "address_number"
    t.text     "address_complement"
    t.text     "address_neighbourhood"
    t.text     "address_zip_code"
    t.text     "address_city"
    t.text     "address_state"
    t.text     "address_phone_number"
    t.text     "payment_choice"
    t.decimal  "payment_service_fee"
    t.text     "referral_link"
    t.integer  "country_id"
    t.datetime "deleted_at"
    t.index ["country_id"], :name => "fk__contributions_country_id"
    t.index ["created_at"], :name => "index_contributions_on_created_at"
    t.index ["project_id"], :name => "index_contributions_on_project_id"
    t.index ["reward_id"], :name => "index_contributions_on_reward_id"
    t.index ["user_id"], :name => "index_contributions_on_user_id"
    t.foreign_key ["country_id"], "countries", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_contributions_country_id"
    t.foreign_key ["project_id"], "projects", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "contributions_project_id_reference"
    t.foreign_key ["reward_id"], "rewards", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "contributions_reward_id_reference"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "contributions_user_id_reference"
  end

  create_table "payments", force: true do |t|
    t.integer  "contribution_id",               null: false
    t.text     "state",                         null: false
    t.text     "key",                           null: false
    t.text     "gateway",                       null: false
    t.text     "gateway_id"
    t.decimal  "gateway_fee"
    t.json     "gateway_data"
    t.text     "payment_method",                null: false
    t.decimal  "value",                         null: false
    t.integer  "installments",      default: 1, null: false
    t.decimal  "installment_value"
    t.datetime "paid_at"
    t.datetime "refused_at"
    t.datetime "pending_refund_at"
    t.datetime "refunded_at"
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.tsvector "full_text_index"
    t.datetime "deleted_at"
    t.datetime "chargeback_at"
    t.index ["contribution_id"], :name => "fk__payments_contribution_id"
    t.index ["full_text_index"], :name => "payments_full_text_index_ix", :kind => "gin"
    t.foreign_key ["contribution_id"], "contributions", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_payments_contribution_id"
  end

  create_view "reward_details", " SELECT r.id,\n    r.description,\n    r.minimum_value,\n    r.maximum_contributions,\n    r.deliver_at,\n    r.updated_at,\n    paid_count(r.*) AS paid_count,\n    waiting_payment_count(r.*) AS waiting_payment_count\n   FROM rewards r", :force => true
  create_view "contribution_details", " SELECT pa.id,\n    c.id AS contribution_id,\n    pa.id AS payment_id,\n    c.user_id,\n    c.project_id,\n    c.reward_id,\n    p.permalink,\n    p.name AS project_name,\n    img_thumbnail(p.*) AS project_img,\n    p.online_date AS project_online_date,\n    p.expires_at AS project_expires_at,\n    p.state AS project_state,\n    u.name AS user_name,\n    profile_img_thumbnail(u.*) AS user_profile_img,\n    u.email,\n    c.anonymous,\n    c.payer_email,\n    pa.key,\n    pa.value,\n    pa.installments,\n    pa.installment_value,\n    pa.state,\n    is_second_slip(pa.*) AS is_second_slip,\n    pa.gateway,\n    pa.gateway_id,\n    pa.gateway_fee,\n    pa.gateway_data,\n    pa.payment_method,\n    pa.created_at,\n    pa.created_at AS pending_at,\n    pa.paid_at,\n    pa.refused_at,\n    pa.pending_refund_at,\n    pa.refunded_at,\n    pa.full_text_index,\n    row_to_json(r.*) AS reward\n   FROM ((((projects p\n     JOIN contributions c ON ((c.project_id = p.id)))\n     JOIN payments pa ON ((c.id = pa.contribution_id)))\n     JOIN users u ON ((c.user_id = u.id)))\n     LEFT JOIN reward_details r ON ((r.id = c.reward_id)))", :force => true
  create_table "contribution_notifications", force: true do |t|
    t.integer  "user_id",         null: false
    t.integer  "contribution_id", null: false
    t.text     "from_email",      null: false
    t.text     "from_name",       null: false
    t.text     "template_name",   null: false
    t.text     "locale",          null: false
    t.datetime "sent_at"
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.datetime "deliver_at", :default => { :expr => "now()" }
    t.index ["contribution_id"], :name => "fk__contribution_notifications_contribution_id"
    t.index ["user_id"], :name => "fk__contribution_notifications_user_id"
    t.foreign_key ["contribution_id"], "contributions", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_contribution_notifications_contribution_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_contribution_notifications_user_id"
  end

  create_view "contribution_reports", " SELECT b.project_id,\n    u.name,\n    replace((b.value)::text, '.'::text, ','::text) AS value,\n    replace((r.minimum_value)::text, '.'::text, ','::text) AS minimum_value,\n    r.description,\n    p.gateway,\n    (p.gateway_data -> 'acquirer_name'::text) AS acquirer_name,\n    (p.gateway_data -> 'tid'::text) AS acquirer_tid,\n    p.payment_method,\n    replace((p.gateway_fee)::text, '.'::text, ','::text) AS payment_service_fee,\n    p.key,\n    (b.created_at)::date AS created_at,\n    (p.paid_at)::date AS confirmed_at,\n    u.email,\n    b.payer_email,\n    b.payer_name,\n    COALESCE(b.payer_document, u.cpf) AS cpf,\n    u.address_street,\n    u.address_complement,\n    u.address_number,\n    u.address_neighbourhood,\n    u.address_city,\n    u.address_state,\n    u.address_zip_code,\n    p.state\n   FROM (((contributions b\n     JOIN users u ON ((u.id = b.user_id)))\n     JOIN payments p ON ((p.contribution_id = b.id)))\n     LEFT JOIN rewards r ON ((r.id = b.reward_id)))\n  WHERE (p.state = ANY (ARRAY[('paid'::character varying)::text, ('refunded'::character varying)::text, ('pending_refund'::character varying)::text]))", :force => true
  create_table "settings", force: true do |t|
    t.text     "name",       null: false
    t.text     "value"
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.index ["name"], :name => "index_configurations_on_name", :unique => true
  end

  create_view "contribution_reports_for_project_owners", " SELECT b.project_id,\n    COALESCE(r.id, 0) AS reward_id,\n    p.user_id AS project_owner_id,\n    r.description AS reward_description,\n    (r.deliver_at)::date AS deliver_at,\n    (pa.paid_at)::date AS confirmed_at,\n    pa.value AS contribution_value,\n    (pa.value * ( SELECT (settings.value)::numeric AS value\n           FROM settings\n          WHERE (settings.name = 'catarse_fee'::text))) AS service_fee,\n    u.email AS user_email,\n    COALESCE(b.payer_document, u.cpf) AS cpf,\n    u.name AS user_name,\n    b.payer_email,\n    pa.gateway,\n    b.anonymous,\n    pa.state,\n    waiting_payment(pa.*) AS waiting_payment,\n    COALESCE(u.address_street, b.address_street) AS street,\n    COALESCE(u.address_complement, b.address_complement) AS complement,\n    COALESCE(u.address_number, b.address_number) AS address_number,\n    COALESCE(u.address_neighbourhood, b.address_neighbourhood) AS neighbourhood,\n    COALESCE(u.address_city, b.address_city) AS city,\n    COALESCE(u.address_state, b.address_state) AS address_state,\n    COALESCE(u.address_zip_code, b.address_zip_code) AS zip_code\n   FROM ((((contributions b\n     JOIN users u ON ((u.id = b.user_id)))\n     JOIN projects p ON ((b.project_id = p.id)))\n     JOIN payments pa ON ((pa.contribution_id = b.id)))\n     LEFT JOIN rewards r ON ((r.id = b.reward_id)))\n  WHERE (pa.state = ANY (ARRAY[('paid'::character varying)::text, ('pending'::character varying)::text]))", :force => true
  create_table "credit_cards", force: true do |t|
    t.integer  "user_id"
    t.text     "last_digits",     null: false
    t.text     "card_brand",      null: false
    t.text     "subscription_id"
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.text     "card_key"
    t.index ["user_id"], :name => "index_credit_cards_on_user_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_credit_cards_user_id"
  end

  create_table "dbhero_dataclips", force: true do |t|
    t.text     "description",                 null: false
    t.text     "raw_query",                   null: false
    t.text     "token",                       null: false
    t.text     "user"
    t.boolean  "private",     default: false, null: false
    t.datetime "created_at", :default => { :expr => "now()" },                  null: false
    t.datetime "updated_at",                  null: false
    t.index ["token"], :name => "index_dbhero_dataclips_on_token", :unique => true
    t.index ["user"], :name => "index_dbhero_dataclips_on_user"
  end

  create_view "financial_reports", " SELECT p.name,\n    u.moip_login,\n    p.goal,\n    p.expires_at,\n    p.state\n   FROM (projects p\n     JOIN users u ON ((u.id = p.user_id)))", :force => true
  create_table "job_perks", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "job_rewards", force: true do |t|
    t.string   "job_reward_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "jobs", force: true do |t|
    t.string   "job_name"
    t.integer  "project_id"
    t.integer  "category_id"
    t.string   "job_description"
    t.string   "gender"
    t.integer  "job_count"
    t.integer  "duration"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "permalink"
    t.datetime "job_start_date"
    t.datetime "job_end_date"
    t.integer  "job_reward_id"
    t.index ["category_id"], :name => "fk__jobs_category_id"
    t.index ["job_reward_id"], :name => "fk__jobs_job_reward_id"
    t.index ["permalink"], :name => "index_jobs_on_permalink", :unique => true
    t.index ["project_id"], :name => "fk__jobs_project_id"
    t.foreign_key ["category_id"], "categories", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_jobs_category_id"
    t.foreign_key ["job_reward_id"], "job_rewards", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_jobs_job_reward_id"
    t.foreign_key ["project_id"], "projects", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_jobs_project_id"
  end

  create_table "payment_logs", force: true do |t|
    t.string   "gateway_id", null: false
    t.json     "data",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payment_notifications", force: true do |t|
    t.integer  "contribution_id", null: false
    t.text     "extra_data"
    t.datetime "created_at", :default => { :expr => "now()" },      null: false
    t.datetime "updated_at",      null: false
    t.integer  "payment_id"
    t.index ["contribution_id"], :name => "index_payment_notifications_on_contribution_id"
    t.index ["payment_id"], :name => "fk__payment_notifications_payment_id"
    t.foreign_key ["contribution_id"], "contributions", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "payment_notifications_backer_id_fk"
    t.foreign_key ["payment_id"], "payments", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_payment_notifications_payment_id"
  end

  create_table "payment_transfers", force: true do |t|
    t.integer  "user_id",       null: false
    t.integer  "payment_id",    null: false
    t.text     "transfer_id",   null: false
    t.json     "transfer_data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["payment_id"], :name => "fk__payment_transfers_payment_id"
    t.index ["user_id"], :name => "fk__payment_transfers_user_id"
    t.foreign_key ["payment_id"], "payments", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_payment_transfers_payment_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_payment_transfers_user_id"
  end

  create_table "paypal_payments", id: false, force: true do |t|
    t.text "data"
    t.text "hora"
    t.text "fusohorario"
    t.text "nome"
    t.text "tipo"
    t.text "status"
    t.text "moeda"
    t.text "Valuebruto"
    t.text "tarifa"
    t.text "liquido"
    t.text "doe_mail"
    t.text "parae_mail"
    t.text "iddatransacao"
    t.text "statusdoequivalente"
    t.text "statusdoendereco"
    t.text "titulodoitem"
    t.text "iddoitem"
    t.text "Valuedoenvioemanuseio"
    t.text "Valuedoseguro"
    t.text "impostosobrevendas"
    t.text "opcao1nome"
    t.text "opcao1Value"
    t.text "opcao2nome"
    t.text "opcao2Value"
    t.text "sitedoleilao"
    t.text "iddocomprador"
    t.text "urldoitem"
    t.text "datadetermino"
    t.text "iddaescritura"
    t.text "iddafatura"
    t.text "idtxn_dereferência"
    t.text "numerodafatura"
    t.text "numeropersonalizado"
    t.text "iddorecibo"
    t.text "saldo"
    t.text "enderecolinha1"
    t.text "enderecolinha2_distrito_bairro"
    t.text "cidade"
    t.text "estado_regiao_território_prefeitura_republica"
    t.text "cep"
    t.text "pais"
    t.text "numerodotelefoneparacontato"
    t.text "extra"
  end

  create_table "project_accounts", force: true do |t|
    t.integer  "project_id",            null: false
    t.integer  "bank_id"
    t.text     "email",                 null: false
    t.text     "state_inscription"
    t.text     "address_street",        null: false
    t.text     "address_number",        null: false
    t.text     "address_complement"
    t.text     "address_city",          null: false
    t.text     "address_neighbourhood", null: false
    t.text     "address_state",         null: false
    t.text     "address_zip_code",      null: false
    t.text     "phone_number",          null: false
    t.text     "agency",                null: false
    t.text     "agency_digit",          null: false
    t.text     "account",               null: false
    t.text     "account_digit",         null: false
    t.text     "owner_name",            null: false
    t.text     "owner_document",        null: false
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.text     "account_type"
    t.index ["bank_id"], :name => "fk__project_accounts_bank_id"
    t.index ["bank_id"], :name => "index_project_accounts_on_bank_id"
    t.index ["project_id"], :name => "index_project_accounts_on_project_id"
    t.foreign_key ["bank_id"], "banks", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_project_accounts_bank_id"
    t.foreign_key ["project_id"], "projects", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_project_accounts_project_id"
  end

  create_table "project_budgets", force: true do |t|
    t.integer  "project_id",                         null: false
    t.text     "name",                               null: false
    t.decimal  "value",      precision: 8, scale: 2, null: false
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.index ["project_id"], :name => "fk__project_budgets_project_id"
    t.foreign_key ["project_id"], "projects", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_project_budgets_project_id"
  end

  create_view "project_totals", " SELECT c.project_id,\n    sum(p.value) AS pledged,\n    ((sum(p.value) / projects.goal) * (100)::numeric) AS progress,\n    sum(p.gateway_fee) AS total_payment_service_fee,\n    count(DISTINCT c.id) AS total_contributions\n   FROM ((contributions c\n     JOIN projects ON ((c.project_id = projects.id)))\n     JOIN payments p ON ((p.contribution_id = c.id)))\n  WHERE (p.state = ANY (confirmed_states()))\n  GROUP BY c.project_id, projects.id", :force => true
  create_view "project_financials", " WITH catarse_fee_percentage AS (\n         SELECT (c.value)::numeric AS total,\n            ((1)::numeric - (c.value)::numeric) AS complement\n           FROM settings c\n          WHERE (c.name = 'catarse_fee'::text)\n        ), catarse_base_url AS (\n         SELECT c.value\n           FROM settings c\n          WHERE (c.name = 'base_url'::text)\n        )\n SELECT p.id AS project_id,\n    p.name,\n    u.moip_login AS moip,\n    p.goal,\n    pt.pledged AS reached,\n    pt.total_payment_service_fee AS payment_tax,\n    (cp.total * pt.pledged) AS catarse_fee,\n    (pt.pledged * cp.complement) AS repass_value,\n    to_char(timezone(COALESCE(( SELECT settings.value\n           FROM settings\n          WHERE (settings.name = 'timezone'::text)), 'America/Sao_Paulo'::text), p.expires_at), 'dd/mm/yyyy'::text) AS expires_at,\n    ((catarse_base_url.value || '/admin/reports/contribution_reports.csv?project_id='::text) || p.id) AS contribution_report,\n    p.state\n   FROM ((((projects p\n     JOIN users u ON ((u.id = p.user_id)))\n     LEFT JOIN project_totals pt ON ((pt.project_id = p.id)))\n     CROSS JOIN catarse_fee_percentage cp)\n     CROSS JOIN catarse_base_url)", :force => true
  create_table "project_notifications", force: true do |t|
    t.integer  "user_id",       null: false
    t.integer  "project_id",    null: false
    t.text     "from_email",    null: false
    t.text     "from_name",     null: false
    t.text     "template_name", null: false
    t.text     "locale",        null: false
    t.datetime "sent_at"
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.datetime "deliver_at", :default => { :expr => "now()" }
    t.index ["project_id"], :name => "fk__project_notifications_project_id"
    t.index ["user_id"], :name => "fk__project_notifications_user_id"
    t.foreign_key ["project_id"], "projects", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_project_notifications_project_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_project_notifications_user_id"
  end

  create_table "project_posts", force: true do |t|
    t.integer  "user_id",                      null: false
    t.integer  "project_id",                   null: false
    t.text     "title",                        null: false
    t.text     "comment_html",                 null: false
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.boolean  "exclusive",    default: false
    t.index ["project_id"], :name => "index_updates_on_project_id"
    t.foreign_key ["project_id"], "projects", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "updates_project_id_fk"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "updates_user_id_fk"
  end

  create_table "project_post_notifications", force: true do |t|
    t.integer  "user_id",         null: false
    t.integer  "project_post_id", null: false
    t.text     "from_email",      null: false
    t.text     "from_name",       null: false
    t.text     "template_name",   null: false
    t.text     "locale",          null: false
    t.datetime "sent_at"
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.datetime "deliver_at", :default => { :expr => "now()" }
    t.index ["project_post_id"], :name => "fk__project_post_notifications_project_post_id"
    t.index ["user_id"], :name => "fk__project_post_notifications_user_id"
    t.foreign_key ["project_post_id"], "project_posts", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_project_post_notifications_project_post_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_project_post_notifications_user_id"
  end

  create_view "projects_for_home", " WITH recommended_projects AS (\n         SELECT 'recommended'::text AS origin,\n            recommends.id,\n            recommends.name,\n            recommends.expires_at,\n            recommends.user_id,\n            recommends.category_id,\n            recommends.goal,\n            recommends.headline,\n            recommends.video_url,\n            recommends.short_url,\n            recommends.created_at,\n            recommends.updated_at,\n            recommends.about_html,\n            recommends.recommended,\n            recommends.home_page_comment,\n            recommends.permalink,\n            recommends.video_thumbnail,\n            recommends.state,\n            recommends.online_days,\n            recommends.online_date,\n            recommends.traffic_sources,\n            recommends.more_links,\n            recommends.first_contributions AS first_backers,\n            recommends.uploaded_image,\n            recommends.video_embed_url\n           FROM projects recommends\n          WHERE (recommends.recommended AND ((recommends.state)::text = 'online'::text))\n          ORDER BY random()\n         LIMIT 3\n        ), recents_projects AS (\n         SELECT 'recents'::text AS origin,\n            recents.id,\n            recents.name,\n            recents.expires_at,\n            recents.user_id,\n            recents.category_id,\n            recents.goal,\n            recents.headline,\n            recents.video_url,\n            recents.short_url,\n            recents.created_at,\n            recents.updated_at,\n            recents.about_html,\n            recents.recommended,\n            recents.home_page_comment,\n            recents.permalink,\n            recents.video_thumbnail,\n            recents.state,\n            recents.online_days,\n            recents.online_date,\n            recents.traffic_sources,\n            recents.more_links,\n            recents.first_contributions AS first_backers,\n            recents.uploaded_image,\n            recents.video_embed_url\n           FROM projects recents\n          WHERE ((((recents.state)::text = 'online'::text) AND ((now() - recents.online_date) <= '5 days'::interval)) AND (NOT (recents.id IN ( SELECT recommends.id\n                   FROM recommended_projects recommends))))\n          ORDER BY random()\n         LIMIT 3\n        ), expiring_projects AS (\n         SELECT 'expiring'::text AS origin,\n            expiring.id,\n            expiring.name,\n            expiring.expires_at,\n            expiring.user_id,\n            expiring.category_id,\n            expiring.goal,\n            expiring.headline,\n            expiring.video_url,\n            expiring.short_url,\n            expiring.created_at,\n            expiring.updated_at,\n            expiring.about_html,\n            expiring.recommended,\n            expiring.home_page_comment,\n            expiring.permalink,\n            expiring.video_thumbnail,\n            expiring.state,\n            expiring.online_days,\n            expiring.online_date,\n            expiring.traffic_sources,\n            expiring.more_links,\n            expiring.first_contributions AS first_backers,\n            expiring.uploaded_image,\n            expiring.video_embed_url\n           FROM projects expiring\n          WHERE ((((expiring.state)::text = 'online'::text) AND (expiring.expires_at <= (now() + '14 days'::interval))) AND (NOT (expiring.id IN ( SELECT recommends.id\n                   FROM recommended_projects recommends\n                UNION\n                 SELECT recents.id\n                   FROM recents_projects recents))))\n          ORDER BY random()\n         LIMIT 3\n        )\n SELECT recommended_projects.origin,\n    recommended_projects.id,\n    recommended_projects.name,\n    recommended_projects.expires_at,\n    recommended_projects.user_id,\n    recommended_projects.category_id,\n    recommended_projects.goal,\n    recommended_projects.headline,\n    recommended_projects.video_url,\n    recommended_projects.short_url,\n    recommended_projects.created_at,\n    recommended_projects.updated_at,\n    recommended_projects.about_html,\n    recommended_projects.recommended,\n    recommended_projects.home_page_comment,\n    recommended_projects.permalink,\n    recommended_projects.video_thumbnail,\n    recommended_projects.state,\n    recommended_projects.online_days,\n    recommended_projects.online_date,\n    recommended_projects.traffic_sources,\n    recommended_projects.more_links,\n    recommended_projects.first_backers,\n    recommended_projects.uploaded_image,\n    recommended_projects.video_embed_url\n   FROM recommended_projects\nUNION\n SELECT recents_projects.origin,\n    recents_projects.id,\n    recents_projects.name,\n    recents_projects.expires_at,\n    recents_projects.user_id,\n    recents_projects.category_id,\n    recents_projects.goal,\n    recents_projects.headline,\n    recents_projects.video_url,\n    recents_projects.short_url,\n    recents_projects.created_at,\n    recents_projects.updated_at,\n    recents_projects.about_html,\n    recents_projects.recommended,\n    recents_projects.home_page_comment,\n    recents_projects.permalink,\n    recents_projects.video_thumbnail,\n    recents_projects.state,\n    recents_projects.online_days,\n    recents_projects.online_date,\n    recents_projects.traffic_sources,\n    recents_projects.more_links,\n    recents_projects.first_backers,\n    recents_projects.uploaded_image,\n    recents_projects.video_embed_url\n   FROM recents_projects\nUNION\n SELECT expiring_projects.origin,\n    expiring_projects.id,\n    expiring_projects.name,\n    expiring_projects.expires_at,\n    expiring_projects.user_id,\n    expiring_projects.category_id,\n    expiring_projects.goal,\n    expiring_projects.headline,\n    expiring_projects.video_url,\n    expiring_projects.short_url,\n    expiring_projects.created_at,\n    expiring_projects.updated_at,\n    expiring_projects.about_html,\n    expiring_projects.recommended,\n    expiring_projects.home_page_comment,\n    expiring_projects.permalink,\n    expiring_projects.video_thumbnail,\n    expiring_projects.state,\n    expiring_projects.online_days,\n    expiring_projects.online_date,\n    expiring_projects.traffic_sources,\n    expiring_projects.more_links,\n    expiring_projects.first_backers,\n    expiring_projects.uploaded_image,\n    expiring_projects.video_embed_url\n   FROM expiring_projects", :force => true
  create_view "projects_in_analysis_by_periods", " WITH weeks AS (\n         SELECT to_char(current_year_1.current_year, 'yyyy-mm W'::text) AS current_year,\n            to_char(last_year_1.last_year, 'yyyy-mm W'::text) AS last_year,\n            current_year_1.current_year AS label\n           FROM (generate_series((now() - '49 days'::interval), now(), '7 days'::interval) current_year_1(current_year)\n             JOIN generate_series((now() - '1 year 49 days'::interval), (now() - '1 year'::interval), '7 days'::interval) last_year_1(last_year) ON ((to_char(last_year_1.last_year, 'mm W'::text) = to_char(current_year_1.current_year, 'mm W'::text))))\n        ), current_year AS (\n         SELECT w.label,\n            count(*) AS current_year\n           FROM (projects p\n             JOIN weeks w ON ((w.current_year = to_char(p.sent_to_analysis_at, 'yyyy-mm W'::text))))\n          GROUP BY w.label\n        ), last_year AS (\n         SELECT w.label,\n            count(*) AS last_year\n           FROM (projects p\n             JOIN weeks w ON ((w.last_year = to_char(p.sent_to_analysis_at, 'yyyy-mm W'::text))))\n          GROUP BY w.label\n        )\n SELECT current_year.label,\n    current_year.current_year,\n    last_year.last_year\n   FROM (current_year\n     JOIN last_year USING (label))", :force => true
  create_view "recommendations", " SELECT recommendations.user_id,\n    recommendations.project_id,\n    (sum(recommendations.count))::bigint AS count\n   FROM ( SELECT b.user_id,\n            recommendations_1.id AS project_id,\n            count(DISTINCT recommenders.user_id) AS count\n           FROM (((contributions b\n             JOIN contributions backers_same_projects USING (project_id))\n             JOIN contributions recommenders ON ((recommenders.user_id = backers_same_projects.user_id)))\n             JOIN projects recommendations_1 ON ((recommendations_1.id = recommenders.project_id)))\n          WHERE ((((((((was_confirmed(b.*) AND was_confirmed(backers_same_projects.*)) AND was_confirmed(recommenders.*)) AND (b.updated_at > (now() - '6 mons'::interval))) AND (recommenders.updated_at > (now() - '2 mons'::interval))) AND ((recommendations_1.state)::text = 'online'::text)) AND (b.user_id <> backers_same_projects.user_id)) AND (recommendations_1.id <> b.project_id)) AND (NOT (EXISTS ( SELECT true AS bool\n                   FROM contributions b2\n                  WHERE ((was_confirmed(b2.*) AND (b2.user_id = b.user_id)) AND (b2.project_id = recommendations_1.id))))))\n          GROUP BY b.user_id, recommendations_1.id\n        UNION\n         SELECT b.user_id,\n            recommendations_1.id AS project_id,\n            0 AS count\n           FROM ((contributions b\n             JOIN projects p ON ((b.project_id = p.id)))\n             JOIN projects recommendations_1 ON ((recommendations_1.category_id = p.category_id)))\n          WHERE (was_confirmed(b.*) AND ((recommendations_1.state)::text = 'online'::text))) recommendations\n  WHERE (NOT (EXISTS ( SELECT true AS bool\n           FROM contributions b2\n          WHERE ((was_confirmed(b2.*) AND (b2.user_id = recommendations.user_id)) AND (b2.project_id = recommendations.project_id)))))\n  GROUP BY recommendations.user_id, recommendations.project_id\n  ORDER BY (sum(recommendations.count))::bigint DESC", :force => true
  create_table "redactor_assets", force: true do |t|
    t.integer  "user_id"
    t.string   "data_file_name",               null: false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    limit: 30
    t.string   "type",              limit: 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.index ["assetable_type", "assetable_id"], :name => "idx_redactor_assetable"
    t.index ["assetable_type", "type", "assetable_id"], :name => "idx_redactor_assetable_type"
    t.index ["user_id"], :name => "fk__redactor_assets_user_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_redactor_assets_user_id"
  end

  create_view "subscriber_reports", " SELECT u.id,\n    cs.channel_id,\n    u.name,\n    u.email\n   FROM (users u\n     JOIN channels_subscribers cs ON ((cs.user_id = u.id)))", :force => true
  create_table "talents", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "category_id"
    t.integer  "user_id"
    t.boolean  "recommended", default: false
    t.string   "state",       default: "published"
    t.string   "permalink"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "genre_id"
    t.index ["category_id"], :name => "fk__talents_category_id"
    t.index ["genre_id"], :name => "fk__talents_genre_id"
    t.index ["user_id"], :name => "fk__talents_user_id"
    t.foreign_key ["category_id"], "categories", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_talents_category_id"
    t.foreign_key ["genre_id"], "genres", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_talents_genre_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_talents_user_id"
  end

  create_table "talent_images", force: true do |t|
    t.integer  "talent_id"
    t.integer  "user_id"
    t.text     "image_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["talent_id"], :name => "fk__talent_images_talent_id"
    t.index ["user_id"], :name => "fk__talent_images_user_id"
    t.foreign_key ["talent_id"], "talents", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_talent_images_talent_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_talent_images_user_id"
  end

  create_table "talent_videos", force: true do |t|
    t.integer  "talent_id"
    t.integer  "user_id"
    t.text     "video_url"
    t.text     "video_thumbnail"
    t.string   "video_embed_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["talent_id"], :name => "fk__talent_videos_talent_id"
    t.index ["user_id"], :name => "fk__talent_videos_user_id"
    t.foreign_key ["talent_id"], "talents", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_talent_videos_talent_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_talent_videos_user_id"
  end

  create_view "talents_for_home", " WITH recommended_talents AS (\n         SELECT 'recommended'::text AS origin,\n            recommends.id,\n            recommends.title,\n            recommends.description,\n            recommends.category_id,\n            recommends.user_id,\n            recommends.recommended,\n            recommends.state,\n            recommends.permalink,\n            recommends.created_at,\n            recommends.updated_at\n           FROM talents recommends\n          WHERE (recommends.recommended AND ((recommends.state)::text = 'published'::text))\n          ORDER BY random()\n         LIMIT 3\n        ), recents_talents AS (\n         SELECT 'recents'::text AS origin,\n            recents.id,\n            recents.title,\n            recents.description,\n            recents.category_id,\n            recents.user_id,\n            recents.recommended,\n            recents.state,\n            recents.permalink,\n            recents.created_at,\n            recents.updated_at\n           FROM talents recents\n          WHERE ((((recents.state)::text = 'published'::text) AND ((now() - (recents.created_at)::timestamp with time zone) <= '5 days'::interval)) AND (NOT (recents.id IN ( SELECT recommends.id\n                   FROM recommended_talents recommends))))\n          ORDER BY random()\n         LIMIT 3\n        )\n SELECT recommended_talents.origin,\n    recommended_talents.id,\n    recommended_talents.title,\n    recommended_talents.description,\n    recommended_talents.category_id,\n    recommended_talents.user_id,\n    recommended_talents.recommended,\n    recommended_talents.state,\n    recommended_talents.permalink,\n    recommended_talents.created_at,\n    recommended_talents.updated_at\n   FROM recommended_talents\nUNION\n SELECT recents_talents.origin,\n    recents_talents.id,\n    recents_talents.title,\n    recents_talents.description,\n    recents_talents.category_id,\n    recents_talents.user_id,\n    recents_talents.recommended,\n    recents_talents.state,\n    recents_talents.permalink,\n    recents_talents.created_at,\n    recents_talents.updated_at\n   FROM recents_talents", :force => true
  create_table "total_backed_ranges", primary_key: "name", force: true do |t|
    t.decimal "lower"
    t.decimal "upper"
  end

  create_table "unsubscribes", force: true do |t|
    t.integer  "user_id",    null: false
    t.integer  "project_id", null: false
    t.datetime "created_at", :default => { :expr => "now()" }, null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], :name => "index_unsubscribes_on_project_id"
    t.index ["user_id"], :name => "index_unsubscribes_on_user_id"
    t.foreign_key ["project_id"], "projects", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "unsubscribes_project_id_fk"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "unsubscribes_user_id_fk"
  end

  create_table "user_links", force: true do |t|
    t.text     "link",       null: false
    t.integer  "user_id",    null: false
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.index ["user_id"], :name => "fk__user_links_user_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_user_links_user_id"
  end

  create_table "user_notifications", force: true do |t|
    t.integer  "user_id",       null: false
    t.text     "from_email",    null: false
    t.text     "from_name",     null: false
    t.text     "template_name", null: false
    t.text     "locale",        null: false
    t.datetime "sent_at"
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.datetime "deliver_at", :default => { :expr => "now()" }
    t.index ["user_id"], :name => "fk__user_notifications_user_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_user_notifications_user_id"
  end

end
