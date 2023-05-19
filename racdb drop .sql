-- drop database in RAC environment 
1 verify instance
[oracle@RAC1 ~]$ srvctl status database -d racdb
/*
Instance racdb1 is running on node rac1
Instance racdb2 is running on node rac2
*/
[oracle@RAC1 bin]$ ./crsctl stat  res -t
/*
--------------------------------------------------------------------------------
NAME           TARGET  STATE        SERVER                   STATE_DETAILS       
--------------------------------------------------------------------------------
Local Resources
--------------------------------------------------------------------------------
ora.DATA.dg
               ONLINE  ONLINE       rac1                                         
               ONLINE  ONLINE       rac2                                         
ora.FRA.dg
               ONLINE  ONLINE       rac1                                         
               ONLINE  ONLINE       rac2                                         
ora.LISTENER.lsnr
               ONLINE  ONLINE       rac1                                         
               ONLINE  ONLINE       rac2                                         
ora.OCR.dg
               ONLINE  ONLINE       rac1                                         
               ONLINE  ONLINE       rac2                                         
ora.asm
               ONLINE  ONLINE       rac1                     Started             
               ONLINE  ONLINE       rac2                     Started             
ora.gsd
               OFFLINE OFFLINE      rac1                                         
               OFFLINE OFFLINE      rac2                                         
ora.net1.network
               ONLINE  ONLINE       rac1                                         
               ONLINE  ONLINE       rac2                                         
ora.ons
               ONLINE  ONLINE       rac1                                         
               ONLINE  ONLINE       rac2                                         
--------------------------------------------------------------------------------
Cluster Resources
--------------------------------------------------------------------------------
ora.LISTENER_SCAN1.lsnr
      1        ONLINE  ONLINE       rac2                                         
ora.LISTENER_SCAN2.lsnr
      1        ONLINE  ONLINE       rac1                                         
ora.LISTENER_SCAN3.lsnr
      1        ONLINE  ONLINE       rac1                                         
ora.cvu
      1        ONLINE  ONLINE       rac1                                         
ora.oc4j
      1        ONLINE  ONLINE       rac1                                         
ora.rac1.vip
      1        ONLINE  ONLINE       rac1                                         
ora.rac2.vip
      1        ONLINE  ONLINE       rac2                                         
ora.racdb.db
      1        OFFLINE OFFLINE                               open   
      2        OFFLINE OFFLINE                               open	  
ora.scan1.vip
      1        ONLINE  ONLINE       rac2                                         
ora.scan2.vip
      1        ONLINE  ONLINE       rac1                                         
ora.scan3.vip
      1        ONLINE  ONLINE       rac1
*/

--stop the entire cluster enviroment 

[oracle@RAC1 ~]$ srvctl stop database -d racdb
/*
Instance racdb1 is not running on node rac1
Instance racdb2 is not running on node rac2
*/

[oracle@RAC1 ~]$ srvctl remove instance -d racdb -i racdb1
/*
Remove instance from the database racdb? (y/[n]) y
*/
[oracle@RAC1 ~]$ srvctl remove instance -d racdb -i racdb2
/*
Remove instance from the database racdb? (y/[n]) y
*/
[oracle@RAC1 ~]$ 
[oracle@RAC1 ~]$ 
[oracle@RAC1 ~]$ srvctl status database -d racdb
/*
Database is not running.
*/
[oracle@RAC1 ~]$ 
[oracle@RAC1 ~]$ 
[oracle@RAC1 ~]$ srvctl remove database -d racdb
/*
Remove the database racdb? (y/[n]) 
*/

oracle@RAC1 ~]$ srvctl status database -d racdb
/*
PRCD-1120 : The resource for database racdb could not be found.
PRCR-1001 : Resource ora.racdb.db does not exist
*/

