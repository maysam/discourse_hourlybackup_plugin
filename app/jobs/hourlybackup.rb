
module Jobs
  class HourlyBackup < ::Jobs::Scheduled
    every 5.minutes 
    sidekiq_options retry: false

    def execute(args)
      Jobs.enqueue_in(0, :create_daily_backup)
    end
  end
end

