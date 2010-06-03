require 'test/unit'
require File.dirname(__FILE__) + '/../lib/project'

class ProjectTest < Test::Unit::TestCase
  def test_initialize_without_name_fails
    assert_raises(ArgumentError) { Project.new }
  end

  def test_initialize_without_account_fails
    assert_raises(ArgumentError) { Project.new(:name) }
  end

  def test_initialize_succeeds_with_name_and_account
    assert_nothing_raised { Project.new(:name, :account) }
  end
end
