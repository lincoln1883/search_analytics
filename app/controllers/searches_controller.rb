class SearchesController < ApplicationController
  def index
    # Add analytics data to the search page
    @top_searches = SearchQuery.group(:final_query)
                               .order('count_final_query DESC')
                               .limit(20)
                               .count(:final_query)

    @top_searches_today = SearchQuery.where("created_at >= ?", 24.hours.ago)
                                     .group(:final_query)
                                     .order('count_final_query DESC')
                                     .limit(10)
                                     .count(:final_query)

    @recent_user_searches = SearchQuery.where("created_at >= ?", 1.hour.ago)
                                        .select(:ip_address, :final_query, :timestamp)
                                        .order(ip_address: :asc, timestamp: :desc)
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
