class Catalog
  def initialize
    ENV['TWO_TASK'] or raise "ERROR: TWO_TASK environment variable not set!"
    ENV['BASELINE_ACC'] or raise "ERROR: BASELINE_ACC environment variable not set!"
  end
end
