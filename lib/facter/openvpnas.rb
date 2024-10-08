Facter.add(:openvpnas) do
  setcode do
    failover_mode = ''
    failover_state = ''
    
    # When failover.mode=ucarp, the openvpnas daemon will not run on the standby server and sacli fails.
    # Therefore it is necessary to look inside the configuration database directly.

    # Check that SQLite database is used to store the configuration. Only SQLite is supported for now.
    sqlite_default = Facter::Core::Execution.execute("grep ^config_db=sqlite:///~/db/config.db /usr/local/openvpn_as/etc/as.conf")
    if sqlite_default != "" then
      # Read the value of the failover.mode in the configuration database.
      failover_mode = Facter::Core::Execution.execute("sqlite3 /usr/local/openvpn_as/etc/db/config.db \"select value from config where name == 'failover.mode' limit 1\"")
      if failover_mode == 'ucarp' then
        # If failover.mode=ucarp then check the running processes.
        ucarp = Facter::Core::Execution.execute("pgrep -af ucarp.*ucarp_active.*ucarp_standby | grep -v \"sh -c /usr/bin/pgrep -af\"")
        if ucarp != "" then
          # The ucarp process is running.
          active = Facter::Core::Execution.execute("pgrep -af \"python3 -c from pyovpn.sagent.sagent_entry import ucarp_active\" | grep -v \"sh -c /usr/bin/pgrep -af\"")
          if active != "" then
            # The openvpnas process is running.
              failover_state = 'active'
          else
            # The openvpnas process is NOT running.
            failover_state = 'standby'
          end
        else
          # The failover.mode is set to ucarp but no ucarp process was found.
          failover_state = 'broken'
        end
      end
    end
    # Return the failover mode and state variables in a hash.
    { :failover_mode => failover_mode, :failover_state => failover_state }
  end
end
