require 'test/unit'
require File.dirname(__FILE__) + '/../lib/catalog'

class CatalogTest < Test::Unit::TestCase
	def setup
		ENV['TWO_TASK'] = 'gfprod'
		ENV['BASELINE_ACC'] = 'GF4'
		@catalog = Catalog.new
	end

	def test_initialize_without_TWO_TASK_fails
		ENV['TWO_TASK'] = nil
		assert_raises(RuntimeError) { Catalog.new }
	end

	def test_initialize_without_BASELINE_ACC_fails
		ENV['BASELINE_ACC'] = nil
		assert_raises(RuntimeError) { Catalog.new }
	end

	def test_projects
		assert_equal 357, @catalog.projects.count
	end
end
