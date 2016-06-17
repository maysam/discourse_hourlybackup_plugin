module Jobs
  class UnsubscribeExpiredUsers < Jobs::Scheduled
    every 1.hour
    sidekiq_options retry: true

    def execute(args)
      p "Unsubscribing Expired Users"
      User.all.find_each do |user|
        if user.custom_fields["user_field_1"]
          if user.custom_fields["user_field_1"].to_date < Time.now
            user.deactivate
          else
            user.activate
          end
        end
      end
    end
  end
end