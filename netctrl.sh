#!/bin/sh
#SONY-Wifi 38:B8:00:49:C8:A5
#PC 50:46:5D:64:FE:43
#dudu-ipad 2A:6A:6B:AE:E3:CA
#tangyuan-ipad F6:66:85:0A:7C:A4
getmac() {
    case "$1" in
        tv)
            mac=38:B8:00:49:C8:A5
            rulename=BLOCK-TV
            ip=192.168.11.204
            name=电视
        ;;
        pc)
            mac=50:46:5D:64:FE:43
            rulename=BLOCK-PC
            ip=192.168.11.100
            name=台式机
        ;;
        ddipad)
            mac=2A:6A:6B:AE:E3:CA
            rulename=BLOCK-duduiPad
            name=嘟嘟iPad
        ;;
        tyipad)
            mac=F6:66:85:0A:7C:A4
            rulename=BLOCK-tangyuaniPad
            name=汤圆iPad
        ;;
        *)
            echo 支持的控制目标: tv pc ddipad tyipad
            exit 1
    esac
}
getconf() {
    if ! uci show firewall | grep -q name=\'$rulename\' ; then
        echo 没找到 $1:$mac 上网控制设置 >&2
        exit 1
    fi
    conf=$(uci show firewall | grep name=\'$rulename\' | sed 's/\.name=.*//')
}

cleanatq() {
    atq | awk '{print $1}' | while read -r jobid ; do
        at -c "$jobid" | grep -q "netctrl.sh disallow $1" && at -r "$jobid"
    done
}

case "$1" in
    allow)
        getmac $2
        getconf $2
        date +%F\ %H:%M"</br>"
        if [ "$(uci get $conf.enabled)" == "0" ]
            then
            echo $name 已是允许状态
            else
            uci set $conf.enabled=0
            uci commit firewall
            if [ "$ip" != "" ] ; then
                uci show shadowsocks-libev.ss_rules.src_ips_bypass | grep -q \'$ip\'
                if [ $? == "0" ] ; then
                    uci del_list shadowsocks-libev.ss_rules.src_ips_bypass=$ip
                    uci commit shadowsocks-libev
                    /etc/init.d/shadowsocks-libev restart 2>/dev/null && echo 允许 $name 上网 || echo 允许 $name 上网失败
                else
                    /sbin/fw4 -q reload && echo 允许 $name 上网 || echo 允许 $name 上网失败
                fi
            fi
        fi
    ;;
    disallow)
        getmac $2
        getconf
        date +%F\ %H:%M"</br>"
        if [ "$(uci get $conf.enabled)" == "1" ] ; then
            echo $name 已是禁止状态
            else
            uci set $conf.enabled=1
            uci commit firewall
            if [ "$ip" != "" ] ; then
                uci show shadowsocks-libev.ss_rules.src_ips_bypass | grep -q \'$ip\'
                if [ $? == "1" ] ; then
                    uci add_list shadowsocks-libev.ss_rules.src_ips_bypass=$ip
                    uci commit shadowsocks-libev
                    /etc/init.d/shadowsocks-libev restart 2>/dev/null && echo 禁止 $name 上网 || echo 禁止 $name 上网失败
                else
                    /sbin/fw4 -q reload && echo 禁止 $name 上网 || echo 禁止 $name 上网失败
                fi
            fi
        fi
    ;;
    allow10)
        $0 allow $2 || exit 1
        echo $0 disallow $2 | at -q a now + 10 min 2>/dev/null
	date -d "@$(( $(busybox date +%s) + 60 * 10 ))" +"</br>至 "%H:%M"</br>10 分钟"
        exit 0
    ;;
    allow15)
        $0 allow $2 || exit 1
        echo $0 disallow $2 | at -q a now + 15 min 2>/dev/null
	date -d "@$(( $(busybox date +%s) + 60 * 15 ))" +"</br>至 "%H:%M"</br>15 分钟"
        exit 0
    ;;
    allow20)
        $0 allow $2 || exit 1
        echo $0 disallow $2 | at -q a now + 20 min 2>/dev/null
	date -d "@$(( $(busybox date +%s) + 60 * 20 ))" +"</br>至 "%H:%M"</br>20 分钟"
        exit 0
    ;;
    allow25)
        $0 allow $2 || exit 1
        cleanatq $2
        echo $0 disallow $2 | at -q a now + 25 min 2>/dev/null
	date -d "@$(( $(busybox date +%s) + 60 * 25 ))" +%"</br>至 "H:%M"</br>30 分钟"
        exit 0
    ;;
    allow30)
        $0 allow $2 || exit 1
        cleanatq $2
        echo $0 disallow $2 | at -q a now + 30 min 2>/dev/null
	date -d "@$(( $(busybox date +%s) + 60 * 30 ))" +"</br>至 "%H:%M"</br>30 分钟"
        exit 0
    ;;
    allow60)
        $0 allow $2 || exit 1
        echo $0 disallow $2 | at -q a now + 60 min 2>/dev/null
	date -d "@$(( $(busybox date +%s) + 60 * 60 ))" +"</br>至 "%H:%M"</br>1 小时"
        exit 0
    ;;
    *)
        echo use allow or disallow
        exit 1
esac