[oracle@RAC1 ~]$ sqlplus  / as sysdba
/*

SQL*Plus: Release 11.2.0.3.0 Production on Sat Apr 29 14:43:21 2023

Copyright (c) 1982, 2011, Oracle.  All rights reserved.

Connected to an idle instance.

SQL> startup;
ORACLE instance started.

Total System Global Area  546992128 bytes
Fixed Size		    2230192 bytes
Variable Size		  264243280 bytes
Database Buffers	  272629760 bytes
Redo Buffers		    7888896 bytes
Database mounted.
Database opened.
SQL> alter system set cluster_database=false scope=spfile;

System altered.

SQL> alter system set cluster_database_instances=1 scope=spfile;

System altered.

SQL> alter database disable thread 2;
Database altered.

SQL> select thread#, group# from v$log;

   THREAD#     GROUP#
---------- ----------
	 1	    1
	 1	    2
	 2	    3
	 2	    4
	 
SQL> alter database drop logfile group 3;
Database altered.
SQL> alter database drop logfile group 4;

SQL> select thread#, group# from v$log;
   THREAD#     GROUP#
---------- ----------
         1          1
         1          2
		 
SQL> select tablespace_name from dba_data_files where tablespace_name like 'UNDOTBS%';

TABLESPACE_NAME
------------------------------
UNDOTBS1
UNDOTBS2

SQL> drop tablespace UNDOTBS2 including contents and datafiles;
Tablespace dropped.

SQL> select tablespace_name from dba_data_files where tablespace_name like 'UNDOTBS%';

TABLESPACE_NAME
------------------------------
UNDOTBS1

SQL> create pfile from spfile;

File created.

SQL> shut immediate;
Database closed.
Database dismounted.
ORACLE instance shut down.
SQL> startup mount restrict
ORACLE instance started.

Total System Global Area  546992128 bytes
Fixed Size                  2230192 bytes
Variable Size             314574928 bytes
Database Buffers          222298112 bytes
Redo Buffers                7888896 bytes
Database mounted.
SQL> drop database;
Disconnected from Oracle Database 11g Enterprise Edition Release 11.2.0.3.0 - 64bit Production
With the Partitioning, Real Application Clusters, Automatic Storage Management, OLAP,
Data Mining and Real Application Testing options

[grid@RAC1 ~]$ asmcmd
ASMCMD> ls
DATA/
FRA/
OCR/
ASMCMD> cd data
ASMCMD> ls
RACDB/
ASMCMD> cd racdb
ASMCMD> ls
PARAMETERFILE/
spfileracdb.ora
ASMCMD> cd parameterfile
ASMCMD> ls
spfile.268.1125333019
ASMCMD> cd ..
ASMCMD> ls
PARAMETERFILE/
spfileracdb.ora
ASMCMD> rm  spfileracdb.ora
ASMCMD> exit
*/

[oracle@RAC1 ~]$ cd /opt/app/oracle/product/11.2.0.3/db_1/dbs
[oracle@RAC1 ~]$# vi initracdb1.ora
/*
SPFILE='+DATA/racdb/spfileracdb.ora'                # line added by Agent
*/


[oracle@RAC1 dbs]$ cd /home/oracle/Documents/
[oracle@RAC1 Documents]$ ls -lrt
total 16
-rw-r----- 1 oracle oinstall   37 Apr 28 15:58 initracdb1.ora
-rw-r----- 1 oracle oinstall 1536 Apr 28 15:58 orapwracdb1
-rw-r----- 1 oracle oinstall   37 Apr 28 15:59 initracdb2.ora
-rw-r----- 1 oracle oinstall 1536 Apr 28 15:59 orapwracdb2



