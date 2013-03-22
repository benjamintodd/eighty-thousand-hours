class MetricsController < ApplicationController
  def weekly_metrics
    send_data WeeklyMetric.to_csv
  end
end