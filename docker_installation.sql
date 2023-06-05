
--Install Docker
--Enable all the required repositories
[oracle@myserver ~]# yum install -y yum-utils zip unzip
[oracle@myserver ~]# yum-config-manager --enable ol7_optional_latest ol7_addons

[oracle@myserver ~]# yum install -y oraclelinux-developer-release-el7
[oracle@myserver ~]# yum-config-manager --enable ol7_developer


--Install Docker and BTRFS.

[root@myserver ~]# yum install -y docker-engine btrfs-progs btrfs-progs-devel

--Configure BTRFS
[root@myserver ~]# fdisk /dev/sdd1
/*
Welcome to fdisk (util-linux 2.23.2).

Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table
Building a new DOS disklabel with disk identifier 0x2ccc116e.

Command (m for help): n
Partition type:
   p   primary (0 primary, 0 extended, 4 free)
   e   extended
Select (default p): p
Partition number (1-4, default 1): 
First sector (2048-25165823, default 2048): 
Using default value 2048
Last sector, +sectors or +size{K,M,G} (2048-25165823, default 25165823): 
Using default value 25165823
Partition 1 of type Linux and of size 12 GiB is set

Command (m for help): w
The partition table has been altered!

Calling ioctl() to re-read partition table.
Syncing disks.

*/



[root@myserver ~]# docker-storage-config -s btrfs -d /dev/sdd1
Creating 'btrfs' file system on: /dev/sdd1
[root@myserver ~]# cat /etc/fstab
/*
# /etc/fstab
# Created by anaconda on Fri Mar  3 10:01:15 2023
#
# Accessible filesystems, by reference, are maintained under '/dev/disk'
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
#
/dev/mapper/ol-root     /                       xfs     defaults        0 0
UUID=3e101576-3759-4dde-a1b2-099bdf4fd884 /boot                   xfs     defaults        0 0
/dev/mapper/ol-home     /home                   xfs     defaults        0 0
/dev/mapper/ol-temp     /temp                   xfs     defaults        0 0
/dev/mapper/ol-u01      /u01                    xfs     defaults        0 0
/dev/mapper/ol-var      /var                    xfs     defaults        0 0
/dev/mapper/ol-swap     swap                    swap    defaults        0 0
UUID=3808a369-00c9-4243-b113-cd099ce11e74 /var/lib/docker btrfs defaults 0 0 # added by docker-storage-config

*/


[root@myserver ~]# df -h
Filesystem           Size  Used Avail Use% Mounted on
devtmpfs             1.8G     0  1.8G   0% /dev
tmpfs                1.8G     0  1.8G   0% /dev/shm
tmpfs                1.8G  9.8M  1.8G   1% /run
tmpfs                1.8G     0  1.8G   0% /sys/fs/cgroup
/dev/mapper/ol-root   27G  7.4G   20G  28% /
/dev/sda2            2.0G  481M  1.6G  24% /boot
/dev/mapper/ol-u01    32G   26G  6.5G  80% /u01
/dev/mapper/ol-home  8.0G  6.6G  1.5G  82% /home
/dev/mapper/ol-temp  8.0G   33M  8.0G   1% /temp
/dev/mapper/ol-var   9.0G  3.2G  5.9G  36% /var
tmpfs                365M     0  365M   0% /run/user/54321
tmpfs                365M   24K  365M   1% /run/user/0
/dev/sr0             4.5G  4.5G     0 100% /run/media/root/OL-7.8 Server.x86_64
/dev/sdd1             35G  3.5M   35G   1% /var/lib/docker


--Finish Docker Setup





[root@myserver ~]# systemctl enable docker.service
Created symlink from /etc/systemd/system/multi-user.target.wants/docker.service to /usr/lib/systemd/system/docker.service.
[root@myserver ~]# systemctl start docker.service
[root@myserver ~]# systemctl status docker.service
/*
● docker.service - Docker Application Container Engine
   Loaded: loaded (/usr/lib/systemd/system/docker.service; enabled; vendor preset: disabled)
   Active: active (running) since Mon 2023-06-05 10:31:43 +0545; 41min ago
     Docs: https://docs.docker.com
 Main PID: 7762 (dockerd)
    Tasks: 8
   Memory: 24.6M
   CGroup: /system.slice/docker.service
           └─7762 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
*/

