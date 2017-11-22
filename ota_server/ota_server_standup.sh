!#/bin/bash

#install package
echo "starting install package"
yum install -y openssh-clients gcc automake autoconf libtool make unzip zip expat-devel gcc-c++
yum remove httpd httpd-tools

#to confirm we were install sucessfully
for  pak in openssh-clients gcc automake autoconf libtool make unzip zip expat-devel gcc-c++;do
    rpm -qa | grep $pak
    if [ $? != 0 ]; then
        echo "install $pak failed!"
        exit 1
    fi
done

wget http://www.cpan.org/src/5.0/perl-5.16.3.tar.gz
tar xfz perl-5.16.3.tar.gz
cd perl-5.16.3
./Configure -des -Dprefix=/usr/local/perl
make && make install
cd

echo "download and install openssl....."
wget https://www.openssl.org/source/openssl-1.0.2l.tar.gz
tar xfz openssl-1.0.2l.tar.gz
cd openssl-1.0.2l
./config shared -fPIC --prefix=/usr/local/openssl enable-tlsext
make && make install
echo "export LD_LIBRARY_PATH=/usr/local/openssl/lib" >> /etc/profile
source /etc/profile
cd

wget http://mirror.bit.edu.cn/apache//apr/apr-1.6.3.tar.gz
wget http://mirror.bit.edu.cn/apache//apr/apr-util-1.6.1.tar.gz

tar xfz apr-1.6.3.tar.gz
cd apr-1.6.3
./configure --prefix=/usr/local/apr
make && make install
cd


tar xfz apr-util-1.6.1.tar.gz
cd apr-util-1.6.1
./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr/bin/apr-1-config
make && make install
cd


wget https://ftp.pcre.org/pub/pcre/pcre-8.41.tar.gz
tar xzf pcre-8.41.tar.gz
cd pcre-8.41/
./configure --prefix=/usr/local/pcre
make && make install
cd

wget http://mirrors.tuna.tsinghua.edu.cn/apache//httpd/httpd-2.4.28.tar.bz2
tar jxvf httpd-2.4.28.tar.bz2
cd httpd-2.4.28/
./configure --prefix=/usr/local/apache --enable-mods-shared=all  --enable-mpms-shared=all --enable-nonportable-atomics=yes  --with-apr=/usr/local/apr --with-apr-util=/usr/local/apr-util --with-pcre=/usr/local/pcre/bin/pcre-config --enable-ssl --with-ssl=/usr/local/openssl
make && make install

cp /usr/local/apache/conf/httpd.conf /usr/local/apache/conf/httpd.conf.init

OLDIFS=$IFS
IFS=$'\n'
modules="#LoadModule slotmem_shm_module
#LoadModule proxy_module
#LoadModule proxy_http_module
#LoadModule proxy_ajp_module
#LoadModule proxy_balancer_module
#LoadModule lbmethod_byrequests_module
#LoadModule lbmethod_bytraffic_module
#LoadModule lbmethod_bybusyness_module
#LoadModule ssl_module"

for module in $modules;do
    echo $module
    sed -i "s/${module}/${module#*#}/" /usr/local/apache/conf/httpd.conf
done
IFS=$OLDIFS


## Find the line: #ServerName www.example.com:80,
# add the line below after it:
# ServerName localhost:80
#Listen 80
## Find the line: DocumentRoot "/usr/local/apache/htdocs"
# change it as: DocumentRoot "/data/www/default"
## Find the line: <Directory "/usr/local/apache/htdocs">
# change it as: <Directory "/data/www/default">
## Find the line: ErrorLog "logs/error_log"
# change it as: ErrorLog "|/usr/local/apache/bin/rotatelogs /data/logs/apache/error_log_default_%Y%m%d 86400 480"
## Find the line: LogFormat "%h %l %u %t \"%r\" %>s %b" common,
# add the lines below:
#   LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %U%q %{Range}i %{Content-Length}o %D %X" GNCustomLog
#    LogFormat "%t %h %{SSL_PROTOCOL}x %{SSL_CIPHER}x \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %U%q %{Range}i %{Content-Length}o %D %X" GNCustomSSLLog
## Find the line: CustomLog "logs/access_log" common
# change it as: CustomLog "|/usr/local/apache/bin/rotatelogs /data/logs/apache/access_log_default_%Y%m%d 86400 480" common
## Find the line "#Include conf/extra/httpd-vhosts.conf",
# uncomment it.

