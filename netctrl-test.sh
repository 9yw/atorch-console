#!/bin/bash
# shellcheck disable=SC2034,SC2317
#SONY-Wifi 38:B8:00:49:C8:A5
#PC 50:46:5D:64:FE:43
#dudu-ipad 2A:6A:6B:AE:E3:CA
#tangyuan-ipad F6:66:85:0A:7C:A4
getmac() {
    case "$1" in
    tv)
        mac=38:B8:00:49:C8:A5
        mac_l=38:b8:00:49:c8:a5
        rulename=BLOCK-TV
        ip=192.168.11.204
        name=电视
    ;;
    pc)
        mac=50:46:5D:64:FE:43
        mac_l=50:46:5d:64:fe:43
        rulename=BLOCK-PC
        ip=192.168.11.100
        name=台式机
    ;;
    ddipad)
        mac=2A:6A:6B:AE:E3:CA
        mac_l=2a:6a:6b:ae:e3:ca
        rulename=BLOCK-duduiPad
        name=嘟嘟iPad
    ;;
    tyipad)
        mac=F6:66:85:0A:7C:A4
        mac_l=f6:66:85:0a:7c:a4
        rulename=BLOCK-tangyuaniPad
        name=汤圆iPad
    ;;
    *)
        echo 支持的控制目标: tv pc ddipad tyipad
        exit 1
    esac
}
getconf() {
    uci show firewall | grep -q name=\'$rulename\'
    case $? in
    0)
        return 0
    ;;
        *)
        echo 没找到 $1:$mac 上网控制设置 >&2
        exit 1
    esac
    conf=$(uci show firewall | grep name=\'$rulename\' | sed 's/\.name=.*//')
}

case "$1" in
    allow)
        getmac $2
        getconf $2
        if [ "$(uci get $conf.enabled)" == "0" ] ; then
            echo $name 已是允许状态
        else
            uci set $conf.enabled=0
            uci commit firewall
            # handle=$(nft -a list chain inet fw4 forward | grep "$rulename" | awk '{print $NF}')
            # [ "$handle" -gt 1 ] && nft delete rule inet fw4 forward handle "$handle"
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
        if [ "$(uci get $conf.enabled)" == "1" ] ; then
            echo $name 已是禁止状态
        else
            uci set $conf.enabled=1
            uci commit firewall
            # forward_handle=$(nft -a list chain inet fw4 forward | grep 'Handle lan IPv4/IPv6 forward traffic' | awk '{print $NF}')
            # nft list chain inet fw4 forward | grep -q '"!fw4: '$rulename'"' &&\
            #     nft insert rule inet fw4 forward handle "$forward_handle" ether saddr $mac_l counter drop comment \"\!fw4:\ "$rulename"\"    
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
        echo $0 disallow $2 | at -q a now + 11 min && echo \ 10 分钟
        exit 0
    ;;
    allow15)
        $0 allow $2 || exit 1
        echo $0 disallow $2 | at -q a now + 16 min && echo \ 15 分钟
        exit 0
    ;;
    allow20)
        $0 allow $2 || exit 1
        echo $0 disallow $2 | at -q a now + 21 min && echo \ 20 分钟
        exit 0
    ;;
    allow30)
        $0 allow $2 || exit 1
        echo $0 disallow $2 | at -q a now + 31 min && echo \ 30 分钟
        exit 0
    ;;
    allow60)
        $0 allow $2 || exit 1
        echo $0 disallow $2 | at -q a now + 61 min && echo \ 1 小时
        exit 0
    ;;
    *)
        echo use allow or disallow
        exit 1
esac