[root@myserver ~]# docker info
/*
Client:
 Debug Mode: false

Server:
 Containers: 0
  Running: 0
  Paused: 0
  Stopped: 0
 Images: 0
 Server Version: 19.03.11-ol
 Storage Driver: btrfs
  Build Version: Btrfs v4.9.1
  Library Version: 102
 Logging Driver: json-file
 Cgroup Driver: cgroupfs
 Plugins:
  Volume: local
  Network: bridge host ipvlan macvlan null overlay
  Log: awslogs fluentd gcplogs gelf journald json-file local logentries splunk syslog
 Swarm: inactive
 Runtimes: runc
 Default Runtime: runc
 Init Binary: docker-init
 containerd version: 7eba5930496d9bbe375fdf71603e610ad737d2b2
 runc version: 5fd4c4d
 init version: fec3683
 Security Options:
  seccomp
   Profile: default
 Kernel Version: 5.4.17-2136.317.5.3.el7uek.x86_64
 Operating System: Oracle Linux Server 7.9
 OSType: linux
 Architecture: x86_64
 CPUs: 2
 Total Memory: 3.556GiB
 Name: myserver.com.np
 ID: NRGM:B7IV:TUXT:G6XN:7XUE:7WK5:UTMD:7XQG:6VPR:2GBI:7HER:BPII
 Docker Root Dir: /var/lib/docker
 Debug Mode: false
 Registry: https://index.docker.io/v1/
 Labels:
 Experimental: false
 Insecure Registries:
  127.0.0.0/8
 Live Restore Enabled: false

Registries:

*/

[root@myserver ~]# docker version
/*
Client: Docker Engine - Community
 Version:           19.03.11-ol
 API version:       1.40
 Go version:        go1.16.2
 Git commit:        9bb540d
 Built:             Fri Jul 23 01:33:55 2021
 OS/Arch:           linux/amd64
 Experimental:      false

Server: Docker Engine - Community
 Engine:
  Version:          19.03.11-ol
  API version:      1.40 (minimum version 1.12)
  Go version:       go1.16.2
  Git commit:       9bb540d
  Built:            Fri Jul 23 01:32:08 2021
  OS/Arch:          linux/amd64
  Experimental:     false
  Default Registry: docker.io
 containerd:
  Version:          v1.4.8
  GitCommit:        7eba5930496d9bbe375fdf71603e610ad737d2b2
 runc:
  Version:          1.1.4
  GitCommit:        5fd4c4d
 docker-init:
  Version:          0.18.0
  GitCommit:        fec3683
  
 */
[root@myserver ~]# useradd mydocker
[root@myserver ~]# echo "mydocker  ALL=(ALL)  NOPASSWD: /usr/bin/docker" >> /etc/sudoers
[root@myserver ~]# echo "alias docker=\"sudo /usr/bin/docker\"" >> /home/mydocker/.bash_profile
[root@myserver ~]# su - mydocker
[mydocker@myserver ~]$ docker ps
/*
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES

*/

[root@myserver ~]# su - mydocker
Last login: Mon Jun  5 10:29:56 +0545 2023 on pts/0
[mydocker@myserver ~]$ 
[mydocker@myserver 23.2.0]$
--The last thing to do here is to pull the Oracle 23c image
[root@myserver ]# sudo docker pull container-registry.oracle.com/database/free


[mydocker@myserver ~]$ docker images
REPOSITORY                                    TAG                 IMAGE ID            CREATED             SIZE
container-registry.oracle.com/database/free   latest              7c64410c08d5        2 months ago        10.3GB
[mydocker@myserver ~]$


docker container create -it --name oracle23c -p 1521:1521 -e ORACLE_PWD=oracle23c container-registry.oracle.com/database/free
/*
9bbc959f3888c882cd7d4272347da4d74788b4df23c55b5f2793de743a007528

*/
[mydocker@myserver ~]$ docker container ls -a
/*
CONTAINER ID        IMAGE                                         COMMAND                  CREATED             STATUS              PORTS               NAMES
9bbc959f3888        container-registry.oracle.com/database/free   "/bin/sh -c 'exec $O…"   44 seconds ago      Created                                 oracle23c
*/

