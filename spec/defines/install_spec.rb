require 'spec_helper'

describe 'nvm::install', :type => :define do
  let(:title) { 'foo' }
  let(:pre_condition) { [
      'class { "nvm": }'
  ] }

  context 'with manage_user => true and default home' do
    let :params do
    {
      :user    => 'foo',
      :manage_user => true
    }
    end

    it { should contain_user('foo')
            .with_ensure('present')
            .with_home('/home/foo')
            .with_managehome(true)
    }
  end

  context 'with manage_user => true and custom home' do
    let :params do
    {
      :user => 'foo',
      :manage_user => true,
      :home => '/bar/foo'
    }
    end

    it { should contain_user('foo')
            .with_ensure('present')
            .with_home('/bar/foo')
            .with_managehome(true)
    }
  end


  context 'with manage_profile => false' do
    let :params do
    {
      :user => 'foo',
      :manage_profile => false
    }
    end

    it { should_not contain_file_line('add NVM_DIR to profile file for foo') }
  end

  context 'with install_node => dummyversion' do
    let :params do
    {
      :user => 'foo',
      :install_node => 'dummyversion',
      :nvm_repo => 'dummyrepo'
    }
    end

    it { should contain_nvm__node__install('dummyversion')
                    .with_user('foo')
                    .with_nvm_dir('/home/foo/.nvm')
                    .with_set_default(true)
    }
  end

  context 'with multiple node_instances' do
    let :params do
    {
      :user => 'foo',
      :node_instances => {
          '0.10.40' => {},
          '0.12.7'  => {},
      }
    }
    end

    it { should contain_nvm__node__install('0.10.40')
                    .with_user('foo')
                    .with_nvm_dir('/home/foo/.nvm')
    }
    it { should contain_nvm__node__install('0.12.7')
                    .with_user('foo')
                    .with_nvm_dir('/home/foo/.nvm')
    }
  end

end
