define openvpnas::config (
  String $ensure = present,
  String $value,
) {
  if ($::openvpnas[failover_mode] == '' ) or ($::openvpnas[failover_mode] == 'ucarp' and $::openvpnas[failover_state] == 'active') {
    openvpnas_config { $name:
      ensure => $ensure,
      value => $value,
    }
  }
}
