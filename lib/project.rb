require 'sequel'

class Project
  attr_accessor :name, :account

  def initialize(name, account)
    @name = name
    @account = account
  end

  def bulk_server_command
    Sequel.connect("oracle://#{@account}:tigers@gfprod") do |db|
      db[:parameter]
        .select(:value_string)
        .where(:code => 'Bulk_Server_Command')
        .first[:value_string]
    end
  end

  def super_server_command
    Sequel.connect("oracle://#{@account}:tigers@gfprod") do |db|
      db[:project].select(:super_server_command).first[:super_server_command]
    end
  end
end
