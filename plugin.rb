# name: Hourly Backup
# about: Schedule hourly backup for Discourse
# version: 0.1
# authors: Frédéric Malo



after_initialize do
  module ::HourlyBackup
    class BackupJob < ::Jobs::Scheduled
      every 2.minutes
      sidekiq_options retry: false


      def execute(args)
        return unless SiteSetting.backup_daily?
        Jobs.enqueue_in(0, :create_daily_backup)
      end
    end
  end
end