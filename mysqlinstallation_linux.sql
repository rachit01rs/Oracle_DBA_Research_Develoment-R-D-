installation of mysql in redhat 9/centos 9

--copy the link   from  https://repo.mysql.com/ from latest mysql database link
[rabinshrestha@rabin ~]$ sudo wget https://repo.mysql.com/mysql80-community-release-el9-1.noarch.rpm

/*
sudo] password for rabinshrestha: 
--2023-05-18 16:32:32--  https://repo.mysql.com/mysql80-community-release-el9-1.noarch.rpm
Resolving repo.mysql.com (repo.mysql.com)... 104.73.164.232
Connecting to repo.mysql.com (repo.mysql.com)|104.73.164.232|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 10534 (10K) [application/x-redhat-package-manager]
Saving to: ‘mysql80-community-release-el9-1.noarch.rpm’

mysql80-community-r 100%[===================>]  10.29K  --.-KB/s    in 0s      

2023-05-18 16:32:32 (278 MB/s) - ‘mysql80-community-release-el9-1.noarch.rpm’ saved [10534/10534]

*/

[rabinshrestha@rabin ~]$ ls
/*
Desktop    Music                                       Public     Videos
Documents  mysql80-community-release-el9-1.noarch.rpm  scripts
Downloads  Pictures                                    Templates

*/
[rabinshrestha@rabin ~]$ sudo dnf localinstall mysql80-community-release-el9-1.noarch.rpm
/*
pdating Subscription Management repositories.
                        
This system is registered with an entitlement server, but is not receiving updates. You can use subscription-manager to assign subscriptions.

Last metadata expiration check: 0:09:39 ago on Thu 18 May 2023 04:24:01 PM +0545.
Dependencies resolved.
================================================================================
 Package                        Arch        Version     Repository         Size
================================================================================
Installing:
 mysql80-community-release      noarch      el9-1       @commandline       10 k

Transaction Summary
================================================================================
Install  1 Package

Total size: 10 k
Installed size: 5.7 k
Is this ok [y/N]: y
Downloading Packages:
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                        1/1 
  Installing       : mysql80-community-release-el9-1.noarch                 1/1 
  Verifying        : mysql80-community-release-el9-1.noarch                 1/1 
Installed products updated.

Installed:
  mysql80-community-release-el9-1.noarch                                        

Complete!

*/

[rabinshrestha@rabin ~]$ dnf repolist enabled | grep "mysql.*-community.*"
/*
mysql-connectors-community    MySQL Connectors Community
mysql-tools-community         MySQL Tools Community
mysql80-community             MySQL 8.0 Community Server

*/

[rabinshrestha@rabin ~]$ sudo dnf install mysql-community-server

