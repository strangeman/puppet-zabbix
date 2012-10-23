class {'zabbix::client':
  hostname => 'mysqlserver',
  user_parameters => ['mysql.ping,mysqladmin -uroot ping|grep alive|wc -l',
                      'system.test,who|wc -l',
                      'softraid.status,egrep \"\\[.*_.*\\]\" /proc/mdstat|wc -l',]
}