cp /usr/local/apache/conf/extra/httpd-vhosts.conf /usr/local/apache/conf/extra/httpd-vhosts.conf.init

echo 'Listen 82
<VirtualHost *:82>
    ServerAdmin lugf@chenyee.com
    DocumentRoot "/data/www/p-admin"
    ServerName ota.chenyee.com
    SetEnvIf Request_URI \.(png|jpg|gif|css|js)$ img-css-js-req
    #RequestHeader set X-Forwarded-Proto HTTP
    ErrorLog "|/usr/local/apache/bin/rotatelogs /data/logs/apache/error_log_p-admin_82_%Y%m%d 86400 480"
    CustomLog "|/usr/local/apache/bin/rotatelogs /data/logs/apache/access_log_p-admin_82_%Y%m%d 86400 480" GNCustomLog env=!img-css-js-req
    <Directory /data/www/p-admin>
      Options FollowSymLinks
      AllowOverride None
      Order deny,allow
      Allow from all
      Require all granted
    </Directory>
    <IfModule jk_module>
        JkMountFile  conf/uriworkermap.properties
        JkLogFile  /data/logs/apache/mod_jk.log
    </IfModule>
</VirtualHost>' > /usr/local/apache/conf/extra/httpd-vhosts.conf


mkdir -p /data/logs/apache
mkdir -p /data/www/p-admin
mkdir /data/www/default

echo "install jdk"
cd
wget http://mirrors.linuxeye.com/jdk/jdk-8u144-linux-x64.tar.gz
tar xzf jdk-8u144-linux-x64.tar.gz
mv jdk1.8.0_144/ /usr/local/jdk

wget http://mirror.bit.edu.cn/apache/tomcat/tomcat-7/v7.0.82/bin/apache-tomcat-7.0.82.tar.gz
tar xzf apache-tomcat-7.0.82.tar.gz
mv apache-tomcat-7.0.82 /usr/local/tomcat

##添加tomcat管理账号
## Find the section "<tomcat-users>..."
# add the lines below:
#vi /usr/local/tomcat/conf/tomcat-users.xml
#<role rolename="admin" />
#<role rolename="admin-gui" />
#<role rolename="manager" />
#<role rolename="manager-gui" />
#<user username="admin" password="8wid6g4e" roles="admin,admin-gui,manager,manager-gui" />


echo 'xport JAVA_HOME=/usr/local/jdk
export TOMCAT_HOME=/usr/local/tomcat
export PATH=$JAVA_HOME/bin:$PATH
' >> /etc/profile

cd
wget http://mirror.bit.edu.cn/apache/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.42-src.tar.gz
tar xzf tomcat-connectors-1.2.42-src.tar.gz
cd tomcat-connectors-1.2.42-src/
cd native/
./configure --with-apxs=/usr/local/apache/bin/apxs
make && make install

cd

## add jk module
#vi /usr/local/apache/conf/httpd.conf
#LoadModule jk_module modules/mod_jk.so
#<IfModule jk_module>
#     JkWorkersFile conf/workers.properties
#     JkShmFile  /data/logs/apache/mod_jk.shm
#     JkLogLevel warn
#     JkLogStampFormat "[%a %b %d %H:%M:%S %Y]"
#</IfModule>

echo "worker.list=worker,jkstatus
worker.worker.port=8009
worker.worker.host=localhost
worker.worker.type=ajp13
worker.worker.lbfactor=1
worker.jkstatus.type=status
" > /usr/local/apache/conf/workers.properties

