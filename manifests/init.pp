# See README.md for usage information
class nvm (
  $version             = $nvm::params::version,
  $manage_user         = $nvm::params::manage_user,
  $manage_dependencies = $nvm::params::manage_dependencies,
  $manage_profile      = $nvm::params::manage_profile,
  $nvm_repo            = $nvm::params::nvm_repo,
  $refetch             = $nvm::params::refetch,
  $install_node        = $nvm::params::install_node,
  $node_instances      = $nvm::params::node_instances,
) inherits ::nvm::params {
  if $manage_dependencies {
     $nvm_install_require = Package['git','wget','make']
     ensure_packages(['git', 'wget', 'make'])
   }

  create_resources(::nvm::install, hiera_hash('nvm::install', {}))
  create_resources(::nvm::node::install, hiera_hash('nvm::node::install', {}))
}
