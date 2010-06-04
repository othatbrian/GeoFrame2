require 'open3'
require 'sequel'

class Project
  attr_accessor :name, :account
  attr_writer :password

  def initialize(name, account, password=nil)
    @name = name
    @account = account
    @password = password
  end

  def bulk_server_command
    @db[:parameter]
      .select(:value_string)
      .where(:code => 'Bulk_Server_Command')
      .first[:value_string]
  end

  def connect
    @db = _connect_with_supplied_password
    begin
      @db if @db.test_connection
    rescue Sequel::DatabaseConnectionError => error
      if @password.downcase != @name.downcase
        @db = _connect_with_default_password
        begin
          @db if @db.test_connection
        rescue Sequel::DatabaseConnectionError => error
          raise error
        end
      end
#      if ENV[:GFDBA_PASSWORD] do
#        Open3.popen3("proj_get_password #{@name} bogus") do |stdin, stdout, stderr|
#          errors = stderr.read
#          stdout.read =~ /^Password =(.*)$/m
#        @db = Sequel.connect("oracle://#{@account}:#{ENV[:GFDBA_PASSWORD]}@#{ENV[:TWO_TASK]}")
#      else
#        raise "ERROR: project or password incorrect and GFDBA_PASSWORD not set!"
    end
  end

  def super_server_command
    @db[:project]
      .select(:super_server_command)
      .first[:super_server_command]
  end

  private
  def _connect_with_supplied_password
    db = Sequel.connect("oracle://#{@account}:#{@password}@#{ENV[:TWO_TASK]}")
    begin
      db if db.test_connection
    rescue
      if @password != @name
        begin
          _connect_with_default_password
        rescue
          raise "password supplied is not valid, " + $!.to_s
        end
      else
        begin
          _connect_with_gfdba_password
        rescue
          raise "password supplied is not valid and " + $!.to_s
        end
      end
    end
  end

  def _connect_with_default_password
    db = Sequel.connect("oracle://#{@account}:#{@account}@#{ENV[:TWO_TASK]}")
    begin
      db if db.test_connection
    rescue Sequel::DatabaseConnectionError => error
      begin
        _connect_with_gfdba_password
      rescue
        raise "default password for #{@name} is not valid and " + $!.to_s
      end
    end
  end

  def _connect_with_gfdba_password
    raise "GFDBA_PASSWORD is not set" unless ENV[:GFDBA_PASSWORD]
    begin
      Open3.popen3("proj_get_password #{@name} password") do |stdin, stdout, stderr|
        errors = stderr.read
        raise 'GFDBA_PASSWORD is not valid' if errors =~ /^Invalid password/m
        stdout.read =~ /^Password =(.*)$/m
        $1 or raise errors
        db = Sequel.connect("oracle://#{@account}:#{$1.chomp}@#{ENV[:TWO_TASK]}")
        db if db.test_connection
      end
    rescue Errno::ENOENT
      raise 'unable to run proj_get_password'
    end
  end
end