[oracle@RAC1 backup]$ vi spfileracdb.ora
/*
racdb2.__db_cache_size=268435456
racdb1.__db_cache_size=226492416
racdb2.__java_pool_size=4194304
racdb1.__java_pool_size=4194304
racdb2.__large_pool_size=12582912
racdb1.__large_pool_size=12582912
racdb1.__oracle_base='/opt/app/oracle'#ORACLE_BASE set from environment
racdb2.__oracle_base='/opt/app/oracle'#ORACLE_BASE set from environment
racdb2.__pga_aggregate_target=184549376
racdb1.__pga_aggregate_target=184549376
racdb2.__sga_target=549453824
racdb1.__sga_target=549453824
racdb2.__shared_io_pool_size=0
racdb1.__shared_io_pool_size=0
racdb2.__shared_pool_size=251658240
racdb1.__shared_pool_size=293601280
racdb2.__streams_pool_size=0
racdb1.__streams_pool_size=0
*.audit_file_dest='/opt/app/oracle/admin/racdb/adump'
*.audit_trail='NONE'
*.cluster_database=true
*.compatible='11.2.0.0.0'
*.control_files='+DATA/racdb/controlfile/current.260.1125332721','+FRA/racdb/controlfile/current.256.1125332721'#Restore Controlfile
*.db_block_size=8192
*.db_create_file_dest='+DATA'
*.db_domain=''
*.db_name='racdb'
*.db_recovery_file_dest='+FRA'
*.db_recovery_file_dest_size=12884901888
*.diagnostic_dest='/opt/app/oracle'
*.dispatchers='(PROTOCOL=TCP) (SERVICE=racdbXDB)'
racdb2.instance_number=2
racdb1.instance_number=1
*.open_cursors=300
*.pga_aggregate_target=182452224
*.processes=150
*.remote_listener='RAC-scan.mydomain:1521'
*.remote_login_passwordfile='exclusive'
*.sga_target=547356672
racdb2.thread=2
racdb1.thread=1
racdb2.undo_tablespace='UNDOTBS2'
racdb1.undo_tablespace='UNDOTBS1'
*/



[root@RAC1 oracle]# cd /opt/app/oracle/admin/racdb/adump
[root@RAC1 adump]# cd /opt/app/11.2.0.3.0/grid/rdbms/audit/
[root@RAC1 adump]# rm -rf *.aud
[root@RAC1 audit]# rm -rf *.aud
[root@RAC1 audit]# cd /opt/app/oracle/product/11.2.0.3.0/db_1/rdbms/audit/
[root@RAC1 audit]# rm -rf *.aud
[root@RAC1 audit]#  cd /opt/app/oracle/diag/rdbms/racdb/racdb2/trace/
[root@RAC1 trace]# rm -rf *


[root@RAC2 oracle]# cd /opt/app/oracle/admin/racdb/adump
[root@RAC2 adump]# rm -rf *.aud
[root@RAC2 adump]# cd /opt/app/11.2.0.3.0/grid/rdbms/audit/
[root@RAC2 audit]# rm -rf *.aud
[root@RAC2 audit]# cd /opt/app/oracle/product/11.2.0.3.0/db_1/rdbms/audit/
[root@RAC2 audit]# rm -rf *.aud
[root@RAC2 audit]#  cd /opt/app/oracle/diag/rdbms/racdb/racdb2/trace/
[root@RAC2 trace]# rm -rf *

[root@RAC1 bin]# ./crsctl check cluster -all
/*
**************************************************************
rac1:
CRS-4537: Cluster Ready Services is online
CRS-4529: Cluster Synchronization Services is online
CRS-4533: Event Manager is online
**************************************************************
rac2:
CRS-4537: Cluster Ready Services is online
CRS-4529: Cluster Synchronization Services is online
CRS-4533: Event Manager is online
**************************************************************
[root@RAC1 bin]#
*/

/*
[root@RAC2 ~]# cd /opt/app/11.2.0.3.0/grid/bin/
[root@RAC2 bin]#  ./crsctl check cluster -all
**************************************************************
rac1:
CRS-4537: Cluster Ready Services is online
CRS-4529: Cluster Synchronization Services is online
CRS-4533: Event Manager is online
**************************************************************
rac2:
CRS-4537: Cluster Ready Services is online
CRS-4529: Cluster Synchronization Services is online
CRS-4533: Event Manager is online
**************************************************************
[root@RAC2 bin]#
*/

[oracle@RAC1 ~]$ srvctl status listener -l listener

/*Listener LISTENER is enabled
Listener LISTENER is running on node(s): rac2,rac1
*/

[oracle@RAC2 ~]$ srvctl status listener -l listener
/*
Listener LISTENER is enabled
Listener LISTENER is running on node(s): rac2,rac1
*/

