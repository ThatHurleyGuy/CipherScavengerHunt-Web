namespace :bootstrap do
	desc "Setup Initial Messages"
	task :create_messages => :environment do
		GeneratorController.initialize_database
	end
end