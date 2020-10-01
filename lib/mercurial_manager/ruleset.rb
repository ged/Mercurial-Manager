# -*- ruby -*-
# frozen_string_literal: true

require 'loggability'

require 'mercurial_manager' unless defined?( MercurialManager )


# Glob-based, order-based rules matcher that can answer "maybe"
# where the inputs make clear that something is unknown.
#
# Rules are of the form:
#
#     level [user=pattern] [repo=pattern] [file=pattern] [branch=pattern]
#
class MercurialManager::Ruleset
	extend Loggability


	# The permission levels
	LEVELS = %i[ init publish write read deny ]


	# Internal Rule class -- contains the patterns and match logic for each line of
	# the Ruleset.
	Rule = Struct.new( :level, :user, :repo, :file, :branch, keyword_init: true ) do
		extend Loggability
		log_to :mercurial_manager


		# The fields of a Rule that are used in a match
		CRITERIA_FIELDS = %i[ user repo file branch ]


		### Returns +true+ iff the criteria matches the rule's patterns, and the
		### specified +level+ is greater than or equal to the rule's level.
		def match?( **criteria )
			return self.each_criteria.all? do |key, pattern|
				val = criteria[ key ] or break false
				File.fnmatch( pattern, val, File::FNM_EXTGLOB )
			end
		end


		### Yield each of the criteria fields that actually has a value set.
		def each_criteria( &block )
			iter = Enumerator.new do |yielder|
				CRITERIA_FIELDS.each do |field|
					val = self[ field ]
					yielder.yield( [field, val] ) if val
				end
			end

			return iter.each( &block ) if block
			return iter
		end


		### Return the rule's level as its numeric equivalent.
		def level_index
			return MercurialManager::Ruleset::LEVELS.index( self.level.to_sym )
		end


		### Returns +true+ if this is a `deny` rule.
		def deny?
			return self.level == 'deny'
		end


		### Return a human-readable representation of the rule.
		def inspect
			attributes = self.to_h
			attributes.delete( :level )

			return "#<MercurialManager::Ruleset::Rule:%#016x {%s} %p>" % [
				self.object_id * 2,
				self.level,
				attributes
			]
		end

	end # Struct Rule


	# Log to MercurialManager's log
	log_to :mercurial_manager


	### Build a Ruleset out of the given +lines+, which is expected to be
	### an Enumerable that yields ruleset lines.
	def self::build( lines )
		rules = lines.map do |line|
			line = line.strip
			next if line.start_with?( '#' )

			self.log.debug "Parsing line: %p" % [ line ]
			level, *criteria = line.split
			attrs = Hash[ criteria.map {|str| str.split('=', 2)} ]
			attrs[:level] = level

			self.log.debug "Adding a rule for attributes: %p" % [ attrs ]
			Rule.new( **attrs )
		end

		return new( rules )
	end


	### Create a Ruleset that contains the given +rules+.
	def initialize( *rules )
		@rules = rules.flatten
	end


	######
	public
	######

	##
	# The rules in this Ruleset.
	attr_reader :rules


	### Test to see if the given +level+ of access is allowed given the specified
	### +criteria+.
	def allow( level, **criteria )
		level_index = LEVELS.index( level ) or return false

		# Allow some keyword aliases
		criteria[ :user ] = criteria.delete( :to ) if criteria.key?( :to )
		criteria[ :repo ] = criteria.delete( :on ) if criteria.key?( :on )

		# Find the first rule that matches
		matching_rule = self.rules.find {|rule| rule.match?(**criteria) }
		self.log.debug "%s request with criteria: %p matched rule: %p" %
			[ level, criteria, matching_rule ]

		# Allow if a matching rule was found, it doesn't say to deny access explicitly,
		# and the level being requested is below the one it allows.
		return matching_rule &&
			!matching_rule.deny? &&
			level_index >= matching_rule.level_index
	end


	### Return a human-readable representation of the Ruleset.
	def inspect
		return "#<%p:%#16x %d rules>" % [
			self.class,
			self.object_id * 2,
			self.rules.length
		]
	end

end # class MercurialManager::Ruleset