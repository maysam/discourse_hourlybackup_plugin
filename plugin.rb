module Jobs
  class HourlyBackup < ::Jobs::Scheduled
    every 5.minutes 
    sidekiq_options retry: false

    def execute(args)
      return unless SiteSetting.backup_daily?
      Jobs.enqueue_in(rand(10), :create_daily_backup)
    end
  end
end

