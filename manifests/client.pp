# == Class: zabbix::client
#
# Данный класс предоставляет конфигурацию агента zabbix
#
# This class provide zabbix agent configuration
#
# === Parameters
# [*zabbix_server*]
#   String of comma delimited IP addresses (or hostnames) of ZABBIX servers.
# [*server_port*]
#   Server port for sending active checks.
# [*hostname*]
#   REGUIRED! Unique hostname. Required for active checks.
# [*listen_port*]
#   Listen port. Default is 10050.
# [*listen_ip*]
#   IP address to bind agent. If 'false', bind to all available IPs
# [*start_agents*]
#   Number of pre-forked instances of zabbix_agentd. 1-16
# [*refresh_active_checks*]
#   How often refresh list of active checks. 2 minutes by default.
# [*disable_active_checks*]
#   Disable active checks. The agent will work in passive mode listening server.
# [*enable_remote_commands*]
#   Enable remote commands for ZABBIX agent. By default remote commands disabled.
# [*debug_level*]
#   Specifies debug level.
# [*pid_file*]
#   Name of PID file.
# [*log_file*]
#   Name of log file. If not set, syslog will be used.
# [*log_file_size*]
#   Maximum size of log file in MB. Set to 0 to disable automatic log rotation.
# [*time_out*]
#   Spend no more than Timeout seconds on processing. Must be between 1 and 30.
# [*user_parameters*]
#   List of user-defined monitoring parameters.
#
# === Actions
# - устанавливает пакет zabbix-agent / install 'zabbix-agent' package
# - создает конфигурационный файл / create config file
# - запускает и контролирует демон zabbix-agent / run and control zabbix-agent daemon
#
# === Examples
#  class {'zabbix::client':
#    hostname => 'testtesttest',
#    user_parameters => ['mysql.ping,mysqladmin -uroot ping|grep alive|wc -l',
#                       'system.test,who|wc -l',
#                       'softraid.status,egrep \"\\[.*_.*\\]\" /proc/mdstat|wc -l']
#  }
# === Authors
# Anton Markelov <doublic@gmail.com> <markelovaa@dalstrazh.ru>
#
class zabbix::client(
  $zabbix_server          = 'zabbix.localnet',
  $server_port            = '10051',
  $hostname               = false,
  $listen_port            = '10050',
  $listen_ip              = false,
  $start_agents           = 5,
  $refresh_active_checks  = 120,
  $disable_active_checks  = 0,
  $enable_remote_commands = 0,
  $debug_level            = 3,
  $pid_file               = false,
  $log_file               = '/var/log/zabbix-agent/zabbix_agentd.log',
  $log_file_size          = 1,
  $time_out               = 3,
  $user_parameters        = false
  ) {

  if $hostname == false {
    fail('Module zabbix: hostname parameter required!')
  }

  if $pid_file == false {
    case $::lsbdistid {
      'debian': {
        $conf_pid_file = '/var/run/zabbix-agent/zabbix_agentd.pid'
      }
      'ubuntu': {
        $conf_pid_file = '/var/run/zabbix/zabbix_agentd.pid'
      }
      default: {
        fail("Module zabbix is not supported on ${::operatingsystem}")
      }
    }
  }
else {
  $conf_pid_file = $pid_file
}

  #install zabbix
  package{'zabbix-agent':
    ensure => installed,
  }

  file {'/etc/zabbix/zabbix_agentd.conf':
    content => template('zabbix/zabbix_agentd.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  service {'zabbix-agent':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
  }

  Package['zabbix-agent']->File['/etc/zabbix/zabbix_agentd.conf']~>Service['zabbix-agent']
}