[oracle@RAC1 backup]$ sqlplus / as sysdba
/*

SQL*Plus: Release 11.2.0.3.0 Production on Sun Apr 30 14:44:15 2023

Copyright (c) 1982, 2011, Oracle.  All rights reserved.

Connected to an idle instance.

SQL> startup nomount pfile='/home/oracle/backup/spfileracdb.ora';
ORACLE instance started.

Total System Global Area  546992128 bytes
Fixed Size                  2230192 bytes
Variable Size             310380624 bytes
Database Buffers          226492416 bytes
Redo Buffers                7888896 bytes
SQL>  create SPFILE='+DATA/racdb/spfileracdb.ora' from pfile='/home/oracle/backup/spfileracdb.ora';

File created.

SQL>
SQL> shut immediate;
ORA-01507: database not mounted


ORACLE instance shut down.
SQL> startup nomount;
ORACLE instance started.

Total System Global Area  546992128 bytes
Fixed Size                  2230192 bytes
Variable Size             310380624 bytes
Database Buffers          226492416 bytes
Redo Buffers                7888896 bytes

SQL> sho parameter pfile;

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
spfile                               string      +DATA/racdb/spfileracdb.ora
SQL>

*/

SQL> !ps -ef | grep pmon;
/*
grid      4291     1  0 15:46 ?        00:00:01 asm_pmon_+ASM1
oracle    5721     1  0 16:09 ?        00:00:02 ora_pmon_racdb1
oracle    6403  5569  0 16:37 pts/0    00:00:00 /bin/bash -c ps -ef | grep pmon
oracle    6405  6403  0 16:37 pts/0    00:00:00 grep pmon

*/

