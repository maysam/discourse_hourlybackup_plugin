module Jobs
  class UnsubscribeExpiredUsers < Jobs::Scheduled
    every 1.hour
    sidekiq_options retry: true

    def execute(args)
      p "Unsubscribing Expired Users"
      User.all.find_each do |user|
        user.deactivate if user.custom_fields["user_field_1"] and user.custom_fields["user_field_1"].to_date < Time.now
      end
    end
  end
end