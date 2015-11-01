# See README.md for usage information
class nvm (
  $user,
  $home                = "/home/${user}",
  $nvm_dir             = "/home/${user}/.nvm",
  $profile_path        = "/home/${user}/.bashrc",
  $version             = $nvm::params::version,
  $manage_user         = $nvm::params::manage_user,
  $manage_dependencies = $nvm::params::manage_dependencies,
  $manage_profile      = $nvm::params::manage_profile,
  $nvm_repo            = $nvm::params::nvm_repo,
  $refetch             = $nvm::params::refetch,
  $install_node        = $nvm::params::install_node,
) inherits ::nvm::params {

  validate_string($user)
  validate_string($home)
  validate_string($nvm_dir)
  validate_string($version)
  validate_bool($manage_user)
  validate_bool($manage_dependencies)
  validate_bool($manage_profile)
  if $install_node {
    validate_string($install_node)
  }

  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

  if $manage_dependencies {
    $nvm_install_require = Package['git','wget','make']
    ensure_packages(['git', 'wget', 'make'])
  }
  else {
    $nvm_install_require = undef
  }

  if $manage_user {
    user { $user:
      ensure     => present,
      home       => $home,
      managehome => true,
      before     => Class['nvm::install']
    }
  }

  class { 'nvm::install':
    user         => $user,
    version      => $version,
    nvm_dir      => $nvm_dir,
    nvm_repo     => $nvm_repo,
    dependencies => $nvm_install_require,
    refetch      => $refetch,
  }

  if $manage_profile {
    file { "ensure ${profile_path}":
      ensure => 'present',
      path   => $profile_path,
      owner  => $user,
    } ->

    file_line { 'add NVM_DIR to profile file':
      path => $profile_path,
      line => "export NVM_DIR=${nvm_dir}",
    } ->

    file_line { 'add . ~/.nvm/nvm.sh to profile file':
      path => $profile_path,
      line => "[ -s \"\$NVM_DIR/nvm.sh\" ] && . \"\$NVM_DIR/nvm.sh\"  # This loads nvm",
    }
  }

  if $install_node {
    nvm::node::install { $install_node:
      user    => $user,
      nvm_dir => $nvm_dir,
      default => true,
    }
  }

}
