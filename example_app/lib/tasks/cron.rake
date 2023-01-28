namespace :cron do
  desc "Runs daily at 10:00 UTC"
  task daily_at_1000_utc: :environment do
    Rails.logger = Logger.new($stdout)
    DailyAt1000UtcCron.new.call
    Rails.logger.info "Finished executing cron:daily_at_1000_utc"
  end
end
