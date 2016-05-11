require 'spec_helper_acceptance'

describe 'nvm class' do

  describe 'running puppet code' do
    pp = <<-EOS
      class { 'nvm':
      }

      nvm::install { 'foo': }
      nvm::install { 'bar': }

      nvm::node::install { '4.3.1':
          user        => 'foo',
          set_default => true,
      }

      nvm::node::install { '0.10.40':
          user    => 'foo',
      }

      nvm::node::install { '6.0.0':
          user        => 'bar',
          set_default => true,
      }
    EOS
    let(:manifest) { pp }

    it 'should work with no errors' do
      apply_manifest(manifest, :catch_failures => true)
    end

    it 'should be idempotent' do
      apply_manifest(manifest, :catch_changes => true)
    end

    describe command('su - foo -c ". /home/foo/.nvm/nvm.sh && nvm --version" -s /bin/bash') do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /0.29.0/ }
    end

    describe command('su - foo -c ". /home/foo/.nvm/nvm.sh && node --version" -s /bin/bash') do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /4.3.1/ }
    end

    describe command('su - foo -c ". /home/foo/.nvm/nvm.sh && nvm ls" -s /bin/bash') do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /0.10.40/ }
    end

    describe command('su - bar -c ". /home/bar/.nvm/nvm.sh && nvm ls" -s /bin/bash') do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /6.0.0/ }
    end

  end

end
