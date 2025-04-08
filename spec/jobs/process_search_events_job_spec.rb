require 'rails_helper'

RSpec.describe ProcessSearchEventsJob, type: :job do
  include ActiveJob::TestHelper

  let(:ip_address) { "127.0.0.1" }
  let(:base_time) { Time.current }

  describe "#perform" do
    before do
      SearchEvent.delete_all
      SearchQuery.delete_all
    end

    after do
      clear_enqueued_jobs
      clear_performed_jobs
    end

    context "with normal typing sequence" do
      it "creates one SearchQuery for the final query" do
        ["H", "He", "Hel", "Hell", "Hello", "Hello W", "Hello Wo", "Hello Wor", "Hello Worl", "Hello World"].each_with_index do |query, index|
          SearchEvent.create!(
            ip_address: ip_address,
            query: query,
            timestamp: base_time + index.seconds
          )
        end

        perform_enqueued_jobs do
          ProcessSearchEventsJob.perform_later(ip_address, base_time + 10.seconds)
        end

        expect(SearchQuery.count).to eq(1)
        expect(SearchQuery.first.final_query).to eq("Hello World")
      end
    end

    context "with backspaces" do
      it "handles backspace sequences correctly" do
        events = [
          ["H", 0], ["He", 1], ["Hel", 2], ["Hell", 3], ["Hello", 4],
          ["Hel", 5],
          ["Hell", 6], ["Hello", 7]
        ]

        events.each do |query, offset|
          SearchEvent.create!(
            ip_address: ip_address,
            query: query,
            timestamp: base_time + offset.seconds
          )
        end

        perform_enqueued_jobs do
          ProcessSearchEventsJob.perform_later(ip_address, base_time + 8.seconds)
        end

        expect(SearchQuery.count).to eq(1)
        expect(SearchQuery.first.final_query).to eq("Hello")
      end
    end

    context "with rapid sequences" do
      it "handles very rapid typing correctly" do
        ["H", "He", "Hel"].each_with_index do |query, index|
          SearchEvent.create!(
            ip_address: ip_address,
            query: query,
            timestamp: base_time + (index * 0.1).seconds
          )
        end

        perform_enqueued_jobs do
          ProcessSearchEventsJob.perform_later(ip_address, base_time + 0.5.seconds)
        end

        expect(SearchQuery.count).to eq(1)
        expect(SearchQuery.first.final_query).to eq("Hel")
      end
    end

    context "with overlapping job runs" do
      it "prevents duplicate final queries within short time windows" do
        SearchEvent.create!(
          ip_address: ip_address,
          query: "Hello",
          timestamp: base_time
        )

        perform_enqueued_jobs do
          ProcessSearchEventsJob.perform_later(ip_address, base_time + 1.second)
          ProcessSearchEventsJob.perform_later(ip_address, base_time + 2.seconds)
        end

        expect(SearchQuery.count).to eq(1)
      end
    end

    context "with empty input" do
      it "doesn't create SearchQuery for empty queries" do
        events = [
          ["test", base_time],
          ["", base_time + 1.second]
        ]

        events.each do |query, timestamp|
          SearchEvent.create!(
            ip_address: ip_address,
            query: query,
            timestamp: timestamp
          )
        end

        perform_enqueued_jobs do
          ProcessSearchEventsJob.perform_later(ip_address, base_time + 2.seconds)
        end

        expect(SearchQuery.count).to eq(0)
      end
    end

    context "with empty input" do
      it "doesn't create SearchQuery for empty queries" do
        ["test", "tes", "te", "t", ""].each_with_index do |query, index|
          SearchEvent.create!(
            ip_address: ip_address,
            query: query,
            timestamp: base_time + index.seconds
          )
        end

        perform_enqueued_jobs do
          ProcessSearchEventsJob.perform_later(ip_address, base_time + 5.seconds)
        end

        expect(SearchQuery.count).to eq(0)
      end
    end
  end
end
