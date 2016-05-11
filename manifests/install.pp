# See README.md for usage information
define nvm::install (
  $user                = $title,
  $home                = undef,
  $nvm_dir             = undef,
  $profile_path        = undef,
  $version             = $nvm::params::version,
  $manage_user         = $nvm::params::manage_user,
  $manage_dependencies = $nvm::params::manage_dependencies,
  $manage_profile      = $nvm::params::manage_profile,
  $nvm_repo            = $nvm::params::nvm_repo,
  $refetch             = $nvm::params::refetch,
  $install_node        = $nvm::params::install_node,
  $node_instances      = $nvm::params::node_instances,
) {

  if $home == undef and $user == 'root' {
    $final_home = '/root'
  }
  elsif $home == undef {
    $final_home = "/home/${user}"
  }
  else {
    $final_home = $home
  }

  if $nvm_dir == undef {
    $final_nvm_dir = "/home/${user}/.nvm"
  }
  else {
    $final_nvm_dir = $nvm_dir
  }

  if $profile_path == undef {
    $final_profile_path = "/home/${user}/.bashrc"
  }
  else {
    $final_profile_path = $profile_path
  }

  validate_string($user)
  validate_string($final_home)
  validate_string($final_nvm_dir)
  validate_string($final_profile_path)
  validate_string($version)
  validate_bool($manage_user)
  validate_bool($manage_dependencies)
  validate_bool($manage_profile)
  if $install_node {
    validate_string($install_node)
  }
  validate_hash($node_instances)

  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

  if $manage_user {
    user { $user:
      ensure     => present,
      home       => $final_home,
      managehome => true,
      before     => Class['nvm::install']
    }
  }

  if $manage_dependencies {
    $nvm_install_require = Package['git','wget','make']
  #  ensure_packages(['git', 'wget', 'make'])
  }
  else {
    $nvm_install_require = undef
  }

  $dependencies = $nvm_install_require

  if $install_node {
    $final_node_instances = merge($node_instances, {
      "${install_node}" => {
        set_default => true,
      },
    })
  }
  else {
    $final_node_instances = $node_instances
  }

  exec { "git clone ${nvm_repo} ${final_nvm_dir} for ${user}":
    command => "git clone ${nvm_repo} ${final_nvm_dir}",
    cwd     => $home,
    user    => $user,
    unless  => "/usr/bin/test -d ${final_nvm_dir}/.git",
    require => $dependencies,
    notify  => Exec["git checkout ${nvm_repo} ${version} for ${user}"],
  }

  if $refetch {
    exec { "git fetch ${nvm_repo} ${final_nvm_dir} for ${user}":
      command => 'git fetch',
      cwd     => $final_nvm_dir,
      user    => $user,
      require => Exec["git clone ${nvm_repo} ${final_nvm_dir} for ${user}"],
      notify  => Exec["git checkout ${nvm_repo} ${version} for ${user}"],
    }
  }

  if $version == 'auto' {
    $co_cmd = 'git checkout --quiet `git describe --abbrev=0 --tags`'
  } else {
    $co_cmd = "git checkout --quiet ${version}"
  }

  exec { "git checkout ${nvm_repo} ${version} for ${user}":
    command     => $co_cmd,
    cwd         => $final_nvm_dir,
    user        => $user,
    refreshonly => true,
  }

  create_resources(::nvm::node::install, $final_node_instances, {
    user        => $user,
    nvm_dir     => $final_nvm_dir,
  })

  if $manage_profile {
    file { "ensure ${final_profile_path} for ${user}":
      ensure => 'present',
      path   => $final_profile_path,
      owner  => $user,
    } ->

    file_line { "add NVM_DIR to profile file for ${user}":
      path => $final_profile_path,
      line => "export NVM_DIR=${final_nvm_dir}",
    } ->

    file_line { "add . ~/.nvm/nvm.sh to profile file for ${user}":
      path => $final_profile_path,
      line => "[ -s \"\$NVM_DIR/nvm.sh\" ] && . \"\$NVM_DIR/nvm.sh\"  # This loads nvm",
    }
  }


}
