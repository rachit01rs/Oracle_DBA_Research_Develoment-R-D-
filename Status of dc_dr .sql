 --check database and instance nameand role 
 SQL> select distinct i.inst_id,i.status,i.instance_name,d.database_role,d.open_mode from gv$instance i,gv$database d;
 
 SQL> select distinct  error from gv$archive_dest_status;
 
 SQL> select * from gv$archive_gap;
 
 --DC
 SQL> select thread#,max(sequence#) from gv$archived_log group by thread#;
 
 --DR
 SQL> select thread#,max(sequence#) from gv$archived_log where applied='YES' group by thread#;
 
 SQL> alter system switch logfile;
 SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;
 SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL DISCONNECT FROM SESSION;
 SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL USING CURRENT LOGFILE DISCONNECT FROM SESSION INSTANCES ALL;
 
 
 SELECT inst_id,process,thread#,sequence#,block#,status from gv$managed_standby;
 