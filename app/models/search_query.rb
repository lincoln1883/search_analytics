class SearchQuery < ApplicationRecord
  validates :ip_address, presence: true
  validates :final_query, presence: true
  validates :timestamp, presence: true
end
