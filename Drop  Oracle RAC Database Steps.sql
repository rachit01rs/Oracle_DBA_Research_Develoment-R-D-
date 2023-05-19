--Drop a Oracle RAC Database
1.Verify the instance

srvctl status database -d  racdb
/*
Instance racdb1 is running on node rac1
Instance racdb2 is running on node rac2
*/

[grid@RAC1 bin]$ ./crsctl status res -t

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
ora.cvu
      1        ONLINE  ONLINE       rac1
ora.oc4j
      1        ONLINE  ONLINE       rac1
ora.rac1.vip
      1        ONLINE  ONLINE       rac1
ora.rac2.vip
      1        ONLINE  ONLINE       rac2
ora.racdb.db
      1        ONLINE  ONLINE       rac1                     Open
      2        ONLINE  ONLINE       rac2                     Open
ora.scan1.vip
      1        ONLINE  ONLINE       rac2
ora.scan2.vip
      1        ONLINE  ONLINE       rac1
*/
2. Stop the entire cluster environment

[oracle@RAC1 ~]$ srvctl stop database -d racdb
[oracle@RAC1 ~]$ srvctl status database -d racdb
/*
Instance racdb1 is not running on node rac1
Instance racdb2 is not running on node rac2
*/
3.update OCR
[oracle@RAC1 ~]$ srvctl remove instance -d racdb -i racdb1
/*
Remove instance from the database racdb? (y/[n]) y
*/
[oracle@RAC1 ~]$ srvctl remove instance -d racdb -i racdb2
/*
Remove instance from the database racdb? (y/[n]) y
*/
[oracle@RAC1 ~]$ srvctl status database -d racdb
/*
Database is not running.
*/
[oracle@RAC1 ~]$ srvctl remove database -d racdb
/*
Remove the database racdb? (y/[n]) y
*/

4. Start only one instance to edit the cluster_database parameter to FALSE/

[oracle@RAC1 ~]$ sqlplus / as sysdba
SQL> startup;
/*
SQL*Plus: Release 11.2.0.3.0 Production on Wed Apr 26 10:43:58 2023

Copyright (c) 1982, 2011, Oracle.  All rights reserved.

Connected to an idle instance.

SQL> startup;
ORACLE instance started.

Total System Global Area 1553305600 bytes
Fixed Size                  2228664 bytes
Variable Size            1056968264 bytes
Database Buffers          486539264 bytes
Redo Buffers                7569408 bytes
Database mounted.
*/

SQL> select instance_name from v$instance;
/*
INSTANCE_NAME
----------------
racdb1
*/
SQL> sho parameter cluster_data;
/*
NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
cluster_database                     boolean     TRUE
cluster_database_instances           integer     2
*/

SQL>alter system set cluster_database=FALSE scope=spfile;
SQL>alter system set cluster_database_instances=1 scope=spfile;
SQL>alter database disable thread 2;


--Delete the unwanted thread and redo logfiles. Thread 1 is for active instance and other is for another instance. 
--Drop all redo group of other thread. Ex: Group 4,5,6 are for other thread then drop as follows.
SQL> select thread#, group# from v$log;
/*
THREAD#     GROUP#
---------- ----------
         1          1
         1          2
         2          3
         2          4

*/

SQL> alter database drop logfile group 3;

SQL> alter database drop logfile group 4;

SQL> select thread#, group# from v$log;

/*
   THREAD#     GROUP#
---------- ----------
         1          1
         1          2

*/




-- Drop the unwanted undo tablespace
SQL> select tablespace_name from dba_data_files where tablespace_name like 'UNDOTBS%';

/*
TABLESPACE_NAME
------------------------------
UNDOTBS1
UNDOTBS2
*/
SQL> drop tablespace UNDOTBS2 including contents and datafiles;
SQL> create pfile from spfile;

5. Mount the first instance in restrict mode and drop the database.

SQL> shutdown immediate
ORA-01109: database not open
Database dismounted.
ORACLE instance shut down.
SQL> startup mount restrict ;
ORACLE instance started.
Total System Global Area  524288000 bytes
Fixed Size                  2926320 bytes
Variable Size             415238416 bytes
Database Buffers          100663296 bytes
Redo Buffers                5459968 bytes
Database mounted.
SQL> show parameter cluster_data

/*
NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
cluster_database                     boolean     FALSE
cluster_database_instances           integer     1

*/
SQL>  select logins,parallel from v$instance;
/*
LOGINS     PAR
---------- ---
RESTRICTED NO
*/


SQL> drop database;
Database dropped.

Disconnected from Oracle Database 11g Enterprise Edition Release 11.2.0.3.0 - 64bit Production
With the Partitioning, Real Application Clusters, Automatic Storage Management, OLAP,
Data Mining and Real Application Testing options


6. Verify the instance
[oracle@RAC1 ~]$ srvctl status database -d racdb

/*
PRCD-1120 : The resource for database racdb could not be found.
PRCR-1001 : Resource ora.racdb.db does not exist
*/

7.Now verify the files after drop database  

[oracle@RAC1 ~]$ su grid
Password:
ASMCMD> cd 2022_12_29
ASMCMD> ls
thread_1_seq_3.262.1124706979
thread_2_seq_1.261.1124706833
ASMCMD> cd ..
ASMCMD> pwd
+fra/racdb/ARCHIVELOG
rm thread*
You may delete multiple files and/or directories.
Are you sure? (y/n) yes

ASMCMD> pwd
+fra/racdb/ARCHIVELOG/2023_04_25
ASMCMD>
ASMCMD> rm thread*
You may delete multiple files and/or directories.
Are you sure? (y/n) yes
SMCMD> cd +fra/racdb/archivelog/
ASMCMD> ls
2023_04_26/
ASMCMD> cd 2023_04_26
ASMCMD> ls
thread_1_seq_178.326.1135157975
thread_1_seq_179.440.1135160661
thread_1_seq_180.438.1135161641
thread_1_seq_181.452.1135162807
thread_2_seq_168.449.1135160661
thread_2_seq_169.437.1135162803
thread_2_seq_170.450.1135162805
thread_2_seq_171.451.1135162805
ASMCMD> rm thread*
You may delete multiple files and/or directories.
Are you sure? (y/n) y



7. To drop the database including the backup, we can go for the below option

RMAN> DROP DATABASE INCLUDING BACKUPS NOPROMPT;


--Below is the SQL query to find ASM diskgroup size in a database which includes Name, Total_GB, Free_GB, Used_GB and Free_percentage of the disk.
select NAME,TOTAL_MB/(1024) TOTAL_GB,FREE_MB/1024 FREE_GB,(TOTAL_MB-FREE_MB)/1024 USED_GB,(FREE_MB/TOTAL_MB)*100 FREE_PER from v$asm_diskgroup;