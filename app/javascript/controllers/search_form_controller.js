import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "query" ]
  static values = {
    debounceWait: { type: Number, default: 500 }
  }

  connect() {
    this.debounceTimer = null
  }

  disconnect() {
    this.clearDebounceTimer()
  }

  handleInput(event) {
    const queryValue = this.queryTarget.value.trim()

    this.clearDebounceTimer()

    this.debounceTimer = setTimeout(() => {
      this.performSearch(queryValue)
    }, this.debounceWaitValue)
  }

  clearDebounceTimer() {
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer)
    }
  }

  async performSearch(query) {
    if (query === null || query === undefined || query === "") {
        console.log("Debounced search triggered with empty query. Skipping.")
      return;
    }

    console.log(`Debounced search for: "${query}"`)

    const url = '/searches';

    try {
      const response = await post(url, {
          body: JSON.stringify({ query: query }),
          responseKind: 'turbo-stream',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'text/vnd.turbo-stream.html, text/html, application/xhtml+xml'
          }
      });

      if (!response.ok) {
          console.error("Search request failed:", response.statusText);
          return;
      }
      

    } catch (error) {
      console.error("Error submitting search:", error);
      return;
    }
  }
}