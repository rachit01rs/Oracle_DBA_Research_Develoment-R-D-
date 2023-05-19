------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------Start Two Nodes DR Drill Testing------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------

Snapshot Standby
Snapshot standby allows the standby database to be opened in read-write mode. 
When switched back into standby mode, all changes made whilst in read-write mode are lost. 
This is achieved using flashback database, but the standby database does not need to have flashback database
explicitly enabled to take advantage of this feature, thought it works just the same if it is.

Note: If you are using RAC1/RAC1DR, then turn off all RAC1DR db instance but one of the RAC1DR db instances should be UP and running in MOUNT mode.

-------------------------------------------------------------------------------------------------------------------------------------
------------------------Start the Process from physical standby database to snapshot standby database--------------------------------
-------------------------------------------------------------------------------------------------------------------------------------

-- Step 1
-- Verify the DB instance status of Primary Database -> DC
[oracle@RAC1 ~]$ srvctl status database -d racdb -v
/*
Instance racdb1 is running on node rac1. Instance status: Open.
Instance racdb2 is running on node rac2. Instance status: Open.

*/
-- Step 2
-- Verify the DB instance status of Primary Database -> DC
SQL> SELECT a.inst_id,b.status,b.instance_name,a.database_role,a.open_mode FROM gv$database a,gv$instance b WHERE a.inst_id=b.inst_id;
/*
  INST_ID STATUS       INSTANCE_NAME    DATABASE_ROLE    OPEN_MODE
---------- ------------ ---------------- ---------------- --------------------
         1 OPEN         racdb1           PRIMARY          READ WRITE
         2 OPEN         racdb2           PRIMARY          READ WRITE

*/

-- Step 3
-- Genrate the Archive Log -> DC
SQL> ALTER SYSTEM SWITCH LOGFILE;

