class SearchEvent < ApplicationRecord
  validates :ip_address, presence: true
  validates :timestamp, presence: true
  validates :query, presence: true, allow_blank: true
end