/*
sudo] password for rabinshrestha: 
Updating Subscription Management repositories.
                        
This system is registered with an entitlement server, but is not receiving updates. You can use subscription-manager to assign subscriptions.

MySQL 8.0 Community Server                                                                                         790 kB/s | 839 kB     00:01    
MySQL Connectors Community                                                                                          18 kB/s |  19 kB     00:01    
MySQL Tools Community                                                                                              280 kB/s | 283 kB     00:01    
Dependencies resolved.
===================================================================================================================================================
 Package                                         Architecture            Version                          Repository                          Size
===================================================================================================================================================
Installing:
 mysql-community-server                          x86_64                  8.0.33-1.el9                     mysql80-community                   49 M
     replacing  mariadb-connector-c-config.noarch 3.2.6-1.el9_0
Installing dependencies:
 mysql-community-client                          x86_64                  8.0.33-1.el9                     mysql80-community                  3.9 M
 mysql-community-client-plugins                  x86_64                  8.0.33-1.el9                     mysql80-community                  1.4 M
 mysql-community-common                          x86_64                  8.0.33-1.el9                     mysql80-community                  554 k
 mysql-community-icu-data-files                  x86_64                  8.0.33-1.el9                     mysql80-community                  2.2 M
 mysql-community-libs                            x86_64                  8.0.33-1.el9                     mysql80-community                  1.5 M

Transaction Summary
===================================================================================================================================================
Install  6 Packages

Total download size: 59 M
Is this ok [y/N]: y
Downloading Packages:
(1/6): mysql-community-common-8.0.33-1.el9.x86_64.rpm                                                              265 kB/s | 554 kB     00:02    
(2/6): mysql-community-client-plugins-8.0.33-1.el9.x86_64.rpm                                                      309 kB/s | 1.4 MB     00:04    
(3/6): mysql-community-libs-8.0.33-1.el9.x86_64.rpm                                                                272 kB/s | 1.5 MB     00:05    
(4/6): mysql-community-client-8.0.33-1.el9.x86_64.rpm                                                              335 kB/s | 3.9 MB     00:11    
(5/6): mysql-community-icu-data-files-8.0.33-1.el9.x86_64.rpm                                                      175 kB/s | 2.2 MB     00:12    
(6/6): mysql-community-server-8.0.33-1.el9.x86_64.rpm                                                              773 kB/s |  49 MB     01:05    
---------------------------------------------------------------------------------------------------------------------------------------------------
Total                                                                                                              797 kB/s |  59 MB     01:15     
MySQL 8.0 Community Server                                                                                         3.0 MB/s | 3.1 kB     00:00    
Importing GPG key 0x3A79BD29:
 Userid     : "MySQL Release Engineering <mysql-build@oss.oracle.com>"
 Fingerprint: 859B E8D7 C586 F538 430B 19C2 467B 942D 3A79 BD29
 From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-mysql-2022
Is this ok [y/N]: y
Key imported successfully
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                                                                                           1/1 
  Installing       : mysql-community-common-8.0.33-1.el9.x86_64                                                                                1/7 
  Installing       : mysql-community-client-plugins-8.0.33-1.el9.x86_64                                                                        2/7 
  Installing       : mysql-community-libs-8.0.33-1.el9.x86_64                                                                                  3/7 
  Running scriptlet: mysql-community-libs-8.0.33-1.el9.x86_64                                                                                  3/7 
  Installing       : mysql-community-client-8.0.33-1.el9.x86_64                                                                                4/7 
  Installing       : mysql-community-icu-data-files-8.0.33-1.el9.x86_64                                                                        5/7 
  Running scriptlet: mysql-community-server-8.0.33-1.el9.x86_64                                                                                6/7 
  Installing       : mysql-community-server-8.0.33-1.el9.x86_64                                                                                6/7 
  Running scriptlet: mysql-community-server-8.0.33-1.el9.x86_64                                                                                6/7 
  Obsoleting       : mariadb-connector-c-config-3.2.6-1.el9_0.noarch                                                                           7/7 
  Running scriptlet: mariadb-connector-c-config-3.2.6-1.el9_0.noarch                                                                           7/7 
  Verifying        : mysql-community-client-8.0.33-1.el9.x86_64                                                                                1/7 
  Verifying        : mysql-community-client-plugins-8.0.33-1.el9.x86_64                                                                        2/7 
  Verifying        : mysql-community-common-8.0.33-1.el9.x86_64                                                                                3/7 
  Verifying        : mysql-community-icu-data-files-8.0.33-1.el9.x86_64                                                                        4/7 
  Verifying        : mysql-community-libs-8.0.33-1.el9.x86_64                                                                                  5/7 
  Verifying        : mysql-community-server-8.0.33-1.el9.x86_64                                                                                6/7 
  Verifying        : mariadb-connector-c-config-3.2.6-1.el9_0.noarch                                                                           7/7 
Installed products updated.

Installed:
  mysql-community-client-8.0.33-1.el9.x86_64         mysql-community-client-plugins-8.0.33-1.el9.x86_64 mysql-community-common-8.0.33-1.el9.x86_64
  mysql-community-icu-data-files-8.0.33-1.el9.x86_64 mysql-community-libs-8.0.33-1.el9.x86_64           mysql-community-server-8.0.33-1.el9.x86_64

Complete!
*/

[rabinshrestha@rabin ~]$ sudo systemctl status mysqld
/*
[sudo] password for rabinshrestha: 
○ mysqld.service - MySQL Server
     Loaded: loaded (/usr/lib/systemd/system/mysqld.service; enabled; vendor preset: disabled)
     Active: inactive (dead)
       Docs: man:mysqld(8)
             http://dev.mysql.com/doc/refman/en/using-systemd.html

*/

