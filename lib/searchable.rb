module Searchable
  extend ActiveSupport::Concern

  module ClassMethods
    def search_db(query)
      q = query.gsub(' ', ' | ')
      ts_query = sanitize_sql_array ["to_tsquery(?)", q]
      conditions = <<-SQL
      tsv @@ #{ts_query}
      SQL
      where(conditions, q)
    end
  end
end
