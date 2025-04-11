import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "query", "feedback" ]
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
    
    if (queryValue) {
      this.showFeedback(`Typing: "${queryValue}"`)
    } else {
      this.showFeedback("Start typing your search...")
    }

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

  showFeedback(message) {
    if (this.hasFeedbackTarget) {
      this.feedbackTarget.textContent = message
    }
  }

  async performSearch(query) {
    if (query === null || query === undefined || query === "") {
      this.showFeedback("Search query is empty. Please type something.")
      return;
    }

    this.showFeedback(`Searching for: "${query}"`)

    const url = '/searches';
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content;

    try {
      const response = await fetch(url, {
          method: 'POST',
          body: JSON.stringify({ query: query }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'text/vnd.turbo-stream.html, text/html, application/xhtml+xml',
            'X-CSRF-Token': csrfToken
          }
      });

      if (!response.ok) {
          this.showFeedback(`Error: Search request failed - ${response.statusText}`)
          return;
      }
      
      this.showFeedback(`Search for "${query}" submitted successfully, just hit enter to submit your search.`)

    } catch (error) {
      this.showFeedback(`Error submitting search: ${error.message}`)
      return;
    }
  }
}