[rabinshrestha@rabin ~]$ sudo service mysqld status

/*
Redirecting to /bin/systemctl status mysqld.service
○ mysqld.service - MySQL Server
     Loaded: loaded (/usr/lib/systemd/system/mysqld.service; enabled; vendor preset: disabled)
     Active: inactive (dead)
       Docs: man:mysqld(8)
             http://dev.mysql.com/doc/refman/en/using-systemd.html
			 
*/
[rabinshrestha@rabin ~]$ sudo systemctl start mysqld



rabinshrestha@rabin ~]$ sudo systemctl status mysqld
/*
● mysqld.service - MySQL Server
     Loaded: loaded (/usr/lib/systemd/system/mysqld.service; enabled; vendor preset: disabled)
     Active: active (running) since Thu 2023-05-18 16:58:28 +0545; 2min 12s ago
       Docs: man:mysqld(8)
             http://dev.mysql.com/doc/refman/en/using-systemd.html
   Main PID: 52499 (mysqld)
     Status: "Server is operational"
      Tasks: 37 (limit: 22808)
     Memory: 474.8M
        CPU: 3.982s
     CGroup: /system.slice/mysqld.service
             └─52499 /usr/sbin/mysqld

May 18 16:58:23 rabin systemd[1]: Starting MySQL Server...
May 18 16:58:28 rabin systemd[1]: Started MySQL Server.

*/
[rabinshrestha@rabin ~]$ sudo systemctl enable mysqld

*/
[rabinshrestha@rabin ~]$ mysql --version
/*
mysql  Ver 8.0.33 for Linux on x86_64 (MySQL Community Server - GPL)

*/

--to find the temporary password 
[rabinshrestha@rabin ~]$ sudo grep 'temporary password' /var/log/mysqld.log
/*
2023-05-18T11:13:25.731360Z 6 [Note] [MY-010454] [Server] A temporary password is generated for root@localhost: _w?I#sp9i>kl

*/

[rabinshrestha@rabin ~]$ mysql_secure_installation



/*
Securing the MySQL server deployment.

Enter password for user root: 

The existing password for the user account root has expired. Please set a new password.

New password: 

Re-enter new password: 
 ... Failed! Error: Your password does not satisfy the current policy requirements

New password: 

Re-enter new password: 
The 'validate_password' component is installed on the server.
The subsequent steps will run with the existing configuration
of the component.
Using existing password for root.

Estimated strength of the password: 100 
Change the password for root ? ((Press y|Y for Yes, any other key for No) : n

 ... skipping.
By default, a MySQL installation has an anonymous user,
allowing anyone to log into MySQL without having to have
a user account created for them. This is intended only for
testing, and to make the installation go a bit smoother.
You should remove them before moving into a production
environment.

Remove anonymous users? (Press y|Y for Yes, any other key for No) : y
Success.


Normally, root should only be allowed to connect from
'localhost'. This ensures that someone cannot guess at
the root password from the network.

Disallow root login remotely? (Press y|Y for Yes, any other key for No) : n

 ... skipping.
By default, MySQL comes with a database named 'test' that
anyone can access. This is also intended only for testing,
and should be removed before moving into a production
environment.


Remove test database and access to it? (Press y|Y for Yes, any other key for No) : n

 ... skipping.
Reloading the privilege tables will ensure that all changes
made so far will take effect immediately.

Reload privilege tables now? (Press y|Y for Yes, any other key for No) : y
Success.

All done!
*/ 
[rabinshrestha@rabin ~]$ mysql -u root -p
/*
Enter password:Adminrabin@1 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 11
Server version: 8.0.33 MySQL Community Server - GPL

Copyright (c) 2000, 2023, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> 

*/

mysql> show databases;
/*
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
4 rows in set (0.00 sec)

mysql> 
mysql> create database testdb;
    
Query OK, 1 row affected (0.01 sec)

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| testdb             |
+--------------------+
5 rows in set (0.01 sec)

*/