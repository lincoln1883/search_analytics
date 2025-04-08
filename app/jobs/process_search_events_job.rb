class ProcessSearchEventsJob < ApplicationJob
  queue_as :default

  WINDOW_DURATION = 15.seconds
  DEBOUNCE_GUARD = 4.seconds

  def perform(ip_address, trigger_timestamp)
    start_time = trigger_timestamp - WINDOW_DURATION
    end_time = trigger_timestamp + DEBOUNCE_GUARD

    relevant_events = SearchEvent.where(ip_address: ip_address)
                                 .where(timestamp: start_time..end_time)
                                 .order(timestamp: :asc)

    return if relevant_events.empty?

    latest_event_in_window = relevant_events.last
    return if latest_event_in_window.timestamp > trigger_timestamp + 1.second # Heuristic: User typed again very soon after trigger

    longest_event = relevant_events.max_by { |event| [event.query.length, event.timestamp] }
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