[oracle@RAC1 ~]$ rman target /
/*

Recovery Manager: Release 11.2.0.3.0 - Production on Sun Apr 30 16:38:53 2023

Copyright (c) 1982, 2011, Oracle and/or its affiliates.  All rights reserved.

connected to target database: RACDB (not mounted)

RMAN> restore controlfile from '+fra/racdb/CONTROLFILE/Backup.296.1135500655';

Starting restore at 30-APR-23
using target database control file instead of recovery catalog
allocated channel: ORA_DISK_1
channel ORA_DISK_1: SID=194 instance=racdb1 device type=DISK

channel ORA_DISK_1: copied control file copy
output file name=+DATA/racdb/controlfile/current.260.1135529073
output file name=+FRA/racdb/controlfile/current.256.1135529083
Finished restore at 30-APR-23

RMAN>  sql 'alter database mount';

sql statement: alter database mount
released channel: ORA_DISK_1

RMAN> catalog start with '+FRA/racdb/';

Starting implicit crosscheck backup at 30-APR-23
allocated channel: ORA_DISK_1
Crosschecked 13 objects
Finished implicit crosscheck backup at 30-APR-23

Starting implicit crosscheck copy at 30-APR-23
using channel ORA_DISK_1
Crosschecked 4 objects
Finished implicit crosscheck copy at 30-APR-23

searching for all files in the recovery area
cataloging files...
cataloging done

List of Cataloged Files
=======================
File Name: +fra/RACDB/BACKUPSET/2023_04_30/nnsnf0_TAG20230430T085211_0.297.1135500733
File Name: +fra/RACDB/ARCHIVELOG/2023_04_30/thread_1_seq_2.298.1135507863
File Name: +fra/RACDB/ARCHIVELOG/2023_04_30/thread_1_seq_3.299.1135507867
File Name: +fra/RACDB/ARCHIVELOG/2023_04_30/thread_1_seq_4.300.1135507869
File Name: +fra/RACDB/ARCHIVELOG/2023_04_30/thread_2_seq_2.301.1135507877
File Name: +fra/RACDB/ARCHIVELOG/2023_04_30/thread_1_seq_5.302.1135507877
File Name: +fra/RACDB/ARCHIVELOG/2023_04_30/thread_2_seq_3.303.1135512825
File Name: +fra/RACDB/CONTROLFILE/Backup.296.1135500655

searching for all files that match the pattern +FRA/racdb/
no files found to be unknown to the database

RMAN> restore database;

Starting restore at 30-APR-23
using channel ORA_DISK_1

channel ORA_DISK_1: starting datafile backup set restore
channel ORA_DISK_1: specifying datafile(s) to restore from backup set
channel ORA_DISK_1: restoring datafile 00001 to +DATA/racdb/datafile/system.256.1125332569
channel ORA_DISK_1: restoring datafile 00002 to +DATA/racdb/datafile/sysaux.257.1125332569
channel ORA_DISK_1: restoring datafile 00003 to +DATA/racdb/datafile/undotbs1.258.1125332571
channel ORA_DISK_1: restoring datafile 00004 to +DATA/racdb/datafile/users.259.1125332571
channel ORA_DISK_1: restoring datafile 00005 to +DATA/racdb/datafile/example.264.1125332757
channel ORA_DISK_1: restoring datafile 00006 to +DATA/racdb/datafile/undotbs2.265.1125332935
channel ORA_DISK_1: reading from backup piece +FRA/racdb/backupset/2023_04_30/nnndf0_tag20230430t082345_0.291.1135499211
channel ORA_DISK_1: piece handle=+FRA/racdb/backupset/2023_04_30/nnndf0_tag20230430t082345_0.291.1135499211 tag=TAG20230430T082345
channel ORA_DISK_1: restored backup piece 1
channel ORA_DISK_1: restore complete, elapsed time: 00:14:27
Finished restore at 30-APR-23

RMAN> recover database;

Starting recover at 30-APR-23
using channel ORA_DISK_1

starting media recovery

archived log for thread 1 with sequence 1 is already on disk as file +FRA/racdb/archivelog/2023_04_30/thread_1_seq_1.293.1135500205
archived log for thread 1 with sequence 2 is already on disk as file +FRA/racdb/archivelog/2023_04_30/thread_1_seq_2.298.1135507863
archived log for thread 1 with sequence 3 is already on disk as file +FRA/racdb/archivelog/2023_04_30/thread_1_seq_3.299.1135507867
archived log for thread 1 with sequence 4 is already on disk as file +FRA/racdb/archivelog/2023_04_30/thread_1_seq_4.300.1135507869
archived log for thread 1 with sequence 5 is already on disk as file +FRA/racdb/archivelog/2023_04_30/thread_1_seq_5.302.1135507877
archived log for thread 2 with sequence 2 is already on disk as file +FRA/racdb/archivelog/2023_04_30/thread_2_seq_2.301.1135507877
archived log for thread 2 with sequence 3 is already on disk as file +FRA/racdb/archivelog/2023_04_30/thread_2_seq_3.303.1135512825
archived log file name=+FRA/racdb/archivelog/2023_04_30/thread_1_seq_1.293.1135500205 thread=1 sequence=1
archived log file name=+FRA/racdb/archivelog/2023_04_30/thread_1_seq_2.298.1135507863 thread=1 sequence=2
archived log file name=+FRA/racdb/archivelog/2023_04_30/thread_1_seq_3.299.1135507867 thread=1 sequence=3
archived log file name=+FRA/racdb/archivelog/2023_04_30/thread_1_seq_4.300.1135507869 thread=1 sequence=4
archived log file name=+FRA/racdb/archivelog/2023_04_30/thread_2_seq_2.301.1135507877 thread=2 sequence=2
archived log file name=+FRA/racdb/archivelog/2023_04_30/thread_1_seq_5.302.1135507877 thread=1 sequence=5
archived log file name=+FRA/racdb/archivelog/2023_04_30/thread_2_seq_3.303.1135512825 thread=2 sequence=3
unable to find archived log
archived log thread=1 sequence=6
RMAN-00571: ===========================================================
RMAN-00569: =============== ERROR MESSAGE STACK FOLLOWS ===============
RMAN-00571: ===========================================================
RMAN-03002: failure of recover command at 04/30/2023 17:27:31
RMAN-06054: media recovery requesting unknown archived log for thread 1 with sequence 6 and starting SCN of 2166691

RMAN> alter database open resetlogs;

*/

