class SearchesController < ApplicationController
  def index; end

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
