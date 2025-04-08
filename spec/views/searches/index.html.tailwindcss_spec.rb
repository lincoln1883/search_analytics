require 'rails_helper'

RSpec.describe "searches/index", type: :view do
  include Capybara::RSpecMatchers
  
  it "renders the search form" do
    render
    expect(rendered).to include("Search Anything")
    expect(rendered).to have_css("form")
    expect(rendered).to have_css("input#search-input")
  end

  it "includes the analytics link" do
    render
    expect(rendered).to have_css("a[href='#{analytics_path}']", text: "analytics")
  end
end
