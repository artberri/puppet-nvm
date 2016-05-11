require 'spec_helper'

describe 'nvm', :type => :class do

  context 'with required param user and default params' do

    it { should contain_package('git') }
    it { should contain_package('make') }
    it { should contain_package('wget') }
    it { should_not contain_user('foo') }
  end

  context 'with manage_dependencies => false' do
    let :params do
    {
      :manage_dependencies => false
    }
    end

    it { should_not contain_package('git') }
    it { should_not contain_package('make') }
    it { should_not contain_package('wget') }
  end
end
