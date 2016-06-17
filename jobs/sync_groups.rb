module Jobs
  class SyncGroups < Jobs::Scheduled
    every 1.minute
    sidekiq_options retry: true

    def execute(args)
      puts "syncing groups to groups.json"
      File.open("groups.json", 'w') { |file| p file; file.write JSON.pretty_generate Group.pluck(:id, :name) }
    end
  end
end
