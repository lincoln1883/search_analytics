require 'rails_helper'

RSpec.describe SearchEvent, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      search_event = SearchEvent.new(
        ip_address: "127.0.0.1",
        query: "test query",
        timestamp: Time.current
      )
      expect(search_event).to be_valid
    end

    it "is valid with an empty query string" do
      search_event = SearchEvent.new(
        ip_address: "127.0.0.1",
        query: "",
        timestamp: Time.current
      )
      expect(search_event).to be_valid
    end

    it "is invalid without an ip_address" do
      search_event = SearchEvent.new(query: "test", timestamp: Time.current)
      expect(search_event).not_to be_valid
      expect(search_event.errors[:ip_address]).to include("can't be blank")
    end

    it "is invalid without a timestamp" do
      search_event = SearchEvent.new(ip_address: "127.0.0.1", query: "test")
      expect(search_event).not_to be_valid
      expect(search_event.errors[:timestamp]).to include("can't be blank")
    end
  end
end
