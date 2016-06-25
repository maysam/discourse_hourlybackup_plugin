module Jobs
  class UnsubscribeExpiredUsers < Jobs::Scheduled
    every 1.hour
    sidekiq_options retry: true

    def execute(args)
      p "Unsubscribing Expired Users"
      User.not_suspended.find_each do |user|
        begin
          if user.custom_fields["user_field_1"]
            if user.custom_fields["user_field_1"].to_date < Time.now
              user.suspended_till = 100.years.from_now
              user.suspended_at = DateTime.now
              user.save!
              user.revoke_api_key
              StaffActionLogger.new(user).log_user_suspend(user, 'Subscription Expired!')
              MessageBus.publish "/logout", user.id, user_ids: [user.id]
            end
          end
        rescue => e
          p e.message
        end
      end
      p "Subscribing Unexpired Users"
      User.suspended.find_each do |user|
        begin
          if user.custom_fields["user_field_1"]
            if user.custom_fields["user_field_1"].to_date >= Time.now
              user.suspended_till = nil
              user.suspended_at = nil
              user.save!
              StaffActionLogger.new(user).log_user_unsuspend(user)
            end
          end
        rescue => e
          p e.message
        end
      end
    end
  end
end