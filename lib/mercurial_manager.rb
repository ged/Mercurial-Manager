# -*- ruby -*-
# frozen_string_literal: true

require 'pathname'
require 'loggability'


# Manage access to a Mercurial server via SSH keys.
module MercurialManager
	extend Loggability

	# Package version
	VERSION = '0.0.1'


	USER_CONFIG = Pathname( "~/.mercurial-server" )


	# Set up a logger for other classes to use
	log_as :mercurial_manager


end # module MercurialManager