SQL> SELECT sid, serial#, context, sofar, totalwork,
 round(sofar/totalwork*100,2) "% Complete"
 FROM v$session_longops
 WHERE opname LIKE 'RMAN%'
 AND opname NOT LIKE '%aggregate%'
 AND totalwork != 0
 AND sofar != totalwork;  2    3    4    5    6    7

no rows selected

SQL> select status, instance_name from gv$instance;
/*
STATUS       INSTANCE_NAME
------------ ----------------
OPEN         racdb1
*/
SQL> exit
Disconnected from Oracle Database 11g Enterprise Edition Release 11.2.0.3.0 - 64bit Production
With the Partitioning, Real Application Clusters, Automatic Storage Management, OLAP,
Data Mining and Real Application Testing options

[oracle@RAC1 ~]$ which srvctl
/*
/opt/app/oracle/product/11.2.0.3.0/db_1/bin/srvctl
*/
[oracle@RAC1 ~]$ srvctl add database -d racdb -o /opt/app/oracle/product/11.2.0.3.0/db_1
[oracle@RAC1 ~]$ srvctl config database -d racdb -a
/*
Database unique name: racdb
Database name:
Oracle home: /opt/app/oracle/product/11.2.0.3.0/db_1
Oracle user: oracle
Spfile:
Domain:
Start options: open
Stop options: immediate
Database role: PRIMARY
Management policy: AUTOMATIC
Server pools: racdb
Database instances:
Disk Groups:
Mount point paths:
Services:
Type: RAC
Database is enabled
Database is administrator managed
*/
[oracle@RAC1 ~]$ srvctl add instance -d racdb -i racdb1 -n RAC1
[oracle@RAC1 ~]$ srvctl add instance -d racdb -i racdb2 -n RAC1

[oracle@RAC1 ~]$ srvctl config database -d racdb -a
/*
Database unique name: racdb
Database name:
Oracle home: /opt/app/oracle/product/11.2.0.3.0/db_1
Oracle user: oracle
Spfile:
Domain:
Start options: open
Stop options: immediate
Database role: PRIMARY
Management policy: AUTOMATIC
Server pools: racdb
Database instances:racdb1,racdb2
Disk Groups:
Mount point paths:
Services:
Type: RAC
Database is enabled
Database is administrator managed
*/

[oracle@RAC1 ~]$ srvctl status database -d racdb
/*
Instance racdb1 is not running on node rac1
Instance racdb2 is not running on node rac2
*/
[oracle@DB-RAC1 ~]$ srvctl config database -d racdb -a
/*
Database unique name: racdb
Database name: 
Oracle home: /opt/app/oracle/product/11.2.0.3/db_1
Oracle user: oracle
Spfile: 
Domain: 
Start options: open
Stop options: immediate
Database role: PRIMARY
Management policy: AUTOMATIC
Server pools: racdb
Database instances: racdb1,racdb2
Disk Groups: 
Mount point paths: 
Services: 
Type: RAC
Database is enabled
Database is administrator managed
*/

[oracle@RAC1 ~]$ srvctl stop database -d racdb
[oracle@RAC1 ~]$ srvctl status database -d racdb

/*
Instance racdb1 is not running on node RAC1
Instance racdb2 is not running on node RAC2
*/


[oracle@RAC1 ~]$ srvctl config database -d racdb -a
/*
Database unique name: racdb
Database name: 
Oracle home: /opt/app/oracle/product/11.2.0.3/db_1
Oracle user: oracle
Spfile: 
Domain: 
Start options: open
Stop options: immediate
Database role: PRIMARY
Management policy: AUTOMATIC
Server pools: racdb
Database instances: racdb1,racdb2
Disk Groups: 
Mount point paths: 
Services: 
Type: RAC
Database is enabled
Database is administrator managed
*/

[oracle@RAC1 ~]$ srvctl modify database -d racdb -a "DATA,FRA"
[oracle@RAC1 ~]$ srvctl config database -d racdb -a
/*
Database unique name: racdb
Database name: 
Oracle home: /opt/app/oracle/product/11.2.0.3/db_1
Oracle user: oracle
Spfile: 
Domain: 
Start options: open
Stop options: immediate
Database role: PRIMARY
Management policy: AUTOMATIC
Server pools: racdb
Database instances: racdb1,racdb2
Disk Groups: DATA,FRA
Mount point paths: 
Services: 
Type: RAC
Database is enabled
Database is administrator managed
*/