[mydocker@myserver ~]$ docker start oracle23c
oracle23c


[mydocker@myserver ~]$ docker container ls
/*
CONTAINER ID        IMAGE                                         COMMAND                  CREATED             STATUS                             PORTS                    NAMES
9bbc959f3888        container-registry.oracle.com/database/free   "/bin/sh -c 'exec $O…"   3 minutes ago       Up 52 seconds (health: starting)   0.0.0.0:1521->1521/tcp   oracle23c

*/
[mydocker@myserver ~]$ docker container stats
/*
CONTAINER ID        NAME                CPU %               MEM USAGE / LIMIT     MEM %               NET I/O             BLOCK I/O           PIDS
9bbc959f3888        oracle23c           0.89%               555.2MiB / 3.556GiB   15.25%              127kB / 82kB        13.1GB / 6.31GB     87
CONTAINER ID        NAME                CPU %               MEM USAGE / LIMIT     MEM %               NET I/O             BLOCK I/O           PIDS
9bbc959f3888        oracle23c           0.89%               555.2MiB / 3.556GiB   15.25%              127kB / 82kB        13.1GB / 6.31GB     87
CONTAINER ID        NAME                CPU %               MEM USAGE / LIMIT     MEM %               NET I/O             BLOCK I/O           PIDS
9bbc959f3888        oracle23c           3.38%               555.3MiB / 3.556GiB   15.25%              127kB / 82.5kB      13.1GB / 6.31GB     87
CONTAINER ID        NAME                CPU %               MEM USAGE / LIMIT     MEM %               NET I/O             BLOCK I/O           PIDS
9bbc959f3888        oracle23c           3.38%               555.3MiB / 3.556GiB   15.25%              127kB / 82.5kB      13.1GB / 6.31GB     87
CONTAINER ID        NAME                CPU %               MEM USAGE / LIMIT     MEM %               NET I/O             BLOCK I/O           PIDS
9bbc959f3888        oracle23c           3.03%               555.3MiB / 3.556GiB   15.25%              127kB / 82.5kB      13.1GB / 6.31GB     87
CONTAINER ID        NAME                CPU %               MEM USAGE / LIMIT     MEM %               NET I/O             BLOCK I/O           PIDS
9bbc959f3888        oracle23c           3.03%               555.3MiB / 3.556GiB   15.25%              127kB / 82.5kB      13.1GB / 6.31GB     87
CONTAINER ID        NAME                CPU %               MEM USAGE / LIMIT     MEM %               NET I/O             BLOCK I/O           PIDS
9bbc959f3888        oracle23c           3.46%               555.3MiB / 3.556GiB   15.25%              127kB / 82.5kB      13.1GB / 6.31GB     87
CONTAINER ID        NAME                CPU %               MEM USAGE / LIMIT     MEM %               NET I/O             BLOCK I/O           PIDS
9bbc959f3888        oracle23c           3.46%               555.3MiB / 3.556GiB   15.25%              127kB / 82.5kB      13.1GB / 6.31GB     87
CONTAINER ID        NAME                CPU %               MEM USAGE / LIMIT     MEM %               NET I/O             BLOCK I/O           PIDS
9bbc959f3888        oracle23c           3.32%               555.4MiB / 3.556GiB   15.25%              127kB / 82.5kB      13.1GB / 6.31GB     87
CONTAINER ID        NAME                CPU %               MEM USAGE / LIMIT     MEM %               NET I/O             BLOCK I/O           PIDS
9bbc959f3888        oracle23c           3.32%               555.4MiB / 3.556GiB   15.25%              127kB / 82.5kB      13.1GB / 6.31GB     87
CONTAINER ID        NAME                CPU %               MEM USAGE / LIMIT     MEM %               NET I/O             BLOCK I/O           PIDS
9bbc959f3888        oracle23c           3.17%               555.4MiB / 3.556GiB   15.25%              127kB / 82.5kB      13.1GB / 6.31GB     87

*/
[mydocker@myserver ~]$ docker exec -it 9bbc959f3888 /bin/sh
sh-4.4$ sqlplus / as sysdba

