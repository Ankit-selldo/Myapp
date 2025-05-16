# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_05_15_000003) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "blog_posts", force: :cascade do |t|
    t.string "title"
    t.string "slug"
    t.string "status"
    t.bigint "author_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "published_at"
    t.string "category"
    t.integer "reading_time"
    t.boolean "featured", default: false
    t.string "meta_title"
    t.text "meta_description"
    t.integer "related_product_ids", default: [], array: true
    t.index ["author_id"], name: "index_blog_posts_on_author_id"
    t.index ["category"], name: "index_blog_posts_on_category"
    t.index ["featured"], name: "index_blog_posts_on_featured"
    t.index ["slug"], name: "index_blog_posts_on_slug", unique: true
  end

  create_table "carts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "discounts", force: :cascade do |t|
    t.string "code", null: false
    t.text "description"
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.decimal "minimum_purchase", precision: 10, scale: 2
    t.datetime "starts_at", null: false
    t.datetime "expires_at", null: false
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "discount_type", null: false
    t.index ["active"], name: "index_discounts_on_active"
    t.index ["code"], name: "index_discounts_on_code", unique: true
    t.index ["expires_at"], name: "index_discounts_on_expires_at"
    t.index ["starts_at"], name: "index_discounts_on_starts_at"
  end

  create_table "discounts_products", id: false, force: :cascade do |t|
    t.bigint "discount_id", null: false
    t.bigint "product_id", null: false
    t.index ["discount_id", "product_id"], name: "index_discounts_products_on_discount_id_and_product_id", unique: true
    t.index ["discount_id"], name: "index_discounts_products_on_discount_id"
    t.index ["product_id"], name: "index_discounts_products_on_product_id"
  end

  create_table "line_items", force: :cascade do |t|
    t.bigint "cart_id", null: false
    t.integer "quantity", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "product_variant_id", null: false
    t.index ["cart_id", "product_variant_id"], name: "index_line_items_on_cart_id_and_product_variant_id", unique: true
    t.index ["cart_id"], name: "index_line_items_on_cart_id"
    t.index ["product_variant_id"], name: "index_line_items_on_product_variant_id"
  end

  create_table "newsletter_subscribers", force: :cascade do |t|
    t.string "email", null: false
    t.string "unsubscribe_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_newsletter_subscribers_on_email", unique: true
    t.index ["unsubscribe_token"], name: "index_newsletter_subscribers_on_unsubscribe_token", unique: true
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "product_id", null: false
    t.integer "quantity", default: 1, null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.decimal "total_price", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id", "product_id"], name: "index_order_items_on_order_id_and_product_id"
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
  end

  create_table "orders", force: :cascade do |t|
    t.string "number", null: false
    t.decimal "total_amount", precision: 10, scale: 2, default: "0.0", null: false
    t.bigint "user_id", null: false
    t.text "shipping_address"
    t.string "tracking_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0, null: false
    t.integer "payment_status", default: 0, null: false
    t.index ["number"], name: "index_orders_on_number", unique: true
    t.index ["payment_status"], name: "index_orders_on_payment_status"
    t.index ["status"], name: "index_orders_on_status"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "product_variants", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.string "size"
    t.string "color"
    t.integer "inventory_count", default: 0
    t.decimal "price_adjustment", precision: 10, scale: 2, default: "0.0"
    t.string "sku"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id", "size", "color"], name: "index_product_variants_on_product_id_and_size_and_color", unique: true
    t.index ["product_id"], name: "index_product_variants_on_product_id"
    t.index ["sku"], name: "index_product_variants_on_sku", unique: true
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "inventory_count"
    t.boolean "featured", default: false
    t.decimal "price", precision: 10, scale: 2, default: "0.0"
    t.string "category"
    t.bigint "user_id", null: false
    t.string "status", default: "draft"
    t.string "meta_title"
    t.text "meta_description"
    t.string "slug"
    t.text "description"
    t.index ["category"], name: "index_products_on_category"
    t.index ["featured"], name: "index_products_on_featured"
    t.index ["slug"], name: "index_products_on_slug", unique: true
    t.index ["status"], name: "index_products_on_status"
    t.index ["user_id"], name: "index_products_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "settings", force: :cascade do |t|
    t.string "key", null: false
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_settings_on_key", unique: true
  end

  create_table "sub_products", force: :cascade do |t|
    t.string "name"
    t.decimal "price"
    t.string "color"
    t.string "size"
    t.bigint "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_sub_products_on_product_id"
  end

  create_table "subscribers", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "unsubscribe_token"
    t.index ["product_id"], name: "index_subscribers_on_product_id"
    t.index ["unsubscribe_token"], name: "index_subscribers_on_unsubscribe_token", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "verification_token"
    t.datetime "email_verified_at"
    t.integer "role", default: 0
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "otp"
    t.datetime "otp_sent_at"
    t.boolean "admin", default: false, null: false
    t.index ["admin"], name: "index_users_on_admin"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["verification_token"], name: "index_users_on_verification_token"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "blog_posts", "users", column: "author_id"
  add_foreign_key "carts", "users"
  add_foreign_key "discounts_products", "discounts"
  add_foreign_key "discounts_products", "products"
  add_foreign_key "line_items", "carts"
  add_foreign_key "line_items", "product_variants"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "orders", "users"
  add_foreign_key "product_variants", "products"
  add_foreign_key "products", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "sub_products", "products"
  add_foreign_key "subscribers", "products"
end
