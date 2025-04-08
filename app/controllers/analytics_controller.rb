class AnalyticsController < ApplicationController
  def index
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
end
