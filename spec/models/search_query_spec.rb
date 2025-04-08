require 'rails_helper'

RSpec.describe SearchQuery, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      search_query = SearchQuery.new(
        ip_address: "127.0.0.1",
        final_query: "test query",
        timestamp: Time.current
      )
      expect(search_query).to be_valid
    end

    it "is invalid without an ip_address" do
      search_query = SearchQuery.new(final_query: "test", timestamp: Time.current)
      expect(search_query).not_to be_valid
    end

    it "is invalid without a final_query" do
      search_query = SearchQuery.new(ip_address: "127.0.0.1", timestamp: Time.current)
      expect(search_query).not_to be_valid
    end
  end
end
