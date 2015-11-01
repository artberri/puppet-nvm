require 'spec_helper'

describe 'nvm::node::install', :type => :define do
  let(:title) { '0.12.7' }
  let(:pre_condition) { [
      'class { "nvm": user => "foo" }'
  ] }

  context 'with default => false' do
    let :params do
    {
      :user    => 'foo',
      :nvm_dir => 'nvm_dir'
    }
    end

    it { should contain_exec('nvm install node version 0.12.7')
                    .with_command('. nvm_dir/nvm.sh && nvm install  0.12.7')
                    .with_user('foo')
                    .with_unless('. nvm_dir/nvm.sh && nvm which 0.12.7')
                    .that_requires('Class[nvm::install]')
                    .with_provider('shell')
    }
    it { should_not contain_exec('nvm set node version 0.12.7 as default') }
  end

  context 'with default => true' do
    let :params do
    {
      :user    => 'foo',
      :nvm_dir => 'nvm_dir',
      :default => true
    }
    end

    it { should contain_exec('nvm install node version 0.12.7')
                    .with_command('. nvm_dir/nvm.sh && nvm install  0.12.7')
                    .with_user('foo')
                    .with_unless('. nvm_dir/nvm.sh && nvm which 0.12.7')
                    .that_requires('Class[nvm::install]')
                    .with_provider('shell')
    }
    it { should contain_exec('nvm set node version 0.12.7 as default')
                    .with_command('. nvm_dir/nvm.sh && nvm alias default 0.12.7')
                    .with_user('foo')
                    .with_unless('. nvm_dir/nvm.sh && nvm which default | grep 0.12.7')
                    .with_provider('shell')
    }
  end

  context 'with from_source => true' do
    let :params do
    {
      :user        => 'foo',
      :nvm_dir     => 'nvm_dir',
      :from_source => true
    }
    end

    it { should contain_exec('nvm install node version 0.12.7')
                    .with_command('. nvm_dir/nvm.sh && nvm install  -s  0.12.7')
                    .with_user('foo')
                    .with_unless('. nvm_dir/nvm.sh && nvm which 0.12.7')
                    .that_requires('Class[nvm::install]')
                    .with_provider('shell')
    }
    it { should_not contain_exec('nvm set node version 0.12.7 as default') }
  end

  context 'without required param user' do
    it { expect { catalogue }.to raise_error }
  end


end
