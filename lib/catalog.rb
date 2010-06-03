require 'sequel'
require File.dirname(__FILE__) + '/project'

class Catalog
  def initialize
    ENV['TWO_TASK'] or raise "ERROR: TWO_TASK environment variable not set!"
    ENV['BASELINE_ACC'] or raise "ERROR: BASELINE_ACC environment variable not set!"
    ENV['GFPUBLIC_USERID'] ||= 'gf_public:gf_public'
  end

  def projects
    db = Sequel.connect "oracle://#{ENV[:GFPUBLIC_USERID]}@#{ENV[:TWO_TASK]}"
    db[:finder_accounts]
      .select(:project_name, :account_name)
      .where(~{:type => ['PROJSYS', 'SYSTEM']})
      .where(~{:account_name => 'CODES'})
      .where(~{:project_id => 0})
      .where(:baseline_account => 'GF4')
      .where(:project_type => 'STANDALONE')
      .order_by(:project_name)
      .collect do |project|
        Project.new project[:project_name], project[:account_name]
      end
  end
end
