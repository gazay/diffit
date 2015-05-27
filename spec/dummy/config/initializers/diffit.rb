Diffit.configure do |config|

  # A name of the stored procedure.
  config.function_name = :tracking_function

  # A name of the tracking table.
  config.table_name = :tracked_changes

end
