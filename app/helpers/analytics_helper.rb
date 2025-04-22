module AnalyticsHelper
  # Filters a list of searches for a user, keeping only the query
  # with the most words when multiple queries share the same starting word.
  # Keeps searches that don't share a starting word.
  def filter_searches_by_longest_start_word(searches)
    return [] if searches.blank?

    grouped_by_first_word = searches.group_by do |search|
      search.final_query.split.first || ""
    end

    filtered_searches = []

    grouped_by_first_word.each do |first_word, group|
      if group.length == 1
        filtered_searches << group.first
      else
        # Find and keep the one with the most words
        most_words_in_group = group.max_by { |s| s.final_query.split.size } # Changed from .length
        filtered_searches << most_words_in_group
      end
    end

    filtered_searches.sort_by(&:timestamp).reverse
  end

  # Filters an aggregated search count hash.
  # If multiple terms share the same starting word, keeps the one with the most words.
  # If word counts are tied, keeps the one with the highest search count.
  def filter_top_searches(search_counts)
    return {} if search_counts.blank?

    grouped_by_first_word = search_counts.keys.group_by do |term|
      term.split.first || ""
    end

    terms_to_keep = []

    grouped_by_first_word.each do |first_word, terms|
      if terms.length == 1
        terms_to_keep << terms.first
      else
        # Find the maximum word count among them
        max_word_count = terms.map { |term| term.split.size }.max # Changed from .length

        # Get all terms with that maximum word count
        most_words_terms = terms.select { |term| term.split.size == max_word_count } # Changed from .length

        if most_words_terms.length == 1
          # Only one term has the max word count, keep it
          terms_to_keep << most_words_terms.first
        else
          # Tie in word count, find the one with the highest search count among the tied terms
          term_with_max_count = most_words_terms.max_by { |term| search_counts[term] }
          terms_to_keep << term_with_max_count
        end
      end
    end

    search_counts.slice(*terms_to_keep)
  end
end