/*
SQL*Plus: Release 23.0.0.0.0 - Developer-Release on Mon Jun 5 09:05:08 2023
Version 23.2.0.0.0

Copyright (c) 1982, 2023, Oracle.  All rights reserved.


Connected to:
Oracle Database 23c Free, Release 23.0.0.0.0 - Developer-Release
Version 23.2.0.0.0

SQL> show pdbs;

    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         3 FREEPDB1                       READ WRITE NO

*/
--to view the docker log
[mydocker@myserver ~]$ docker logs 9bbc
/*
Starting Oracle Net Listener.
Oracle Net Listener started.
Starting Oracle Database instance FREE.
Oracle Database instance FREE started.

The Oracle base remains unchanged with value /opt/oracle

SQL*Plus: Release 23.0.0.0.0 - Developer-Release on Mon Jun 5 06:47:57 2023
Version 23.2.0.0.0

Copyright (c) 1982, 2023, Oracle.  All rights reserved.


Connected to:
Oracle Database 23c Free, Release 23.0.0.0.0 - Developer-Release
Version 23.2.0.0.0

SQL>
User altered.

SQL>
User altered.

SQL>
Session altered.

SQL>
User altered.

SQL> Disconnected from Oracle Database 23c Free, Release 23.0.0.0.0 - Developer-Release
Version 23.2.0.0.0
The Oracle base remains unchanged with value /opt/oracle
#########################
DATABASE IS READY TO USE!
#########################
The following output is now a tail of the alert.log:
Completed: Pluggable database FREEPDB1 opened read write
Completed: ALTER DATABASE OPEN
2023-06-05T06:47:56.990621+00:00
===========================================================
Dumping current patch information
===========================================================
No patches have been applied
===========================================================
2023-06-05T06:47:59.829441+00:00
FREEPDB1(3):TABLE AUDSYS.AUD$UNIFIED: ADDED INTERVAL PARTITION SYS_P411 (3262) VALUES LESS THAN (TIMESTAMP' 2023-06-06 00:00:00')
2023-06-05T06:53:53.334093+00:00
Resize operation completed for file# 201, fname /opt/oracle/oradata/FREE/temp01.dbf, old size 20480K, new size 86016K
2023-06-05T06:53:54.938050+00:00
Resize operation completed for file# 201, fname /opt/oracle/oradata/FREE/temp01.dbf, old size 86016K, new size 151552K
2023-06-05T06:53:56.806248+00:00
Resize operation completed for file# 201, fname /opt/oracle/oradata/FREE/temp01.dbf, old size 151552K, new size 217088K
2023-06-05T06:53:58.241391+00:00
Resize operation completed for file# 201, fname /opt/oracle/oradata/FREE/temp01.dbf, old size 217088K, new size 282624K
2023-06-05T06:53:59.811410+00:00
Resize operation completed for file# 201, fname /opt/oracle/oradata/FREE/temp01.dbf, old size 282624K, new size 348160K
2023-06-05T06:57:47.281660+00:00
--ATTENTION--
Heavy swapping observed on system
WARNING: Heavy swapping observed on system in last 5 mins.
Heavy swapping can lead to timeouts, poor performance, and instance eviction.
2023-06-05T06:57:49.338946+00:00
Resize operation completed for file# 3, fname /opt/oracle/oradata/FREE/sysaux01.dbf, old size 563200K, new size 573440K
2023-06-05T06:57:49.341101+00:00
FREEPDB1(3):Resize operation completed for file# 13, fname /opt/oracle/oradata/FREE/FREEPDB1/sysaux01.dbf, old size 317440K, new size 337920K
2023-06-05T07:34:52.615367+00:00
Warning: VKTM detected a forward time drift.
Please see the VKTM trace file for more details:
/opt/oracle/diag/rdbms/free/FREE/trace/FREE_vktm_43.trc
*/