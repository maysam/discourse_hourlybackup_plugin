# name: Hourly Backup
# about: Schedule hourly backup for Discourse
# version: 0.1
# authors: Frédéric Malo



after_initialize do
  module ::HourlyBackup
    class BackupJob < ::Jobs::Scheduled
      every 1.minute
      sidekiq_options retry: false

      def has_something_changed_since?(date=1.minute.ago)
        [User, Post, Topic].each do |klass|
          return true if klass.where("created_at >= :date OR updated_at >= :date", date: date).exists?
        end
        false
      end

      def execute(args)
        #return unless SiteSetting.backup_daily?
        return unless has_something_changed_since?
        Jobs.enqueue_in(0, :create_daily_backup) # change 0 to rand(8)
      end
    end
  end
end