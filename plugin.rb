# name: Subscription Manager
# about: manages subscriptions for discourse users
# version: 0.1
# authors: Maysam Torabi
# Many thanks to Régis Hanol ! https://meta.discourse.org/t/hourly-backup-only-if-something-has-changed/27274/12


after_initialize do
  module ::Subscription
    class UnsubscribeJob < ::Jobs::Scheduled
      every 1.hour
      sidekiq_options retry: false

      def unsubscribe_expired_users
        User.all.find_each do |user| 
          user.deactivate if user.custom_fields["user_field_1"] and user.custom_fields["user_field_1"].to_date < Time.now
        end
      end

      def execute(args)
        Jobs.enqueue_in(rand(4), :unsubscribe_expired_users) 
      end
    end
  end
end
