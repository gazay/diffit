Diffit.configure do |config|

  # A name of the tracking table.
  config.table_name = :tracked_changes

  # A name of the stored procedure.
  config.function_name = :tracked_changes_function

  # A strategy to handle relations. Should be one of: [:join, :subquery].
  config.strategy = :join

end
