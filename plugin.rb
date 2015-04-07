# name: Hourly Backup
# about: Schedule hourly backup for Discourse
# version: 0.1
# authors: Frédéric Malo


module ::HourlyBackup
  class Engine < ::Rails::Engine
    engine_name "hourlybackup"
    isolate_namespace HourlyBackup
  end
end

after_initialize do

  load File.expand_path("../app/jobs/hourlybackup.rb", __FILE__)

end