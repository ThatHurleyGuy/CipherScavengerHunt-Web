class Team < ActiveRecord::Base
  attr_accessible :netid, :name, :pin, :score, :message
  has_one :message

	 # reads our ldap settings
	@@config_file = File.open("#{Rails.root}/config/ldap.yml")
	@@config = YAML.load(@@config_file)

	# logs in a user against the active directory, if possible
	# returns the user if successful, nil if not
	def self.login(netid, password)
	    # sanity check
	    return nil if netid.blank? || password.blank?

	    # attempt to bind to ldap and authenticate this user
	    # this will do the following:
	    #   1) Bind to the active directory (returning false if it cannot)
	    #   2) Query for the name of the user
	    #   3) Find or create the corresponding user
		return ldap_authenticate(netid, password)
	end

	# creates the ldap connection from the info in the configuration file
	def self.make_ldap_connection(username, password)
	    Net::LDAP.new(
	    	:host => @@config['host'],
			:port => @@config['port'],
			:encryption => @@config['secure'] ? :simple_tls : nil,
			:auth => {
			:method => :simple,
			:username => username,
			:password => password
	    }
	  )
	end

	# authenticates the give netid and password against LDAP
	def self.ldap_authenticate(netid, password)
	    # make ldap connection, and set binding parameters to be as the given
	    # user
	    who = "cn=#{netid},#{@@config['base_dn']}"
	    ldap = make_ldap_connection(who, password)

	    # search for the user's name in the AD
	    # sn == last name, givenName == first name
	    attrs = ['sn', 'givenName']
	    results = ldap.search(:base => who, :attributes => attrs)

	    # fail out if our query was unsuccessful (bad authentication)
	    return nil if results.blank?

	    # If this user already exists, return it
	    team = Team.first({:netid => netid})

	    if not team.nil?
	    	return team;
	    end

	    team = Team.create(:netid => netid, score => 0)

		# encoded = ""
		# parity = ""
		# level = rand(3) + 1
		# pin = rand(8999) + 1000
		# if level == 1
		# 	encoded = encode_level1(message1)
		# elsif level == 2
		# 	encoded = encode_level2(message1)
		# elsif level == 3 
		# 	message1 = decoded2
		# 	parity = encode_level3(message1, message2)
		# end

		#message = Message.create(:level => level, :decoded => message1, :encoded => encoded, :parity => parity)	
		#team = Team.create(:name => name, :pin => pin, :score => 0, :message => message)
		#message.team = team
		#message.save
		#team.save
		return team
	end
end