echo "/*=worker
/jkmanager=jkstatus
!/*.gif=worker
!/*.jpg=worker
!/*.png=worker
!/*.css=worker
!/*.js=worker
!/*.htm=worker
!/*.html=worker
!/otadm/res/*=worker
!/otadm/temp/*=worker
!/manager/*=worker
" > /usr/local/apache/conf/uriworkermap.properties

mkdir /data/www/p-admin/manager/
cp -a /usr/local/tomcat/webapps/manager/images/ /data/www/p-admin/manager/

echo "tomcat is ready"

#install mysql on ota3
yum install mysql-server  #only availd on centos 6.x

#>create database otadb DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
#>use otadb;
>source otadb.sql;
>source otapushdb.sql;
>grant all on otadb.* to otadbw@'%' identified by 'tvua3545';
>grant all on otapushdb.* to otadbw@'%' identified by 'tvua3545';
>flush privileges;


#install otadm
cp otadm.war /usr/local/tomcat/webapps/
#becasue otadm miss the aps package, we need copy from the otatest server manully.
scp -r aps root@119.81.96.122:/usr/local/tomcat/webapps/otadm/WEB-INF/classes/com/gionee


#vi /usr/local/tomcat/bin/catalina.sh #lugf -XX:PermSize=256M -XX:MaxPermSize=512m 在8.0 里不支持
#JAVA_OPTS="-server -Xms2048m -Xmx2048m -XX:PermSize=256M -XX:MaxPermSize=512m"

#vi /usr/local/tomcat/webapps/otadm/WEB-INF/classes/OTAApsDB.properties
#database.aps.driver=com.mysql.jdbc.Driver
#database.aps.url=jdbc:mysql://10.10.100.6/otapushdb?allowMultiQueries=true&useUnicode=true&characterEncoding=utf8
#database.aps.username=otadbw
#database.aps.password=10.10.100.6
#database.min.aps.conn=10
#database.max.aps.conn=250
#hibernate.mapping.directory=/com/gionee/ota/server/so/mysql


#vi /usr/local/tomcat/webapps/otadm/WEB-INF/classes/OTAServerDB.properties
#change the mysql server ip address
#database.url=jdbc:mysql://10.10.100.6/otadb?autoReconnect=true&useUnicode=true&characterEncoding=UTF-8
#database.username=otadbw
#database.password=tvua3545
#database.min.conn=10
#database.max.conn=500

#vi /usr/local/tomcat/webapps/otadm/WEB-INF/classes/OTAServer.properties
#### web domain
#web.path=http://ota.chenyee.com:91/ota/   #这个是客户端下载ota包的地址
#
#### web resource config
#resc.root=/data/dl/ota/res
#resc.temp=/data/dl/ota/temp
#resc.ota=ota
#resc.cm=cm

#releaseNotes.upload=/data/dl/ota/rn/
#display.path=/rn/

#### menu id
#menu.id.devices=1
#menu.id.sysmnt=2
#menu.id.users=3
#menu.id.groups=4


#### performace logger
#perf.log.switch=false

#### mail send config
#mail.send.tag.submit=1
#mail.send.tag.reject=1
#mail.send.tag.pass=1
#mail.send.tag.release=1

#### web page size and other constants
#web.page.size=15
#file.system.protocol=file:///

#### using push
#sys.push.active=false

mkdir -p /data/dl/ota/res
mkdir -p /data/dl/ota/temp

#starting conifgure jms
mkdir -p /data/logs/jms
cd
wget https://archive.apache.org/dist/activemq/5.15.0/apache-activemq-5.15.0-bin.tar.gz
tar xvf apache-activemq-5.15.0-bin.tar.gz
mv apache-activemq-5.15.0 /usr/local/ActiveMQ
cd /usr/local/ActiveMQ/conf
cp activemq.xml activemq.xml.init
#vi activemq.xml #remove all other name except openwire and replace 0.0.0.0 to the ip
#<transportConnectors>
#<transportConnector name="openwire" uri="tcp://0.0.0.0:61616"/>
#</transportConnectors>
#<transportConnectors>
#<transportConnector name="openwire" uri="tcp://内网ip:61616"/>
#</transportConnectors>

#####AMQ store的配置  不要这个配置了，从 5.4 开始后不支持 amqPersistenceAdapter , 用后面的 kahadb
#<broker xmlns="http://activemq.apache.org/schema/core" brokerName="broker" persistent="true" useShutdownHook="false" dataDirectory="${activemq.data}">
#<persistenceAdapter>
#<amqPersistenceAdapter directory="${activemq.data}" maxFileLength="32mb"/>


#######KahaDB的配置
#<kahaDB directory="${activemq.data}/kahadb" journalMaxFileLength="32mb" checksumJournalFiles="true" checkForCorruptJournalFiles="true"/>
#</persistenceAdapter>
#</broker>

#修改 env jvm memory 为 1G
#vi /usr/local/ActiveMQ/bin/env
#ACTIVEMQ_OPTS_MEMORY="-Xms1G -Xmx1G"

#vi /usr/local/tomcat/webapps/otadm/WEB-INF/classes/jmsConfig.properties
### jms config
#jms.brokerURL=tcp://10.67.37.86:61616
#jms.username=system
#jms.password=manager
#jms.receiveTimeout=10000
#jms.destination.sys.name=aps.sys


mkdir -p /data/www/p-admin/otadm
cd /usr/local/tomcat/webapps/otadm
cp -a css /data/www/p-admin/otadm/
cp -a js /data/www/p-admin/otadm/
cp -a image /data/www/p-admin/otadm/

ln -s /data/dl/ota/res/ /data/www/p-admin/otadm/res
ln -s /data/dl/ota/temp/ /data/www/p-admin/otadm/temp

#tomcat mysql connector
cd
wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.44.tar.gz

tar xzf mysql-connector-java-5.1.44.tar.gz
cd mysql-connector-java-5.1.44/
cp mysql-connector-java-5.1.44-bin.jar /usr/local/tomcat/lib/

vi /usr/local/tomcat/conf/server.xml
<Host name="ota.chenyee.com"  appBase="webapps" unpackWARs="true" autoDeploy="true">


######################################OTA DEPLOY###########################


echo "start ota deploy"
#jetty
cd
wget http://central.maven.org/maven2/org/eclipse/jetty/jetty-distribution/8.1.21.v20160908/jetty-distribution-8.1.21.v20160908.tar.gz
tar xzf jetty-distribution-8.1.21.v20160908.tar.gz
mv jetty-distribution-8.1.21.v20160908 /usr/local/jetty-8.1.21

#vim /usr/local/jetty-8.1.21/bin/jetty.sh
#JAVA_OPTIONS+=(" -Xms2048m -Xmx2048m -Xmn1280m -Xss256k -XX:+UseParallelGC -XX:+UseParallelOldGC -XX:ParallelGCThreads=4")


#vim /usr/local/jetty-8.1.21/etc/webdefault.xml
#<init-param>
#      <param-name>dirAllowed</param-name>
#      <param-value>false</param-value>
#    </init-param>

#vim  /usr/local/jetty-8.1.21/etc/jetty.xml
#<Set name="port"><Property name="jetty.port" default="8880"/></Set>
#<Set name="confidentialPort">9443</Set>
#<Set name="forwarded">true</Set>

cp /usr/local/jetty-8.1.21/lib/jetty-ajp-8.1.21.v20160908.jar /usr/local/jetty-8.1.21/lib/ext/

mkdir -p /usr/local/jetty-8.1.21/webapps/ota
cd /usr/local/jetty-8.1.21/webapps/ota
cp /root/ota.war /usr/local/jetty-8.1.21/webapps/ota/

jar xvf ota.war

#vim /usr/local/jetty-8.1.21/webapps/ota/WEB-INF/classes/GnAPI_OTADatabase.properties
#database.url=jdbc:mysql://119.81.96.113/otadb?autoReconnect=true&useUnicode=true&characterEncoding=UTF-8
#database.username=otadbw
#database.password=tvua3545

#vim /usr/local/jetty-8.1.21/webapps/ota/WEB-INF/classes/GnAPI_OTA.properties
#web.path=http://ota.chenyee.com:91/ota/
#resc.ota=ota
#releaseNote_url=getTemplate.do
#releaseNotes.upload=/data/dl/ota/rn/

cd /usr/local/jetty-8.1.21/
cp /usr/local/tomcat/lib/mysql-connector-java-5.1.44-bin.jar /usr/local/jetty-8.1.21/lib/ext/

#
mkdir /data/www/ota/
mkdir -p /data/log/rel
mkdir -p /data/log/thm

echo 'export LD_LIBRARY_PATH=/usr/local/openssl/lib
export JAVA_HOME=/usr/local/jdk
export TOMCAT_HOME=/usr/local/tomcat
export JETTY_HOME=/usr/local/jetty-8.1.21
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib
export PATH=$JAVA_HOME/bin:$PATH
sh /usr/local/tomcat/bin/startup.sh
/usr/local/apache/bin/httpd -k start
nohup /usr/local/ActiveMQ/bin/activemq start>>/data/logs/jms/jmslog 2>&1 &
sh /usr/local/jetty-8.1.21/bin/jetty.sh start
' >> /etc/rc.local

echo '
<VirtualHost *:80>
    ServerAdmin lugf@chenyee.com
    DocumentRoot "/data/www/ota/"
    ServerName 119.81.96.122 #在正式环境中换成域名
    ErrorLog "|/usr/local/apache/bin/rotatelogs /data/logs/apache/error_log_ota_80_%Y%m%d 86400 480"
    CustomLog "|/usr/local/apache/bin/rotatelogs /data/logs/apache/access_log_ota_80_%Y%m%d 86400 480" GNCustomLog
    <Directory /data/www/ota/>
#      Options FollowSymLinks
      Options +Indexes
      AllowOverride None
      Order deny,allow
      Allow from all
      Require all granted
      FileETag None
    </Directory>
        ProxyRequests Off
        ProxyVia Off
        ProxyPreserveHost On
        <Proxy *>
                AddDefaultCharset off
                Order deny,allow
                Allow from all
        </Proxy>
        ProxyStatus On
        <Location /status>
                SetHandler server-status
                Order Deny,Allow
                Allow from all
        </Location>
        ProxyPass /ota http://localhost:8880/ota
        ProxyPassReverse /ota http://localhost:8880/ota
</VirtualHost>

Listen 81
<VirtualHost *:81>
    ServerName 119.81.96.122 #在正式环境中换成域名
    DocumentRoot /data/dl
    LogFormat "%h %{%Y%m%d%H%M%S}t %U%q %{Range}i %{Content-Length}o \"%{User-Agent}i\"" down
    SetEnvIf Request_URI "^/ota/res/.+" ota-down
    CustomLog "|/usr/local/apache/bin/rotatelogs   /data/logs/ota/d-%Y%m%d%H.log 3600 480" downenv=ota-down
    <Directory "/data/dl">
        Options FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>
</VirtualHost>
' >> /usr/local/apache/conf/extra/httpd-vhosts.conf

otadm Login 的用户名密码： admin/gionee@2015

#keepalived + haproxy
yum install keepalived haproxy


vi /etc/keepalived/keepalived.conf
global_defs {
   notification_email {
        lugf@chenyee.com
   }
   notification_email_from opm@chenyee.com
   smtp_server hwhkhm.qiye.163.com
   smtp_connect_timeout 30
   router_id haproxy-ha
}

vrrp_script chk_haproxy {
   script "/bin/bash /root/monitor_keepalived.sh"
   interval 5
   timeout 3
   fall   2
   rise   2
}

vrrp_instance VI_stats {
   state MASTER
   notify /root/keepalived_alert.sh
   interface bond1
   track_interface {
      bond0
      bond1
   }
   virtual_router_id 62
   priority 200         # 这里 backup 机器的评分修改为 150
   garp_master_delay 10
   advert_int 10
   authentication {
      auth_type PASS
      auth_pass 1234
   }
   track_script {
      chk_haproxy
   }
   virtual_ipaddress {

       119.81.31.125/16 dev bond1 scope global
   }
}
}

###### haproxy

vi /etc/haproxy/haproxy.cfg
#---------------------------------------------------------------------
# Example configuration for a possible web application.  See the
# full configuration options online.
#
#   http://haproxy.1wt.eu/download/1.4/doc/configuration.txt
#
#---------------------------------------------------------------------

#---------------------------------------------------------------------
# Global settings
#---------------------------------------------------------------------
global
    # to have these messages end up in /var/log/haproxy.log you will
    # need to:
    #
    # 1) configure syslog to accept network log events.  This is done
    #    by adding the '-r' option to the SYSLOGD_OPTIONS in
    #    /etc/sysconfig/syslog
    #
    # 2) configure local2 events to go to the /var/log/haproxy.log
    #   file. A line like the following can be added to
    #   /etc/sysconfig/syslog
    #
    #    local2.*                       /var/log/haproxy.log
    #
    log         127.0.0.1 local2

    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon

    # turn on stats unix socket
    stats socket /var/lib/haproxy/stats

#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------
defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option      httpclose
    option                  redispatch
    retries                 3
    timeout connect         5s
    timeout client          1m
    timeout server          1m
    maxconn                 3000

#---------------------------------------------------------------------
# main frontend which proxys to the backends
#---------------------------------------------------------------------
frontend http-in
         bind *:90,*:92,*:91
         acl ota hdr_beg(host) -i ota.chenyee.com:90
         acl otadl hdr_beg(host) -i ota.chenyee.com:91
         acl otadm hdr_beg(host) -i ota.chenyee.com:92
         use_backend ota if ota
         use_backend otadl if otadl
         use_backend otadm if otadm

backend ota
        balance roundrobin
        option  httpchk GET /heartbeat.txt
        server  ota01 10.67.37.86:80 cookie ota01 check addr 10.67.37.86 port 80 inter 2000 rise 2 fall 5
        server  ota02 10.67.37.77:80 cookie ota02 check addr 10.67.37.77 port 80 inter 2000 rise 2 fall 5
        cookie  SERVERID rewrite
backend otadl
        balance roundrobin
        option  httpchk GET /heartbeat.txt
        server  ota01 10.67.37.86:81 cookie otadl01 check addr 10.67.37.86 port 81 inter 2000 rise 2 fall 5
        server  ota02 10.67.37.77:81 cookie otadl02 check addr 10.67.37.77 port 81 inter 2000 rise 2 fall 5
        cookie  SERVERID rewrite
backend otadm
        balance roundrobin
        option  httpchk GET /heartbeat.txt
        server  ota01 10.67.37.86:82 cookie otadm check addr 10.67.37.86 port 82 inter 2000 rise 2 fall 5
        cookie  SERVERID rewrite

#编辑 /etc/rsyslog.conf 加入 @centos
local2.*                                                /var/log/haproxy.log

#download sendEmail-v1.56
拷贝脚本 monitor_keepalived.sh keepalived_alert.sh

### check haproxy and start
chkconfig haproxy on
chkconfig keepalived on
/etc/init.d/haproxy start
/etc/init.d/keepalived start



### start keepalived and check vip
### touch heartbeat.txt
touch /data/dl/heartbeat.txt
touch /data/www/ota/heartbeat.txt
touch /data/www/p-admin/heartbeat.txt
touch /usr/local/tomcat/webapps/ROOT/heartbeat.txt

#同步文件在 ota1 跟 ota2 之间通过 rsync
ota1 作为 rsync 客户端
在 /etc/rc.local 里加入nohup /root/inotify_rsync.sh &

ota2 作为 rsync 备份端
添加  rsync --daemon --config=/etc/rsync.conf 到 /etc/rc.local

vi /etc/rsync.conf
uid = root
gid = root
use chroot = no
max connections = 20
strict modes = yes
log file = /var/log/rsyncd.log
pid file = /var/run/rsyncd.pid
lock file = /var/run/rsync.lock
log format = %t %a %m %f %b
[otares]
path = /data/dl/ota/res
auth users = rsync
read only = no
hosts allow = 10.67.37.86
hosts deny = *
list = no
uid = root
gid = root
secrets file = /etc/rsync.secure
ignore errors = yes
timeout = 120
dont compress = *.gz *.tgz *.zip *.z *.rpm *.deb *.iso *.bz2 *.tbz

vi /etc/rsync.secure
rsync:rsync@ota2   #用户名密码

因为strict modes = yes,所以必须
chmod 600 /etc/rsync.secure

#测试：
http://ota.chenyee.com:90/ota/check.do
http://ota.chenyee.com:91/ttest.zip
http://ota.chenyee.com:92/otadm/login.do



