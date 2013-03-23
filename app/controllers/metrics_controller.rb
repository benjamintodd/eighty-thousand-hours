class MetricsController < ApplicationController
  def weekly_metrics
    send_data WeeklyMetric.to_csv
  end

  def monthly_metrics
  	send_data MonthlyMetric.to_csv
  end
end