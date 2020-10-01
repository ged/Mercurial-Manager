#!/usr/bin/env rspec -cfd

require_relative '../spec_helper'

require 'mercurial_manager/ruleset'


RSpec.describe( MercurialManager::Ruleset ) do

	let( :ruleset ) do
		described_class.build( access_rules.each_line )
	end


	RSpec::Matchers.define( :allow_access ) do |level, **kwargs|

		match do |ruleset|
			ruleset.allow( level, **kwargs )
		end

		failure_message do |ruleset|
			"but it did not"
		end

		failure_message_when_negated do |ruleset|
			"but it did"
		end

	end


	context "with the default ruleset" do

		let( :access_rules ) do
			return <<~END_RULES
				init user=root/**
				deny repo=hgadmin
				write user=users/**
			END_RULES
		end


		it "allows root users to do any operation on any repository" do
			expect( ruleset ).to allow_access( :init, to: 'root/jrandom', on: 'project1/driver' )
			expect( ruleset ).to allow_access( :init, to: 'root/jrandom', on: 'hgadmin' )
			expect( ruleset ).to allow_access( :init, to: 'root/jrandom', on: 'project2/driver' )
		end


		it "does not allow non-root users to access the hgadmin repo" do
			expect( ruleset ).not_to allow_access( :read, to: 'users/jrandom', on: 'hgadmin' )
			expect( ruleset ).not_to allow_access( :read, to: 'users/fhawkins', on: 'hgadmin' )
		end


		it "allows other users to read and write, but not create repositories" do
			expect( ruleset ).to allow_access( :read, to: 'users/jrandom', on: 'project1/driver' )
			expect( ruleset ).to allow_access( :read, to: 'users/fhawkins', on: 'project1/driver' )
			expect( ruleset ).to allow_access( :write, to: 'users/jrandom', on: 'project1/driver' )
			expect( ruleset ).to allow_access( :write, to: 'users/fhawkins', on: 'project1/driver' )
			expect( ruleset ).
				not_to allow_access( :init, to: 'users/jrandom', on: 'project1/driver' )
			expect( ruleset ).
				not_to allow_access( :init, to: 'users/fhawkins', on: 'project1/driver' )
		end


		# test_norules
		it "denies access to everything with no matches" do
			expect( ruleset ).not_to allow_access( :init )
			expect( ruleset ).not_to allow_access( :publish )
			expect( ruleset ).not_to allow_access( :write )
			expect( ruleset ).not_to allow_access( :read )
		end


		# test_root
		it "allows all access to users with a root key" do
			expect( ruleset ).to allow_access( :init, to: 'root/key' )
			expect( ruleset ).to allow_access( :publish, to: 'root/key' )
			expect( ruleset ).to allow_access( :write, to: 'root/key' )
			expect( ruleset ).to allow_access( :read, to: 'root/key' )
		end


		# test_user_norepo
		it "denies access to a user with a key in `user/**`" do
			expect( ruleset ).not_to allow_access( :init, to: 'user/key' )
			expect( ruleset ).not_to allow_access( :publish, to: 'user/key' )
			expect( ruleset ).not_to allow_access( :write, to: 'user/key' )
			expect( ruleset ).not_to allow_access( :read, to: 'user/key' )
		end


		# test_user/test_user_kwargs
		it "allows write access and above to users with a key and a specific repo" do
			expect( ruleset ).not_to allow_access( :init, to: 'users/key', on: 'some/repo' )
			expect( ruleset ).not_to allow_access( :publish, to: 'users/key', on: 'some/repo' )
			expect( ruleset ).to allow_access( :write, to: 'users/key', on: 'some/repo' )
			expect( ruleset ).to allow_access( :read, to: 'users/key', on: 'some/repo' )
		end

	end


	context "ruleset 2" do

		let( :access_rules ) do
			return <<~END_RULES
				init user=root/**
				deny repo=hgadmin
				init user=users/toto/* repo=toto
				write user=users/toto/* repo=pub/**
				write user=users/w/*
				write repo=allpub/**
				read user=users/**
			END_RULES
		end


	    # test_hgadmin
		it "denies access to `hgadmin` to non-root users" do
			expect( ruleset ).not_to allow_access( :init, to: 'users/key', repo: 'hgadmin' )
			expect( ruleset ).not_to allow_access( :publish, to: 'users/key', repo: 'hgadmin' )
			expect( ruleset ).not_to allow_access( :write, to: 'users/key', repo: 'hgadmin' )
			expect( ruleset ).not_to allow_access( :read, to: 'users/key', repo: 'hgadmin' )

			expect( ruleset ).not_to allow_access( :init, to: 'key', repo: 'hgadmin' )
			expect( ruleset ).not_to allow_access( :publish, to: 'key', repo: 'hgadmin' )
			expect( ruleset ).not_to allow_access( :write, to: 'key', repo: 'hgadmin' )
			expect( ruleset ).not_to allow_access( :read, to: 'key', repo: 'hgadmin' )
		end


		# test_user
		it "allows the correct access to `some/repo`" do
			expect( ruleset ).not_to allow_access( :init, to: 'users/key', repo: 'some/repo' )
			expect( ruleset ).not_to allow_access( :publish, to: 'users/key', repo: 'some/repo' )
			expect( ruleset ).not_to allow_access( :write, to: 'users/key', repo: 'some/repo' )
			expect( ruleset ).to allow_access( :read, to: 'users/key', repo: 'some/repo' )
		end


		# test_repo
		it "allows correct access to the `toto` repo to toto users" do
			expect( ruleset ).to allow_access( :init, to: 'users/toto/key', repo: 'toto' )
			expect( ruleset ).to allow_access( :publish, to: 'users/toto/key', repo: 'toto' )
			expect( ruleset ).to allow_access( :write, to: 'users/toto/key', repo: 'toto' )
			expect( ruleset ).to allow_access( :read, to: 'users/toto/key', repo: 'toto' )
		end


		# test_write
		it "allows correct write access" do
			expect( ruleset ).not_to allow_access( :init, to: 'users/w', repo: 'toto' )
			expect( ruleset ).not_to allow_access( :publish, to: 'users/w', repo: 'toto' )
			expect( ruleset ).not_to allow_access( :write, to: 'users/w', repo: 'toto' )
			expect( ruleset ).to allow_access( :read, to: 'users/w', repo: 'toto' )

			expect( ruleset ).not_to allow_access( :init, to: 'users/w/key', repo: 'toto' )
			expect( ruleset ).not_to allow_access( :publish, to: 'users/w/key', repo: 'toto' )
			expect( ruleset ).to allow_access( :write, to: 'users/w/key', repo: 'toto' )
			expect( ruleset ).to allow_access( :write, to: 'users/w/key', repo: 'toto' )

			expect( ruleset ).to allow_access( :read, to: 'users/w', repo: 'pub/stuff' )
			expect( ruleset ).to allow_access( :write, to: 'users/w/key', repo: 'pub/stuff' )
			expect( ruleset ).to allow_access( :read, to: 'users/toto', repo: 'pub/stuff' )
			expect( ruleset ).to allow_access( :write, to: 'users/toto/key', repo: 'pub/stuff' )

			expect( ruleset ).to allow_access( :read, to: 'users/toto', repo: 'other/repo' )
			expect( ruleset ).to allow_access( :read, to: 'users/toto/key', repo: 'other/repo' )
			expect( ruleset ).to allow_access( :read, to: 'users/w', repo: 'other/repo' )
			expect( ruleset ).to allow_access( :write, to: 'users/w/key', repo: 'other/repo' )

			expect( ruleset ).to allow_access( :write, to: 'users/toto', repo: 'allpub/repo' )
			expect( ruleset ).to allow_access( :write, to: 'users/toto/key', repo: 'allpub/repo' )
			expect( ruleset ).to allow_access( :write, to: 'users/w', repo: 'allpub/repo' )
			expect( ruleset ).to allow_access( :write, to: 'users/w/key', repo: 'allpub/repo' )

			expect( ruleset ).not_to allow_access( :read, to: 'users/toto', repo: 'hgadmin' )
			expect( ruleset ).not_to allow_access( :read, to: 'users/toto/key', repo: 'hgadmin' )
			expect( ruleset ).not_to allow_access( :read, to: 'users/w', repo: 'hgadmin' )
			expect( ruleset ).not_to allow_access( :read, to: 'users/w/key', repo: 'hgadmin' )
		end


		# test_init
		it "allows some users `init` access to `toto`" do
			expect( ruleset ).to allow_access( :read, to: 'users/toto', repo: 'toto' )
			expect( ruleset ).to allow_access( :init, to: 'users/toto/key', repo: 'toto' )
		end

	end


	context "ruleset 3" do

		let( :access_rules ) do
			return <<~END_RULES
				read  user=users/w/* repo=toto
				deny  user=users/w/* repo=no
				write user=users/w/*
				read  user=users/**
			END_RULES
		end


		# test_user_w
		it "allows access correctly to w users" do
			expect( ruleset ).not_to allow_access( :init, repo: 'toto', user: 'users/w/key' )
			expect( ruleset ).not_to allow_access( :publish, repo: 'toto', user: 'users/w/key' )
			expect( ruleset ).not_to allow_access( :write, repo: 'toto', user: 'users/w/key' )
			expect( ruleset ).to allow_access( :read, repo: 'toto', user: 'users/w/key' )

			expect( ruleset ).not_to allow_access( :init, repo: 'no', user: 'users/w/key' )
			expect( ruleset ).not_to allow_access( :publish, repo: 'no', user: 'users/w/key' )
			expect( ruleset ).not_to allow_access( :write, repo: 'no', user: 'users/w/key' )
			expect( ruleset ).not_to allow_access( :read, repo: 'no', user: 'users/w/key' )

			expect( ruleset ).not_to allow_access( :init, repo: 'other', user: 'users/w/key' )
			expect( ruleset ).not_to allow_access( :publish, repo: 'other', user: 'users/w/key' )
			expect( ruleset ).to allow_access( :write, repo: 'other', user: 'users/w/key' )
			expect( ruleset ).to allow_access( :read, repo: 'other', user: 'users/w/key' )
		end


		# test_user_k
		it "allows access correctly to k users" do
			expect( ruleset ).not_to allow_access( :init, repo: 'toto', user: 'users/k/key' )
			expect( ruleset ).not_to allow_access( :publish, repo: 'toto', user: 'users/k/key' )
			expect( ruleset ).not_to allow_access( :write, repo: 'toto', user: 'users/k/key' )
			expect( ruleset ).to allow_access( :read, repo: 'toto', user: 'users/k/key' )

			expect( ruleset ).not_to allow_access( :init, repo: 'no', user: 'users/k/key' )
			expect( ruleset ).not_to allow_access( :publish, repo: 'no', user: 'users/k/key' )
			expect( ruleset ).not_to allow_access( :write, repo: 'no', user: 'users/k/key' )
			expect( ruleset ).to allow_access( :read, repo: 'no', user: 'users/k/key' )

			expect( ruleset ).not_to allow_access( :init, repo: 'other', user: 'users/k/key' )
			expect( ruleset ).not_to allow_access( :publish, repo: 'other', user: 'users/k/key' )
			expect( ruleset ).not_to allow_access( :write, repo: 'other', user: 'users/k/key' )
			expect( ruleset ).to allow_access( :read, repo: 'other', user: 'users/k/key' )
		end


		# test_otheruser
		it "allows access correctly to other users" do
			expect( ruleset ).not_to allow_access( :init, repo: 'toto', user: 'jay/key' )
			expect( ruleset ).not_to allow_access( :publish, repo: 'toto', user: 'jay/key' )
			expect( ruleset ).not_to allow_access( :write, repo: 'toto', user: 'jay/key' )
			expect( ruleset ).not_to allow_access( :read, repo: 'toto', user: 'jay/key' )

			expect( ruleset ).not_to allow_access( :init, repo: 'no', user: 'jay/key' )
			expect( ruleset ).not_to allow_access( :publish, repo: 'no', user: 'jay/key' )
			expect( ruleset ).not_to allow_access( :write, repo: 'no', user: 'jay/key' )
			expect( ruleset ).not_to allow_access( :read, repo: 'no', user: 'jay/key' )

			expect( ruleset ).not_to allow_access( :init, repo: 'other', user: 'jay/key' )
			expect( ruleset ).not_to allow_access( :publish, repo: 'other', user: 'jay/key' )
			expect( ruleset ).not_to allow_access( :write, repo: 'other', user: 'jay/key' )
			expect( ruleset ).not_to allow_access( :read, repo: 'other', user: 'jay/key' )
		end

	end


	context "ruleset 4" do

		let( :access_rules ) do
			return <<~END_RULES
				read  user=users/w/* repo=toto
				write user=users/w/*
				deny  user=users/w/* repo=no
				read  user=users/**
			END_RULES
		end


		# test_user_w
		it "allows access correctly to user w" do
			expect( ruleset ).not_to allow_access( :init, repo: 'toto', user: 'users/w/key' )
			expect( ruleset ).not_to allow_access( :publish, repo: 'toto', user: 'users/w/key' )
			expect( ruleset ).not_to allow_access( :write, repo: 'toto', user: 'users/w/key' )
			expect( ruleset ).to allow_access( :read, repo: 'toto', user: 'users/w/key' )

			# deny has no effect here, write match first
			expect( ruleset ).not_to allow_access( :init, repo: 'no', user: 'users/w/key' )
			expect( ruleset ).not_to allow_access( :publish, repo: 'no', user: 'users/w/key' )
			expect( ruleset ).to allow_access( :write, repo: 'no', user: 'users/w/key' )
			expect( ruleset ).to allow_access( :read, repo: 'no', user: 'users/w/key' )

			expect( ruleset ).not_to allow_access( :init, repo: 'other', user: 'users/w/key' )
			expect( ruleset ).not_to allow_access( :publish, repo: 'other', user: 'users/w/key' )
			expect( ruleset ).to allow_access( :write, repo: 'other', user: 'users/w/key' )
			expect( ruleset ).to allow_access( :read, repo: 'other', user: 'users/w/key' )
		end

	end


	context "ruleset 5" do

		let( :access_rules ) do
			return <<~END_RULES
				read  user=users/w/* repo=toto
				deny  user=users/w/* repo=no
				write user=users/w/*
				read  user=users/**
			END_RULES
		end


		# test_user_w
		it "allows access correctly to user w" do
			expect( ruleset ).not_to allow_access( :init, repo: 'toto', user: 'users/w/key' )
			expect( ruleset ).not_to allow_access( :publish, repo: 'toto', user: 'users/w/key' )
			expect( ruleset ).not_to allow_access( :write, repo: 'toto', user: 'users/w/key' )
			expect( ruleset ).to allow_access( :read, repo: 'toto', user: 'users/w/key' )

			# deny takes effect here
			expect( ruleset ).not_to allow_access( :init, repo: 'no', user: 'users/w/key' )
			expect( ruleset ).not_to allow_access( :publish, repo: 'no', user: 'users/w/key' )
			expect( ruleset ).not_to allow_access( :write, repo: 'no', user: 'users/w/key' )
			expect( ruleset ).not_to allow_access( :read, repo: 'no', user: 'users/w/key' )

			expect( ruleset ).not_to allow_access( :init, repo: 'other', user: 'users/w/key' )
			expect( ruleset ).not_to allow_access( :publish, repo: 'other', user: 'users/w/key' )
			expect( ruleset ).to allow_access( :write, repo: 'other', user: 'users/w/key' )
			expect( ruleset ).to allow_access( :read, repo: 'other', user: 'users/w/key' )
		end

	end


	context "publish ruleset" do

		let( :access_rules ) do
			return <<~END_RULES
				init user=root/**
				deny repo=hgadmin
				init user=users/toto/* repo=toto
				publish user=users/toto/* repo=pub/**
				publish repo=allpub/**
				write user=users/w/*
				read user=users/**
			END_RULES
		end


		# test_publish
		it "allows access correctly to publish capability" do
			expect( ruleset ).not_to allow_access( :init, repo: 'allpub/stuff', user: 'users/w/key' )
			expect( ruleset ).to allow_access( :publish, repo: 'allpub/stuff', user: 'users/w/key' )
			expect( ruleset ).to allow_access( :write, repo: 'allpub/stuff', user: 'users/w/key' )
			expect( ruleset ).to allow_access( :read, repo: 'allpub/stuff', user: 'users/w/key' )

			expect( ruleset ).not_to allow_access( :init, repo: 'toto', user: 'users/w/key' )
			expect( ruleset ).not_to allow_access( :publish, repo: 'toto', user: 'users/w/key' )
			expect( ruleset ).to allow_access( :write, repo: 'toto', user: 'users/w/key' )
			expect( ruleset ).to allow_access( :read, repo: 'toto', user: 'users/w/key' )

			expect( ruleset ).not_to allow_access( :init, repo: 'other/stuff', user: 'users/w/key' )
			expect( ruleset ).not_to allow_access( :publish, repo: 'other/stuff', user: 'users/w/key' )
			expect( ruleset ).to allow_access( :write, repo: 'other/stuff', user: 'users/w/key' )
			expect( ruleset ).to allow_access( :read, repo: 'other/stuff', user: 'users/w/key' )

			expect( ruleset ).not_to allow_access( :init, user: 'users/w/key', repo: 'pub/stuff' )
			expect( ruleset ).not_to allow_access( :publish, user: 'users/w/key', repo: 'pub/stuff' )
			expect( ruleset ).to allow_access( :write, user: 'users/w/key', repo: 'pub/stuff' )
			expect( ruleset ).to allow_access( :read, user: 'users/w/key', repo: 'pub/stuff' )

			expect( ruleset ).not_to allow_access( :init, user: 'users/toto/key', repo: 'pub/stuff' )
			expect( ruleset ).to allow_access( :publish, user: 'users/toto/key', repo: 'pub/stuff' )
			expect( ruleset ).to allow_access( :write, user: 'users/toto/key', repo: 'pub/stuff' )
			expect( ruleset ).to allow_access( :read, user: 'users/toto/key', repo: 'pub/stuff' )
		end

	end

end

