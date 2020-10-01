#!/usr/bin/env ruby -S rake

require 'rake/deveiate'

ENV['VERSION_FROM'] = 'lib/mercurial_manager.rb'

Rake::DevEiate.setup( 'mercurial-manager' ) do |project|
	project.publish_to = 'deveiate:/usr/local/www/public/code'
	project.version_from = 'lib/mercurial_manager.rb'
end

