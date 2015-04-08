# name: Hourly Backup
# about: Schedule hourly backup for Discourse
# version: 0.1
# authors: Frédéric Malo



after_initialize do
  module ::HourlyBackup
    class BackupJob < ::Jobs::Scheduled
      every 60.minutes
      sidekiq_options retry: false

      def has_something_changed_since?(date=1.hour.ago)
        [User, Post, Topic].each do |klass|
          return true if klass.where("created_at >= :date OR updated_at >= :date", date: date).exists?
        end
        false
      end

      def execute(args)
        return unless SiteSetting.backup_daily?
        Jobs.enqueue_in(rand(8), :create_daily_backup)
      end
    end
  end
end