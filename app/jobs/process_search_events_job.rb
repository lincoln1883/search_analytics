class ProcessSearchEventsJob < ApplicationJob
  queue_as :default

  WINDOW_DURATION = 15.seconds
  DEBOUNCE_GUARD = 4.seconds

  def perform(ip_address, timestamp)
    start_time = timestamp - WINDOW_DURATION
    end_time = timestamp + DEBOUNCE_GUARD

    events = SearchEvent.where(ip_address: ip_address)
                       .where("timestamp <= ?", timestamp)
                       .order(timestamp: :asc)

    return if events.empty?

    final_event = events.last
    return if final_event.query.blank?

    latest_event_in_window = events.last
    return if latest_event_in_window.timestamp > timestamp + 1.second

    longest_event = events.max_by { |event| [event.query.length, event.timestamp] }
    final_query_text = longest_event.query

    recent_final_query_exists = SearchQuery.where(ip_address: ip_address)
                                            .where(final_query: final_query_text)
                                            .where("created_at >= ?", 1.minute.ago)
                                            .exists?

    return if recent_final_query_exists

    SearchQuery.create!(
      ip_address: ip_address,
      final_query: final_query_text,
      timestamp: longest_event.timestamp
    )

  rescue => e
    Rails.logger.error("Error in ProcessSearchEventsJob for IP #{ip_address}: #{e.message}")
  end
end
