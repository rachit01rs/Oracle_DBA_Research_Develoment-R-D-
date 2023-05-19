[oracle@oemserver ~]$ sqlplus sys/Adminrabin1@OEMDB as sysdba

SQL*Plus: Release 19.0.0.0.0 - Production on Thu Apr 13 13:03:23 2023
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.


Connected to:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.3.0.0.0

SQL> select name,open_mode from v$database;
/*
NAME      OPEN_MODE
--------- --------------------
OEMDB     READ WRITE

*/


SQL> alter system set "_allow_insert_with_update_check"=true scope=both;

System altered.

SQL> alter system set session_cached_cursors=200 scope=spfile;

System altered.

SQL> alter system set shared_pool_size=600M scope=spfile;

System altered.

SQL> alter system set processes=600 scope=spfile;

System altered.

SQL> shut immediate;
Database closed.
Database dismounted.
ORACLE instance shut down.
SQL> startup;
ORACLE instance started.

Total System Global Area 2415917880 bytes
Fixed Size                  8899384 bytes
Variable Size             654311424 bytes
Database Buffers         1744830464 bytes
Redo Buffers                7876608 bytes
Database mounted.
Database opened.


SQL> show parameter session_cached_cursors;

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
session_cached_cursors               integer     200
SQL>
SQL>
SQL>
SQL> show parameter "_allow_insert_with_update_check";

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
_allow_insert_with_update_check      boolean     TRUE
SQL>
SQL>
SQL> show parameter shared_pool_size;

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
shared_pool_size                     big integer 608M
SQL>
SQL>
SQL> show parameter processes;
/*
NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
aq_tm_processes                      integer     1
db_writer_processes                  integer     1
gcs_server_processes                 integer     0
global_txn_processes                 integer     1
job_queue_processes                  integer     40
log_archive_max_processes            integer     4
processes

*/                            integer     600
SQL>

--Install EM Cloud Control 13c Release 3 (13.5.0.0)


[oracle@oemserver ~]$ mkdir -p /u01/app/oracle/middleware
[oracle@oemserver ~]$
[oracle@oemserver ~]$ mkdir -p /u01/app/oracle/agent


[oracle@oemserver BKP_EM_13C]$ ls
em13500_linux64-2.zip  em13500_linux64-3.zip  em13500_linux64-4.zip  em13500_linux64-5.zip  em13500_linux64.bin
[oracle@oemserver BKP_EM_13C]$ ./em13500_linux64.bin
auncher log file is /tmp/OraInstall2023-04-13_03-18-11PM/launcher2023-04-13_03-18-11PM.log.
Extracting the installer . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . Done
Checking monitor: must be configured to display at least 256 colors.   Actual 16777216    Passed
Checking swap space: must be greater than 512 MB.   Actual 15359 MB    Passed
Checking if this platform requires a 64-bit JVM.   Actual 64    Passed (64-bit not required)
Preparing to launch the Oracle Universal Installer from /tmp/OraInstall2023-04-13_03-18-11PM
ScratchPathValue :/tmp/OraInstall2023-04-13_03-18-11PM


[root@oemserver ~]# /u01/app/oracle/middleware/allroot.sh

Starting to execute allroot.sh ......... 

Starting to execute /u01/app/oracle/middleware/root.sh ......
Check /u01/app/oracle/middleware/install/root_oemserver.com.np_2023-04-13_20-07-27.log for the output of root script

Finished product-specific root actions.
/etc exist
Finished execution of  /u01/app/oracle/middleware/root.sh ......


Starting to execute /u01/app/oracle/agent/agent_13.5.0.0.0/root.sh ......

Finished product-specific root actions.
/etc exist
Finished execution of  /u01/app/oracle/agent/agent_13.5.0.0.0/root.sh ......
[root@oemserver ~]# 

-- Stop EM Cloud Control 13C
--stop OMS
[oracle@oemserver ~]$ export OMS_HOME=/u01/app/oracle/middleware
[oracle@oemserver ~]$ /u01/app/oracle/middleware/bin/emctl stop oms -all or emctl stop oms -all -force
/*
Oracle Enterprise Manager Cloud Control 13c Release 5
Copyright (c) 1996, 2021 Oracle Corporation.  All rights reserved.
Stopping Oracle Management Server...
WebTier Successfully Stopped
Oracle Management Server Successfully Stopped
Oracle Management Server is Down
JVMD Engine is Down
BI Publisher is disabled, to enable BI Publisher on this host, use the 'emctl config oms -enable_bip' command
Stopping BI Publisher Server...
BI Publisher Server Already Stopped
BI Publisher is disabled, to enable BI Publisher on this host, use the 'emctl config oms -enable_bip' command
AdminServer Successfully Stopped
BI Publisher Server is Down
BI Publisher is disabled, to enable BI Publisher on this host, use the 'emctl config oms -enable_bip' command
*/
--stop Agent
[oracle@oem ~]$ export AGENT_HOME=/u01/app/oracle/agent/agent_inst
[oracle@oem ~]$ /u01/app/oracle/agent/agent_inst/bin/emctl stop agent
/*
Oracle Enterprise Manager Cloud Control 13c Release 5
Copyright (c) 1996, 2021 Oracle Corporation.  All rights reserved.
Starting agent ............................ stopped.
*/


