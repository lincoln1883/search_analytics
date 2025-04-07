class CreateSearchEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :search_events do |t|
      t.string :ip_address
      t.text :query
      t.datetime :timestamp
      t.boolean :processed
    end
  end
end
