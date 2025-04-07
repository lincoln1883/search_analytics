class CreateSearchQueries < ActiveRecord::Migration[7.1]
  def change
    create_table :search_queries do |t|
      t.string :ip_address
      t.string :final_query
      t.datetime :timestamp

      t.timestamps
    end
  end
end
