DROP DIRECTORY  DIR_NAME;
create or replace directory data_pump AS '/home/oracle/data_pump';
grant create any directory TO OE;
grant read,write on directory data_pump to public;

SELECT * FROM DBA_DIRECTORIES WHERE DIRECTORY_NAME = 'DIR_NAME';
/*
owner directory_name directory_path origin_con_id
SYS   DIR_NAME       /home/oracle/              3

*/


create user oe_dup identified by Nepal977 default tablespace users quota unlimited on users;

grant connect,resource to oe_dup;


 select * from dba_users where username like 'OE%';

/*
username user_id password account_status lock_date expiry_date         default_tablespace temporary_tablespace local_temp_tablespace created             profile initial_rsrc_consumer_group external_name password_versions editions_enabled authentication_type proxy_only_connect common last_login                     oracle_maintained inherited default_collation implicit all_shard password_change_date
OE_DUP       146          OPEN                     02.10.2023 07:57:50 USERS              TEMP                 TEMP                  05.04.2023 07:57:50 DEFAULT DEFAULT_CONSUMER_GROUP                    11G 12C           N                PASSWORD            N                  NO                                    N                 NO        USING_NLS_COMP    NO       NO        05.04.2023 07:57:50
OE           107          OPEN                     31.08.2023 11:12:25 USERS              TEMP                 TEMP                  04.03.2023 11:12:25 DEFAULT DEFAULT_CONSUMER_GROUP                    11G 12C           N                PASSWORD            N                  NO     05.04.2023 08:09:15.000 +05:45 N                 NO        USING_NLS_COMP    NO       NO        04.03.2023 11:12:25

*/
SELECT * FROM dba_ts_quotas WHERE username LIKE 'OE%';
/*
tablespace_name username    bytes max_bytes blocks max_blocks dropped
USERS           OE       10485760        -1   1280         -1 NO
USERS           OE_DUP          0        -1      0         -1 NO
*/


SELECT Count(*) "Count",owner,status FROM dba_objects WHERE owner LIKE  'OE%' GROUP BY owner,status;
/*
COUNT owner status
       142 OE    VALID

*/

expdp " '/ as sysdba' " schemas=OE DIRECTORY=DIR_NAME DUMPFILE=oe_05_04_2023.dmp LOGFILE=oe_05_04_2023.Log CONTENT=METADATA_ONLY;

expdp sys/Adminrabin1@orclpdb schemas=OE directory=DIR_NAME  dumpfile=OE_%T_%L.dmp logfile=expdpOE.log parallel=4