[oracle@DB-RAC1 ~]$ srvctl status listener -l listener
/*
Listener LISTENER is enabled
Listener LISTENER is running on node(s): RAC1,RAC2
*/

[oracle@RAC1 ~]$ lsnrctl status
/*
LSNRCTL for Linux: Version 11.2.0.3.0 - Production on 25-MAY-2020 13:36:26
Copyright (c) 1991, 2011, Oracle.  All rights reserved.
Connecting to (ADDRESS=(PROTOCOL=tcp)(HOST=)(PORT=1521))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 11.2.0.3.0 - Production
Start Date                4-MAY-2023 13:29:15
Uptime                    0 days 0 hr. 7 min. 11 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /opt/app/11.2.0.3/grid/network/admin/listener.ora
Listener Log File         /opt/app/oracle/diag/tnslsnr/DB-RAC1/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=LISTENER)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.120.11)(PORT=1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.120.12)(PORT=1521)))
Services Summary...
Service "+ASM" has 1 instance(s).
  Instance "+ASM1", status READY, has 1 handler(s) for this service...
Service "PRIMARY" has 1 instance(s).
  Instance "racdb1", status READY, has 1 handler(s) for this service...
Service "racdbXDB" has 1 instance(s).
  Instance "racdb1", status READY, has 1 handler(s) for this service...
The command completed successfully
*/

[oracle@RAC2 ~]$ srvctl status database -d racdb
/*
Instance racdb1 is running on node RAC1
Instance racdb2 is running on node RAC2
*/
[oracle@DB-RAC2 ~]$ srvctl status listener -l listener
/*
Listener LISTENER is enabled
Listener LISTENER is running on node(s): RAC1,RAC2
*/
[oracle@DB-RAC2 ~]$ lsnrctl status
/*
LSNRCTL for Linux: Version 11.2.0.3.0 - Production on 25-MAY-2020 13:32:51
Copyright (c) 1991, 2011, Oracle.  All rights reserved.
Connecting to (ADDRESS=(PROTOCOL=tcp)(HOST=)(PORT=1521))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 11.2.0.3.0 - Production
Start Date                4-MAY-2023 13:29:19
Uptime                    0 days 0 hr. 3 min. 31 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /opt/app/11.2.0.3/grid/network/admin/listener.ora
Listener Log File         /opt/app/oracle/diag/tnslsnr/DB-RAC2/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=LISTENER)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.120.13)(PORT=1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.120.14)(PORT=1521)))
Services Summary...
Service "+ASM" has 1 instance(s).
  Instance "+ASM2", status READY, has 1 handler(s) for this service...
Service "PRIMARY" has 1 instance(s).
  Instance "racdb2", status READY, has 1 handler(s) for this service...
Service "racdbXDB" has 1 instance(s).
  Instance "racdb2", status READY, has 1 handler(s) for this service...
The command completed successfully
*/

[oracle@RAC1/RAC2 ~]$ vi /opt/app/oracle/product/11.2.0.3/db_1/network/admin/tnsnames.ora
/*
racdb =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = RAC-scan.mydomain.com)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = racdb)
    )
  )
*/



[oracle@RAC1/RAC2 ~]$ tnsping racdb

/*
TNS Ping Utility for Linux: Version 11.2.0.3.0 - Production on 22-JUN-2020 10:41:56
Copyright (c) 1997, 2011, Oracle.  All rights reserved.
Used parameter files:
Used TNSNAMES adapter to resolve the alias
Attempting to contact (DESCRIPTION = (ADDRESS = (PROTOCOL = TCP)(HOST = RAC-scan.mydomain.com)(PORT = 1521)) (CONNECT_DATA = (SERVER = DEDICATED) (SERVICE_NAME = racdb)))
OK (0 msec)
*/