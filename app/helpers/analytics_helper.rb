module AnalyticsHelper
  # Filters a list of searches for a user, keeping only the longest query
  # when multiple queries share the same starting word.
  # Keeps searches that don't share a starting word.
  def filter_searches_by_longest_start_word(searches)
    return [] if searches.blank?

    # Group searches by the first word of their final_query
    grouped_by_first_word = searches.group_by do |search|
      search.final_query.split.first || "" # Handle empty/nil queries
    end

    filtered_searches = []

    grouped_by_first_word.each do |first_word, group|
      if group.length == 1
        # If only one search starts with this word, keep it
        filtered_searches << group.first
      else
        # If multiple searches start with this word, find and keep the longest
        longest_in_group = group.max_by { |s| s.final_query.length }
        filtered_searches << longest_in_group
      end
    end

    # Return the filtered list, maybe sort by timestamp again if needed
    filtered_searches.sort_by(&:timestamp).reverse
  end

  # Filters an aggregated search count hash (e.g., {"term" => count})
  # If multiple terms share the same starting word, keeps only the longest one.
  # If lengths are tied, keeps the one with the highest count.
  def filter_top_searches(search_counts)
    return {} if search_counts.blank?

    # Group terms (keys) by their first word
    grouped_by_first_word = search_counts.keys.group_by do |term|
      term.split.first || ""
    end

    terms_to_keep = []

    grouped_by_first_word.each do |first_word, terms|
      if terms.length == 1
        # Only one term starts with this word, keep it
        terms_to_keep << terms.first
      else
        # Multiple terms start with this word
        # Find the maximum length among them
        max_length = terms.map(&:length).max

        # Get all terms with that maximum length
        longest_terms = terms.select { |term| term.length == max_length }

        if longest_terms.length == 1
          # Only one term has the max length, keep it
          terms_to_keep << longest_terms.first
        else
          # Tie in length, find the one with the highest count among the tied terms
          term_with_max_count = longest_terms.max_by { |term| search_counts[term] }
          terms_to_keep << term_with_max_count
        end
      end
    end

    # Return a new hash containing only the terms to keep and their counts
    search_counts.slice(*terms_to_keep)
  end
end
