require 'test/unit'
require File.dirname(__FILE__) + '/../lib/project'

class ProjectTest < Test::Unit::TestCase
  ENV[:GFDBA_PASSWORD] = nil

  def setup
    @p = Project.new(:wts_work_proj, :WTS_WORK_PROJ, :tigers)
  end

  def test_initialize_without_name_fails
    assert_raises(ArgumentError) { Project.new }
  end

  def test_initialize_without_account_fails
    assert_raises(ArgumentError) { Project.new(:name) }
  end

  def test_initialize_succeeds_with_name_and_account
    assert_nothing_raised { Project.new(:name, :account) }
  end

#  def test_connect
#    assert @p.connect
#  end

  def test_connect_with_supplied_password
    @p = Project.new(:wts_work_proj, :WTS_WORK_PROJ, :tigers)
    assert_nothing_raised { @p.send :_connect_with_supplied_password }
  end

  def test_connect_with_invalid_supplied_password
    @p = Project.new(:wts_work_proj, :WTS_WORK_PROJ, :password)
    assert_block do
      begin
        @p.send :_connect_with_supplied_password
      rescue
        $!.to_s == 'password supplied is not valid, default password for wts_work_proj is not valid and GFDBA_PASSWORD is not set'
      end
    end
  end

  def test_connect_with_invalid_supplied_password_same_as_default
    @p = Project.new(:wts_work_proj, :WTS_WORK_PROJ, :wts_work_proj)
    assert_block do
      begin
        @p.send :_connect_with_supplied_password
      rescue
        $!.to_s == 'password supplied is not valid and GFDBA_PASSWORD is not set'
      end
    end
  end

  def test_connect_using_default_password
    @p = Project.new(:la_cam_jh, :LA_CAM_JH)
    assert_nothing_raised { @p.send :_connect_with_default_password }
  end

  def test_connect_using_invalid_default_password
    assert_block do
      @p = Project.new(:wts_work_proj, :WTS_WORK_PROJ)
      begin
        @p.send :_connect_with_default_password
      rescue
        $!.to_s == 'default password for wts_work_proj is not valid and GFDBA_PASSWORD is not set'
      end
    end
  end

  def test_connect_using_GFDBA_PASSWORD_without_PATH
    path = ENV[:PATH]
    ENV[:PATH] = ENV[:PATH].split(/:/).delete_if {|path| path =~ /geoframe/}.join(':')
    assert_block do
      @p = Project.new(:wts_work_proj, :WTS_WORK_PROJ)
      begin
        @p.send :_connect_with_gfdba_password
      rescue
        $!.to_s == 'unable to run proj_get_password' 
      end
    end
    ENV[:PATH] = path
  end

  def test_connect_using_GFDBA_PASSWORD_without_LD_LIBRARY_PATH
    ld_library_path = ENV[:LD_LIBRARY_PATH]
    ENV[:LD_LIBRARY_PATH] = ENV[:LD_LIBRARY_PATH].split(/:/).delete_if {|path| path =~ /geoframe/}.join(':')
    assert_block do
      @p = Project.new(:wts_work_proj, :WTS_WORK_PROJ)
      begin
        @p.send :_connect_with_gfdba_password
      rescue
        $!.to_s =~ /error while loading shared libraries/
      end
    end
    ENV[:LD_LIBRARY_PATH] = ld_library_path
  end

  def test_connect_using_GFDBA_PASSWORD_without_being_set
    assert_block do
      @p = Project.new(:wts_work_proj, :WTS_WORK_PROJ)
      begin
        @p.send :_connect_with_gfdba_password
      rescue
        $!.to_s == 'GFDBA_PASSWORD is not set' 
      end
    end
  end

  def test_connect_using_wrong_GFDBA_PASSWORD
    ENV[:GFDBA_PASSWORD] = :bogus
    @p = Project.new(:wts_work_proj, :WTS_WORK_PROJ)
    assert_block do
      begin
        @p.send(:_connect_with_gfdba_password)
      rescue
        $!.to_s == 'GFDBA_PASSWORD is not valid'
      end
    end
    ENV[:GFDBA_PASSWORD] = nil
  end

  def test_connect_using_GFDBA_PASSWORD
    ENV[:GFDBA_PASSWORD] = :midway
    @p = Project.new(:wts_work_proj, :WTS_WORK_PROJ)
    assert_nothing_raised { @p.send(:_connect_with_gfdba_password) }
  end

  def test_bulk_server_command
    p = Project.new(:nova_atchmrg, :NOVA_ATCHMRG, :tigers)
    p.connect
    assert_equal 'LOCAL:NOVA_ATCHMRG@hesz04.internal.houstonenergyinc.com:/apps/geoframe/geoframe_44_sun/bin/ctsrvr_init.csh', p.bulk_server_command
  end

  def test_super_server_command
    p = Project.new(:nova_atchmrg, :NOVA_ATCHMRG, :tigers)
    p.connect
    assert_equal 'LOCAL:hesz04.internal.houstonenergyinc.com:/apps/geoframe/geoframe_44_sun/bin/apu_superserver_init.csh', p.super_server_command
  end
end
