# ruport/config.rb : Ruby Reports configuration system
#
# Author: Gregory T. Brown (gregory.t.brown at gmail dot com)
#
# Copyright (c) 2006, All Rights Reserved.
#
# This is free software.  You may modify and redistribute this freely under
# your choice of the GNU General Public License or the Ruby License. 
#
# See LICENSE and COPYING for details
#
require "ostruct"
module Ruport

  # === Overview
  #
  # This class serves as the configuration system for Ruport.
  #  
  # The source and mailer defined as <tt>:default</tt> will become the 
  # fallback values if you don't specify one in <tt>Report::Mailer</tt> or 
  # <tt>Query</tt>, but you may define as many sources as you like and switch 
  # between them later.
  #
  # === Example
  #
  # The most common way to access your application configuration is through 
  # the <tt>Ruport.configure</tt> method, like this:
  #   
  #   Ruport.configure do |config|
  #
  #     config.log_file 'foo.log'
  #     config.debug_mode = true
  #
  #     config.source :default,
  #                   :dsn => "dbi:mysql:somedb:db.blixy.org",
  #                   :user => "root", 
  #                   :password => "chunky_bacon"
  #   
  #     config.mailer :default,
  #                   :host => "mail.chunkybacon.org", 
  #                   :address => "chunky@bacon.net",
  #                   :user => "cartoon", 
  #                   :password => "fox", 
  #                   :port => 25, 
  #                   :auth_type => :login
  #
  #   end
  #
  # You can accomplish the same thing by opening the class directly:
  #
  #   class Ruport::Config
  #
  #     source :default, 
  #            :dsn => "dbi:mysql:some_db", 
  #            :user => "root"
  #     
  #     mailer :default, 
  #            :host => "mail.iheartwhy.com", 
  #            :address => "sandal@ruby-harmonix.net", 
  #            :user => "sandal",
  #            :password => "abc123"
  #     
  #     logfile 'foo.log'
  #
  #   end
  #
  # Saving this config information into a file and then requiring it allows
  # you to share configurations between Ruport applications. 
  #
  module Config
    module_function
    
    # :call-seq:
    #   source(source_name, options)
    #
    # Creates or retrieves a database source configuration. Available options
    # are:
    # <b><tt>:user</tt></b>::       The user used to connect to the database.
    # <b><tt>:password</tt></b>::   The password to use to connect to the 
    #                               database (optional).
    # <b><tt>:dsn</tt></b>::        The dsn string that dbi will use to 
    #                               access the database.
    #
    # Example (setting a source): 
    #   source :default, :user => "root", 
    #                    :password => "clyde",
    #                    :dsn  => "dbi:mysql:blinkybase"
    #
    # Example (retrieving a source):
    #   db = source(:default) #=> <OpenStruct ..>
    #   db.dsn                #=> "dbi:mysql:blinkybase"
    #
    def source(*args) 
      return sources[args.first] if args.length == 1
      sources[args.first] = OpenStruct.new(*args[1..-1])
      check_source(sources[args.first],args.first)
    end

    # The file that <tt>Ruport.log()</tt> will write to.
    def log_file(file)
      @logger = Logger.new(file)
    end
    
    # Same as <tt>Config.log_file</tt>, but accessor style.
    def log_file=(file)
      log_file(file)
    end

    # Alias for <tt>sources[:default]</tt>.
    def default_source
      sources[:default]
    end

    # Returns all <tt>source</tt>s defined in this <tt>Config</tt>.
    def sources; @sources ||= {}; end

    # Returns the currently active logger.
    def logger; @logger; end

    # returns true if in debug mode
    def debug_mode?; !!@debug_mode; end
    
    # Verifies that you have provided a DSN for your source.
    def check_source(settings,label) # :nodoc:
      unless settings.dsn
        Ruport.log( 
          "Missing DSN for source #{label}!",
          :status => :fatal, :level => :log_only,
          :raises => ArgumentError 
        )
      end
    end

    # forces messages with :level of :log_only to be printed
    def debug_mode=(something)
      @debug_mode = !!something
    end
    
    # Allows users to set their own accessors on the Config module
    def method_missing(meth, *args)
      @config ||= OpenStruct.new
      
      if args.empty? || meth.to_s =~ /.*=/
        @config.send(meth, *args)
      else
        @config.send("#{meth}=".to_sym, *args)
      end
    end
    
  end
end