-- Step 4
-- Verify the currect archive of Primary Database -> DC
-- Step 4.1 (Check the archive log Status) -> DC
SQL> SELECT first_time,next_time,archived,applied,sequence#,thread# FROM v$archived_log ORDER BY sequence#;
/*
FIRST_TIM NEXT_TIME ARC APPLIED    SEQUENCE#    THREAD#
--------- --------- --- --------- ---------- ----------
16-MAY-23 16-MAY-23 YES YES              376          1
16-MAY-23 16-MAY-23 YES NO               377          1
16-MAY-23 16-MAY-23 YES YES              377          1
16-MAY-23 16-MAY-23 YES NO               378          1
16-MAY-23 16-MAY-23 YES NO               378          1
*/
-- Step 4.2 (Check the archive log Generated Status) -> DC
SQL> SELECT MAX(sequence#), thread# FROM gv$archived_log GROUP BY thread#;

/*
MAX(SEQUENCE#)    THREAD#
-------------- ----------
           378          1
           188          2
*/

-- Step 5
-- Verify the DB instance status of Secondary Database -> DR
[oracle@RAC1DR ~]$  srvctl status database -d racdr -v
/*
Instance racdb1 is running on node rac1dr. Instance status: Mounted (Closed).
Instance racdb2 is running on node rac2dr. Instance status: Mounted (Closed).
*/

-- Step 6
-- Verify the DB instance status of Secondary Database -> DR
SQL> SELECT a.inst_id,b.status,b.instance_name,a.database_role,a.open_mode FROM gv$database a,gv$instance b WHERE a.inst_id=b.inst_id;
/*
 INST_ID STATUS       INSTANCE_NAME    DATABASE_ROLE    OPEN_MODE
---------- ------------ ---------------- ---------------- --------------------
         1 MOUNTED      racdb1           PHYSICAL STANDBY MOUNTED
         2 MOUNTED      racdb2           PHYSICAL STANDBY MOUNTED
*/

-- Step 7
-- Verify the DB instance status of Secondary Database -> DR
-- Step 7.1 (Check the archive log Status) -> DR
SQL> SELECT first_time,next_time,archived,applied,sequence#,thread# FROM v$archived_log ORDER BY sequence#;

/*
FIRST_TIM NEXT_TIME ARC APPLIED    SEQUENCE#    THREAD#
--------- --------- --- --------- ---------- ----------
16-MAY-23 16-MAY-23 YES YES              374          1
16-MAY-23 16-MAY-23 YES YES              375          1
16-MAY-23 16-MAY-23 YES YES              376          1
16-MAY-23 16-MAY-23 YES YES              377          1
16-MAY-23 16-MAY-23 YES IN-MEMORY        378          1
*/

-- Step 7.2 (Check the archive log Generated Status) -> DR
SQL> SELECT MAX(sequence#), thread# FROM gv$archived_log GROUP BY thread#;

-- Step 7.3 (Check the archive log Applied Status) -> DR
SQL> SELECT MAX(sequence#), thread# FROM gv$archived_log WHERE applied ='YES' GROUP BY thread#;
/*
MAX(SEQUENCE#)    THREAD#
-------------- ----------
           377          1
           188          2

*/

-- Step 7.4 (Check the archive log MRP & Reciving Status) -> DR
SQL> SELECT thread#,sequence#,status,block#,process FROM gv$managed_standby WHERE status IN ('APPLYING_LOG','RECEIVING');
/*
THREAD#  SEQUENCE# STATUS           BLOCK# PROCESS
---------- ---------- ------------ ---------- ---------
         1        379 APPLYING_LOG       1440 MRP0
*/
-- Step 7.5 (Check the error status ) -> DR
SQL> SELECT DISTINCT error FROM gv$archive_dest_status;

-- Step 7.6 (Check the archive log gap Status) -> DR
SQL> SELECT * FROM gv$archive_gap;

-- Step 8
-- Log Differ on DC
SQL> ALTER SYSTEM SET log_archive_dest_state_2=DEFER SID='*';

-- Step 9
-- Log Differ on DR
SQL> ALTER SYSTEM SET log_archive_dest_state_2=DEFER SID='*';


-- Step 10
-- Make sure the db_recovery_file_dest_size and location is set properly -> DR
-- Note The oracle parameter "db_recovery_file_dest_size" should be greater than 5GB -> DR.
-- Step 10.1 (Set the Console Line Size) - DR
SQL> set linesize 9999

-- Step 10.1 (Check the database recovery siz status) - DR
SQL> show parameters db_recovery_file_dest
/*
NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
db_recovery_file_dest                string      +FRA
db_recovery_file_dest_size           big integer 40G

*/

-- Step 11
-- Verify the restore point -> DR
SQL> SELECT inst_id,name,open_mode,flashback_on FROM gv$database;
/*
   INST_ID NAME      OPEN_MODE            FLASHBACK_ON
---------- --------- -------------------- ------------------
         1 RACDB     MOUNTED              NO
         2 RACDB     MOUNTED              NO

*/

-- Step 12
-- Cancel the managed standby recovery process -> DR
SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;
/*
Database altered.
*/

-- Step 13
-- Verify the Current status of Secondary Database -> DR
[oracle@RAC1DR ~]$  srvctl status database -d racdr -v
/*
Instance racdb1 is running on node rac1dr. Instance status: Mounted (Closed).
Instance racdb2 is running on node rac2dr. Instance status: Mounted (Closed).
*/

-- Step 14 To stop the DB services and status of Secondary Database -> DR
[oracle@RAC1DR ~]$$ srvctl stop database -d racdr
[oracle@RAC1DR ~]$$ srvctl status database -d racdr -v
/*
Instance racdb1 is not running on node rac1dr
Instance racdb2 is not running on node rac2dr

*/

-- Step 15
-- To start the DB services for node 1 and it's status of Secondary Database -> DR
[oracle@nplprod1 ~]$ srvctl start instance -d racdr -i racdb1 -o mount
[oracle@nplprod1 ~]$ srvctl status database -d racdr -v
/*
Instance racdb1 is running on node rac1dr. Instance status: Mounted (Closed).
Instance racdb2 is not running on node rac2dr

*/

-- Step 16
-- Verify the DB instance status of Secondary Database -> DR
SQL>  SELECT a.inst_id,b.status,b.instance_name,a.database_role,a.open_mode FROM gv$database a,gv$instance b WHERE a.inst_id=b.inst_id;
/*
  INST_ID STATUS       INSTANCE_NAME    DATABASE_ROLE    OPEN_MODE
---------- ------------ ---------------- ---------------- --------------------
         1 MOUNTED      racdb1           PHYSICAL STANDBY MOUNTED

*/

-- Step 17
-- Covert physical standby database to snapshot standby database -> DR.
SQL> ALTER DATABASE CONVERT TO SNAPSHOT STANDBY;
/*
Database altered.
*/

-- Step 18
-- The physical standby database in snapshot standby database status shoud be in mount mode -> DR
SQL> SELECT a.inst_id,b.status,b.instance_name,a.database_role,a.open_mode FROM gv$database a,gv$instance b WHERE a.inst_id=b.inst_id;
/*
 INST_ID STATUS       INSTANCE_NAME    DATABASE_ROLE    OPEN_MODE
---------- ------------ ---------------- ---------------- --------------------
         1 MOUNTED      racdb1           SNAPSHOT STANDBY MOUNTED

*/

-- Step 19
-- Bring the database in open mode -> DR
SQL> ALTER DATABASE OPEN;
/*
Database altered.
*/

-- Step 20
-- Verify the DB instance status of Secondary Database -> DR
SQL> SELECT a.inst_id,b.status,b.instance_name,a.database_role,a.open_mode FROM gv$database a,gv$instance b WHERE a.inst_id=b.inst_id;
/*
 INST_ID STATUS       INSTANCE_NAME    DATABASE_ROLE    OPEN_MODE
---------- ------------ ---------------- ---------------- --------------------
         1 OPEN         racdb1           SNAPSHOT STANDBY READ WRITE

*/


-- Step 21
-- Verify the restore point of Secondary Database -> DR
SQL> SELECT inst_id,name,open_mode,flashback_on FROM gv$database;
/*
    INST_ID NAME      OPEN_MODE            FLASHBACK_ON
---------- --------- -------------------- ------------------
         1 RACDB     READ WRITE           RESTORE POINT ONLY
*/



-- Step 22
-- Verify the health of Snapshot DR-Drill on Secondary Database -> DR 
-- Step 22.1 (Create a temporary user for testing purpose) -> DR
SQL> CREATE USER snaptest IDENTIFIED BY snaptest;

-- Step 22.2 (Grant to connectivity on temporary user) -> DR
SQL> GRANT CONNECT, RESOURCE TO snaptest;

-- Step 22.3 (Craete a table for testing purpose) -> DR
SQL> CREATE TABLE snaptest.test
     AS
     SELECT
          LEVEL   sn,
          sysdate dates
     FROM dual
     CONNECT BY LEVEL <=5;
/*
Table created

*/


-- Step 22.4 (Verify the table) -> DR
SQL> SELECT * FROM snaptest.test;
/*
        SN DATES
---------- ---------
         1 16-MAY-23
         2 16-MAY-23
         3 16-MAY-23
         4 16-MAY-23
         5 16-MAY-23
*/

-- Step 22.5 (Verify the Archive Log seaping Status) -> DR
SQL> SELECT process,status,sequence# FROM v$managed_standby;

/*
PROCESS   STATUS        SEQUENCE#
--------- ------------ ----------
ARCH      CONNECTED             0
ARCH      CONNECTED             0
ARCH      CONNECTED             0
ARCH      CLOSING               1
ARCH      CONNECTED             0
ARCH      CONNECTED             0
ARCH      CONNECTED             0
ARCH      CONNECTED             0

8 rows selected.
*/
--note:I don't have a database link so, I eliminated these steps.
/*
-- Step 23
-- Verify the recreate the database links on Secondary Database -> DR
-- Step 23.1 (Check the status of database links) -> DR
SQL> select * from dba_db_links;

-- Step 23.2 (Check the status of database links) -> DR
SQL> select 'select * from dual@'||db_link||' ;' from dba_db_links db;

-- Step 23.2.1 (Check the status of database links) -> DR
SQL> select * from dual@CVMASTER1 ;

-- Step 23.2.2 (Check the status of database links) -> DR
SQL> select * from dual@CVMASTERS ;

-- Step 23.2.3 (Check the status of database links) -> DR
SQL> select * from dual@CVSTAGING ;

-- Step 23.2.4 (Check the status of database links) -> DR
SQL> select * from dual@SBADMIN ;

-- Step 23.2.5 (Check the status of database links) -> DR
WITH db_link_status
AS
(
 SELECT 'CVMASTER1' db_link FROM dual@CVMASTER1  UNION ALL
 SELECT 'CVMASTERS' db_link FROM dual@CVMASTERS  UNION ALL
 SELECT 'CVSTAGING' db_link FROM dual@CVSTAGING  UNION ALL
 SELECT 'SBADMIN'   db_link FROM dual@SBADMIN
)
SELECT a.db_link FROM db_link_status a
WHERE EXISTS (SELECT 1 FROM dba_db_links b WHERE a.db_link=b.db_link);

-- Step 23.2.6 (Check the status of database links) -> DR
SELECT
     substr(REGEXP_REPLACE(TRIM(a.db_link),'( ){2,}',' '),1,instr(REGEXP_REPLACE(TRIM(a.db_link),'( ){2,}',' '),' ',1,6))    db_link_name,
     substr(a.db_link,instr(a.db_link,'ADDRESS',-1)) connection_string
FROM (
      SELECT dbms_metadata.get_ddl('DB_LINK',db.db_link,db.owner) db_link FROM dba_db_links db
     ) a;

-- Step 23.3 (Check the password status for database links) -> DR
SQL> select name,value from v$parameter where name ='sec_case_sensitive_logon';

name                     value
------------------------ -------
sec_case_sensitive_logon false


-- Step 23.4 (Drop the existing database links) -> DR
SQL> DROP PUBLIC DATABASE LINK CVMASTER1;
-- Step 23.4.1 (Re-Create the existing database links with DR IP) -> DR
SQL> CREATE PUBLIC DATABASE LINK CVMASTER1
 CONNECT TO CVMASTERS IDENTIFIED BY CVMASTERS
 USING '(DESCRIPTION =
  (ADDRESS_LIST =
    (ADDRESS = (PROTOCOL = TCP)(HOST =172.16.25.11)(PORT = 1521))
  )
  (CONNECT_DATA =
    (SERVICE_NAME = dr)
  )
)';

-- Step 23.5 (Drop the existing database links) -> DR
SQL> DROP PUBLIC DATABASE LINK CVMASTERS;
-- Step 23.5.1 (Re-Create the existing database links with DR IP) -> DR
SQL> CREATE PUBLIC DATABASE LINK CVMASTERS
 CONNECT TO CVMASTERS IDENTIFIED BY CVMASTERS
 USING '(DESCRIPTION =
  (ADDRESS_LIST =
    (ADDRESS = (PROTOCOL = TCP)(HOST =172.16.25.11)(PORT = 1521))
  )
  (CONNECT_DATA =
    (SERVICE_NAME = dr)
  )
)';

-- Step 23.6 (Drop the existing database links) -> DR
SQL> DROP PUBLIC DATABASE LINK CVSTAGING;
-- Step 23.6.1 (Re-Create the existing database links with DR IP) -> DR
SQL> CREATE PUBLIC DATABASE LINK CVSTAGING
 CONNECT TO CVSTAGING IDENTIFIED BY CVSTAGING
 USING '(DESCRIPTION =
  (ADDRESS_LIST =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 172.16.25.11)(PORT = 1521))
  )
  (CONNECT_DATA =
    (SERVICE_NAME = dr)
  )
)';

-- Step 23.7 (Drop the existing database links) -> DR
SQL> DROP PUBLIC DATABASE LINK SBADMIN;
-- Step 23.7.1 (Re-Create the existing database links with DR IP) -> DR
SQL> CREATE PUBLIC DATABASE LINK SBADMIN
 CONNECT TO SBADMIN IDENTIFIED BY SBADMIN
 USING '(DESCRIPTION =
  (ADDRESS_LIST =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 172.16.25.11)(PORT = 1521))
  )
  (CONNECT_DATA =
    (SERVICE_NAME = dr)
  )
)';

*/
-------------------------------------------------------------------------------------------------------------------------------------
--------------------------End the Process from physical standby database to snapshot standby database--------------------------------
-------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------
--------------------------Covert back physical standby database from snapshot standby database---------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------
-- Step 24
-- Covert back physical standby database from snapshot standby database.
-- Verify the DB instance status of Secondary Database -> DR
SQL> SELECT a.inst_id,b.status,b.instance_name,a.database_role,a.open_mode FROM gv$database a,gv$instance b WHERE a.inst_id=b.inst_id;
/*
 INST_ID STATUS       INSTANCE_NAME    DATABASE_ROLE    OPEN_MODE
---------- ------------ ---------------- ---------------- --------------------
         1 OPEN         racdb1           SNAPSHOT STANDBY READ WRITE

*/

-- Step 25
-- Shutdown the DR database -> DR
SQL> shutdown immediate;
/*
Database closed.
Database dismounted.
ORACLE instance shut down.
*/

-- Step 26
-- Bring the database in mount mode -> DR
SQL> startup mount;
/*
ORACLE instance started.

Total System Global Area 1152450560 bytes
Fixed Size                  2227704 bytes
Variable Size             738198024 bytes
Database Buffers          402653184 bytes
Redo Buffers                9371648 bytes
Database mounted.

*/

-- Step 27
-- Covert back physical standby database from snapshot standby database -> DR.
SQL> ALTER DATABASE CONVERT TO PHYSICAL STANDBY;
/*
Database altered.
*/

-- Step 28
-- Shutdown the database -> DR
SQL> shutdown immediate;
/*
ORA-01507: database not mounted


Database dismounted.
ORACLE instance shut down.
*/

-- Step 29
-- Bring the database in nomount mode -> DR
SQL> startup nomount;
/*
ORACLE instance started.

Total System Global Area 1152450560 bytes
Fixed Size                  2227704 bytes
Variable Size             738198024 bytes
Database Buffers          402653184 bytes
Redo Buffers                9371648 bytes

*/

-- Step 30
-- Bring the database in mount mode -> DR
SQL> ALTER DATABASE MOUNT STANDBY DATABASE;
/*
Database altered.
*/

-- Step 31
-- Verify the DB instance status of Secondary Database -> DR
SQL> SELECT a.inst_id,b.status,b.instance_name,a.database_role,a.open_mode FROM gv$database a,gv$instance b WHERE a.inst_id=b.inst_id;
/*
INST_ID STATUS       INSTANCE_NAME    DATABASE_ROLE    OPEN_MODE
---------- ------------ ---------------- ---------------- --------------------
         1 MOUNTED      racdb1           PHYSICAL STANDBY MOUNTED

*/

-- Step 32
-- Verify the DB services status Secondary Database -> DR
[oracle@RAC1DR ~]$ srvctl status database -d racdr -v
/*
Instance racdb1 is running on node rac1dr. Instance status: Mounted (Closed).
Instance racdb2 is not running on node rac2dr
*/


-- Step 33
-- To stop the DB services and status Secondary Database -> DR
[oracle@RAC1DR ~]$ srvctl stop database -d racdr
[oracle@RAC1DR ~]$ srvctl status database -d racdr -v
/*
Instance racdb1 is not running on node rac1dr
Instance racdb2 is not running on node rac2dr

*/

-- Step 34
-- To start the DB services and status Secondary Database -> DR
[oracle@DRCIB-PRD-PDB1 ~]$ srvctl start database -d racdr -o mount
[oracle@DRCIB-PRD-PDB1 ~]$ srvctl status database -d racdr -v
/*
Instance racdb1 is running on node rac1dr. Instance status: Mounted (Closed).
Instance racdb2 is running on node rac2dr. Instance status: Mounted (Closed).
*/

-- Step 35
-- Verify the DB instance status of Secondary Database -> DR
SQL> SELECT a.inst_id,b.status,b.instance_name,a.database_role,a.open_mode FROM gv$database a,gv$instance b WHERE a.inst_id=b.inst_id;
/*
 INST_ID STATUS       INSTANCE_NAME    DATABASE_ROLE    OPEN_MODE
---------- ------------ ---------------- ---------------- --------------------
         1 MOUNTED      racdb1           PHYSICAL STANDBY MOUNTED
         2 MOUNTED      racdb2           PHYSICAL STANDBY MOUNTED

*/

-- Step 36
-- ENABLE the Archive Log Sipping - DC
ALTER SYSTEM SET log_archive_dest_state_2=ENABLE;

-- Step 37
-- ENABLE the Archive Log Sipping - DR
ALTER SYSTEM SET log_archive_dest_state_2=ENABLE;

-- Step 38
-- Verify the archive log Generated Status - Primary Database -> DC
SQL> SELECT MAX(sequence#), thread# FROM gv$archived_log GROUP BY thread#;

-- Step 39
-- Verify the DB instance status of Secondary Database -> DR
-- Step 39.1 (Check the archive log Generated Status) -> DR
SQL> SELECT MAX(sequence#), thread# FROM gv$archived_log GROUP BY thread#;

-- Step 39.2 (Check the archive log Applied Status) -> DR
SQL> SELECT MAX(sequence#), thread# FROM gv$archived_log WHERE applied ='YES' GROUP BY thread#;

-- Step 39.3 (Check the error status ) -> DR
SQL> SELECT DISTINCT error FROM gv$archive_dest_status;

-- Step 39.4 (Check the archive log gap Status) -> DR
SQL> SELECT * FROM gv$archive_gap;

-- Step 39.5 (Check the archive log MRP & Reciving Status) -> DR
SQL> SELECT inst_id,process,thread#,sequence#,block#,status FROM gv$managed_standby;

-- Step 40
-- Start the Recovery Process in Secondary Database -> DR
SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT FROM SESSION;
/*
Database altered.
*/

-- Step 41
-- Verify the DB instance status of Secondary Database -> DR
SQL> SELECT a.inst_id,b.status,b.instance_name,a.database_role,a.open_mode FROM gv$database a,gv$instance b WHERE a.inst_id=b.inst_id;
/*
INST_ID STATUS       INSTANCE_NAME    DATABASE_ROLE    OPEN_MODE
---------- ------------ ---------------- ---------------- --------------------
         1 MOUNTED      racdb1           PHYSICAL STANDBY MOUNTED
         2 MOUNTED      racdb2           PHYSICAL STANDBY MOUNTED
*/

-- Step 42

-- Step 42.1 (Check the archive log Generated Status) -> DR
SQL> SELECT MAX(sequence#), thread# FROM gv$archived_log GROUP BY thread#;

-- Step 42.2 (Check the archive log Applied Status) -> DR
SQL> SELECT MAX(sequence#), thread# FROM gv$archived_log WHERE applied ='YES' GROUP BY thread#;

-- Step 42.3 (Check the error status ) -> DR
SQL> SELECT DISTINCT error FROM gv$archive_dest_status;

-- Step 42.4 (Check the archive log gap Status) -> DR
SQL> SELECT * FROM gv$archive_gap;

-- Step 42.5 (Check the archive log MRP & Reciving Status) -> DR
SQL> SELECT inst_id,process,thread#,sequence#,block#,status FROM gv$managed_standby;
/*
  INST_ID PROCESS      THREAD#  SEQUENCE#     BLOCK# STATUS
---------- --------- ---------- ---------- ---------- ------------
         2 ARCH               0          0          0 CONNECTED
         2 ARCH               0          0          0 CONNECTED
         2 ARCH               0          0          0 CONNECTED
         2 ARCH               0          0          0 CONNECTED
         2 ARCH               2        189      10240 CLOSING
         2 ARCH               0          0          0 CONNECTED
         2 ARCH               0          0          0 CONNECTED
         2 ARCH               0          0          0 CONNECTED
         2 RFS                0          0          0 IDLE
         2 RFS                0          0          0 IDLE
         2 RFS                2        190        362 IDLE

   INST_ID PROCESS      THREAD#  SEQUENCE#     BLOCK# STATUS
---------- --------- ---------- ---------- ---------- ------------
         2 RFS                0          0          0 IDLE
         2 RFS                1        380        402 IDLE
         1 ARCH               1        379      10240 CLOSING
         1 ARCH               0          0          0 CONNECTED
         1 ARCH               0          0          0 CONNECTED
         1 ARCH               0          0          0 CONNECTED
         1 ARCH               0          0          0 CONNECTED
         1 ARCH               0          0          0 CONNECTED
         1 ARCH               0          0          0 CONNECTED
         1 ARCH               0          0          0 CONNECTED
         1 RFS                0          0          0 IDLE

   INST_ID PROCESS      THREAD#  SEQUENCE#     BLOCK# STATUS
---------- --------- ---------- ---------- ---------- ------------
         1 MRP0               1        380        401 APPLYING_LOG

*/

-- Step 43
-- Verify the DB instance status of Primary Database -> DC
SQL> SELECT a.inst_id,b.status,b.instance_name,a.database_role,a.open_mode FROM gv$database a,gv$instance b WHERE a.inst_id=b.inst_id;
/*
 INST_ID STATUS       INSTANCE_NAME    DATABASE_ROLE    OPEN_MODE
---------- ------------ ---------------- ---------------- --------------------
         1 OPEN         racdb1           PRIMARY          READ WRITE
         2 OPEN         racdb2           PRIMARY          READ WRITE

*/

-- Step 44 (Check the archive log Generated Status) -> DC
SQL> SELECT MAX(sequence#), thread# FROM gv$archived_log GROUP BY thread#;


------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------End Two Nodes DR Drill Testing------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------

