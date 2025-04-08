require 'rails_helper'

RSpec.describe "analytics/index", type: :view do
  before do
    assign(:top_searches, {"test" => 5, "example" => 3})
    assign(:top_searches_today, {"today" => 2})
    assign(:recent_user_searches, [
      SearchQuery.new(
        ip_address: "127.0.0.1",
        final_query: "recent search",
        timestamp: Time.current
      )
    ])
  end

  it "displays the analytics sections" do
    render
    expect(rendered).to include("Search Analytics")
    expect(rendered).to include("Top 20 Overall Searches")
    expect(rendered).to include("Top 10 Searches Today")
  end

  it "shows search counts" do
    render
    expect(rendered).to include("<span class=\"font-mono bg-gray-100 p-1 rounded\">test</span> (5)")
    expect(rendered).to include("<span class=\"font-mono bg-gray-100 p-1 rounded\">example</span> (3)")
  end
end
