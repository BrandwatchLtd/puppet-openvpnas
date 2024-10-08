define openvpnas::userprop (
  String $ensure = present,
  String $value,
) {
  if ($::openvpnas[failover_mode] == '' ) or ($::openvpnas[failover_mode] == 'ucarp' and $::openvpnas[failover_state] == 'active') {
    openvpnas_userprop { $name:
      ensure => $ensure,
      value => $value,
    }
  }
}
