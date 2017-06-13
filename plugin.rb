# name: Subscription Manager
# about: manages subscriptions for discourse users
# version: 0.1
# authors: Maysam Torabi
# Many thanks to Régis Hanol ! https://meta.discourse.org/t/hourly-backup-only-if-something-has-changed/27274/12

PLUGIN_NAME ||= "discourse_subscription_manager".freeze

after_initialize do
  require_dependency File.expand_path('../jobs/sync_groups.rb', __FILE__)
  require_dependency File.expand_path('../jobs/unsubscribe_expired_users.rb', __FILE__)

  Jobs.enqueue_in(rand(4), :sync_groups)
  Jobs.enqueue_in(rand(4), :unsubscribe_expired_users)

  module ::DiscourseSubscriptionManager
    class Engine < ::Rails::Engine
      engine_name PLUGIN_NAME
      isolate_namespace DiscourseSubscriptionManager
    end
  end

  require_dependency "application_controller"

  class DiscourseSubscriptionManager::SubscriptionManagerController < ::ApplicationController
    requires_plugin PLUGIN_NAME
    skip_before_filter :check_xhr, :preload_json, :verify_authenticity_token, :redirect_to_login_if_required

    def subscribe
      begin
        status = params.require :status
        email = params.require :email
        # first_name = params.require :first_name
        # last_name = params.require :last_name
        complete_name = params.require :name
        product_id = params.require :prod
        token = params.require :hottok
        offer = params.require :off

        days_to_add = 0
        groups_to_add_to = []
        send_email = false
        _rule = nil

        rules = YAML.load_file "public/uploads/rules.yml"
        rules.each do |rule_part|
          rule = rule_part.last
          if rule['token'].to_s == token or rule['token'].to_s == "all" or (rule['token'].is_a? Array and rule['token'].include? token)
            if rule['product_id'].to_s == product_id or rule['product_id'].to_s == "all" or (rule['product_id'].is_a? Array and rule['product_id'].include? product_id)
              if rule['offer'].to_s == offer or rule['offer'].to_s == "all" or (rule['offer'].is_a? Array and rule['offer'].include? offer)
                if status == "approved"
                  days_to_add = rule['days']
                elsif status == "refunded"
                  days_to_add = -rule['days']
                end
                if status == 'approved' or status == 'refunded'
                  groups_to_add_to = rule['group']
                  groups_to_add_to = [] if groups_to_add_to.nil?
                  groups_to_add_to = [groups_to_add_to] unless groups_to_add_to.is_a? Array
                end
                _rule = rule
                break
              end
            end
          end
        end

        if days_to_add != 0
          if user = User.find_by_email(email)
            user.activate
          elsif days_to_add > 0
            puts "Creating new account!"
            user = User.new(email: email)
            user.password = SecureRandom.hex
            user.username = UserNameSuggester.suggest(user.email)

            # name_parts = []
            # name_parts << first_name if first_name
            # name_parts << last_name if last_name
            # user.name = name_parts.join ' '
            user.name = complete_name.titlecase

            user.activate

            user.email_tokens.update_all  confirmed: true

            send_email = true
          end

          if user
            current_expiration_date = user.custom_fields["user_field_1"]
            if current_expiration_date.nil?
              current_expiration_date = Date.today
            else
              current_expiration_date = current_expiration_date.to_date
              if current_expiration_date < Date.today
                current_expiration_date = Date.today
              end
            end
            current_expiration_date += days_to_add.days
            user.custom_fields["user_field_1"] = current_expiration_date.strftime("%d/%m/%Y")
            if current_expiration_date < Time.now
              user.suspended_till = 100.years.from_now
              user.suspended_at = DateTime.now
              user.revoke_api_key
              StaffActionLogger.new(user).log_user_suspend(user, 'Seu tempo de acesso expirou. Por favor renove sua assinatura.')
              MessageBus.publish "/logout", user.id, user_ids: [user.id]
            else
              user.suspended_till = nil
              user.suspended_at = nil
              StaffActionLogger.new(user).log_user_unsuspend(user)
            end
            user.save

            groups_to_add_to.each do |group_id|
              group = Group.find group_id
              return render_json_error group unless group && !group.automatic
              if days_to_add > 0
                group.users << user rescue ActiveRecord::RecordNotUnique
              else
                group.users.delete user
              end
            end

            if send_email
              puts "Sending email!"
              email_token = user.email_tokens.create email: user.email
              Jobs.enqueue :user_email, type: :account_created, user_id: user.id, email_token: email_token.token
            end
          end
        end

        render json: {rule: _rule, user: user, params: params, current_expiration_date: current_expiration_date, groups_to_add_to: groups_to_add_to}
      rescue StandardError => e
        render_json_error e.message
      end
    end
  end

  DiscourseSubscriptionManager::Engine.routes.draw do
    post "/subscribe" => "subscription_manager#subscribe"
  end

  Discourse::Application.routes.append do
    mount ::DiscourseSubscriptionManager::Engine, at: "/subscription_manager"
  end
end