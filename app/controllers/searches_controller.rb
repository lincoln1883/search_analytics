class SearchesController < ApplicationController
  helper AnalyticsHelper # Ensure the helper is available

  def index
    # Fetch top searches
    top_searches_raw = SearchQuery.group(:final_query)
                                  .order('count_final_query DESC')
                                  .limit(20)
                                  .count(:final_query)

    top_searches_today_raw = SearchQuery.where("created_at >= ?", 24.hours.ago)
                                        .group(:final_query)
                                        .order('count_final_query DESC')
                                        .limit(10)
                                        .count(:final_query)

    # Apply filtering to top searches
    @filtered_top_searches = helpers.filter_top_searches(top_searches_raw)
    @filtered_top_searches_today = helpers.filter_top_searches(top_searches_today_raw)

    # Fetch and filter recent searches (as done previously)
    recent_user_searches_raw = SearchQuery.where("created_at >= ?", 1.hour.ago)
                                          .select(:ip_address, :final_query, :timestamp)
                                          .order(ip_address: :asc, timestamp: :desc)
    @filtered_recent_searches = recent_user_searches_raw.group_by(&:ip_address).transform_values do |searches|
      helpers.filter_searches_by_longest_start_word(searches)
    end
  end

  def create
    query = params[:query]&.strip
    ip = request.remote_ip

    if query.present?
      SearchEvent.create!(
        ip_address: ip,
        query: query,
        timestamp: Time.current
      )

      ProcessSearchEventsJob.set(wait: 5.seconds).perform_later(ip, Time.current)

      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("search_results", partial: "searches/feedback", locals: { query: query }) }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("search_results", html: "<p class='text-gray-500'>Please enter a search term.</p>") }
      end
    end
  end
end
