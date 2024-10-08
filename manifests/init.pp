# @summary setup OpenVPN Access Server
#
# Install and configure OpenVPN Access Server
#
# @example
#   include ::openvpnas
#
class openvpnas (
  Variant[Enum['present', 'absent', 'purged', 'disabled', 'installed', 'latest'], String[1]] $package_ensure = 'installed',
  Enum['running', 'stopped'] $service_ensure = 'running',
  Boolean $service_enable                    = true,
  String $service_name                       = 'openvpnas',
  Hash $config = {},
  Hash $userprop = {},
) {
  contain 'openvpnas::install'
  contain 'openvpnas::service'

  Class['openvpnas::install']
  -> Class['openvpnas::service']

  $failover_mode = $::openvpnas[failover_mode]
  $failover_state = $::openvpnas[failover_state]
  notify { "failover_mode is '${failover_mode}' and failover_state is '${failover_state}'.": }

  if ($failover_mode == '') or ($failover_mode == 'ucarp' and $failover_state == 'active') {
    create_resources(openvpnas::config, $config)
    create_resources(openvpnas::userprop, $userprop)
  } else {
    notify { "Skipping openvpnas_config and openvpnas_userprop resources due to failover_mode(${failover_mode}) and failover_state(${failover_state}).": }
  }
}