--start oms
[oracle@oemserver ~]$ /u01/app/oracle/middleware/bin/emctl start oms
/*
Oracle Enterprise Manager Cloud Control 13c Release 5
Copyright (c) 1996, 2021 Oracle Corporation.  All rights reserved.
Starting Oracle Management Server...
WebTier Successfully Started
Oracle Management Server Successfully Started
Oracle Management Server is Up
JVMD Engine is Up.
*/

--start agent
[oracle@oemserver ~]$ /u01/app/oracle/agent/agent_inst/bin/emctl start agent
/*
Oracle Enterprise Manager Cloud Control 13c Release 5
Copyright (c) 1996, 2021 Oracle Corporation.  All rights reserved.
Starting agent ............................ started.
*/

--check agent up or NOT
[oracle@oemserver ~]$ /u01/app/oracle/agent/agent_inst/bin/emctl status agent shows
/*
Oracle Enterprise Manager Cloud Control 13c Release 5
Copyright (c) 1996, 2021 Oracle Corporation.  All rights reserved.
Agent is already running
[oracle@oemserver ~]$ cd /u01/app/oracle/agent/
[oracle@oemserver agent]$ cd agent_inst/bin/
[oracle@oemserver bin]$ ./emctl status agent shows
Oracle Enterprise Manager Cloud Control 13c Release 5
Copyright (c) 1996, 2021 Oracle Corporation.  All rights reserved.
---------------------------------------------------------------
Agent Version          : 13.5.0.0.0
OMS Version            : 13.5.0.0.0
Protocol Version       : 12.1.0.1.0
Agent Home             : /u01/app/oracle/agent/agent_inst
Agent Log Directory    : /u01/app/oracle/agent/agent_inst/sysman/log
Agent Binaries         : /u01/app/oracle/agent/agent_13.5.0.0.0
Core JAR Location      : /u01/app/oracle/agent/agent_13.5.0.0.0/jlib
Agent Process ID       : 3178
Parent Process ID      : 2589
Agent URL              : https://oemserver.com.np:3872/emd/main/
Local Agent URL in NAT : https://oemserver.com.np:3872/emd/main/
Repository URL         : https://oemserver.com.np:4903/empbs/upload
Started at             : 2023-04-18 09:42:39
Started by user        : oracle
Operating System       : Linux version 5.4.17-2136.317.5.5.el7uek.x86_64 (amd64)
Number of Targets      : 38
Last Reload            : (none)
Last successful upload                       : 2023-04-18 12:27:30
Last attempted upload                        : 2023-04-18 13:05:51
Total Megabytes of XML files uploaded so far : 0.42
Number of XML files pending upload           : 64
Size of XML files pending upload(MB)         : 0.1
Available disk space on upload filesystem    : 52.82%
Collection Status                            : Collections enabled
Heartbeat Status                             : OMS is unreachable
Last attempted heartbeat to OMS              : 2023-04-18 13:05:29
Last successful heartbeat to OMS             : 2023-04-18 12:42:02
Next scheduled heartbeat to OMS              : 2023-04-18 13:05:59

---------------------------------------------------------------
Agent is Running and Ready
*/

--create user dbsnmp and unlocked this user.
 ALTER USER DBSNMP IDENTIFIED BY dbsnmp account unlock;

--ADUMP Cleanup,we use OS command find to search for candidates older than 7 days and delete them subsequently. For example

SELECT SID, SERIAL#, STATUS, SERVER
FROM V$SESSION
WHERE USERNAME = 'HR';

-- add agent on ORACLE RAC 11 GETBND
 [oracle@RAC1 ~]$ mkdir -p /opt/app/oracle/agent/agent13c
 [oracle@RAC2 ~]$ mkdir -p /opt/app/oracle/agent/agent13c
 
 
 [root@RAC1 ~]# /opt/app/oracle/agent/agent13c/agent_13.5.0.0.0/root.sh

Finished product-specific root actions.
/etc exist

Creating /etc/oragchomelist file...

[root@RAC2 ~]# /opt/app/oracle/agent/agent13c/agent_13.5.0.0.0/root.sh

Finished product-specific root actions.
/etc exist

Creating /etc/oragchomelist file...
 
