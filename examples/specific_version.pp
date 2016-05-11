class { 'nvm': }

nvm::install { 'foo':
  install_node => '0.12.7',
}
