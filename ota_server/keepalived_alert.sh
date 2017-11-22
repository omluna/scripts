host=`hostname`
msg="$1 vip has changed. $2 -- $3 at $host"
echo $msg > /root/mail.log
### send email
/root/sendEmail-v1.56/sendEmail -f opm@chenyee.com -t lugf@chenyee.com -u "Oversea haproxy server status changed" -m "${msg}" -s hwhkhm.qiye.163.com -xu opm@chenyee.com -xp Chenyee@1116

