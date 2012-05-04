#!/bin/bash

datadir=$HOME/.local/share/rrdb

if [ ! -f $datadir ]; then
    mkdir -p $datadir
fi

log()
{
    local logfile=$HOME/logs/stats.log
    local fun=$1
    local result=$2
    local date=$(date)
    echo "$date: Writing $fun $result" >> $logfile
}

get_net()
{
    local datafile=$datadir/net.rrd
    if [ ! -e $datafile ]; then
        rrdtool create $datafile --step 60 \
            DS:ppp0_bytes_in:COUNTER:120:U:U \
            DS:ppp0_bytes_out:COUNTER:120:U:U \
            DS:ppp0_packets_in:COUNTER:120:U:U \
            DS:ppp0_packets_out:COUNTER:120:U:U \
            DS:eth0_bytes_in:COUNTER:120:U:U \
            DS:eth0_bytes_out:COUNTER:120:U:U \
            DS:eth0_packets_in:COUNTER:120:U:U \
            DS:eth0_packets_out:COUNTER:120:U:U \
            DS:eth1_bytes_in:COUNTER:120:U:U \
            DS:eth1_bytes_out:COUNTER:120:U:U \
            DS:eth1_packets_in:COUNTER:120:U:U \
            DS:eth1_packets_out:COUNTER:120:U:U \
            DS:wlan0_bytes_in:COUNTER:120:U:U \
            DS:wlan0_bytes_out:COUNTER:120:U:U \
            DS:wlan0_packets_in:COUNTER:120:U:U \
            DS:wlan0_packets_out:COUNTER:120:U:U \
            RRA:AVERAGE:0.5:1:1440 \
            RRA:AVERAGE:0.5:60:168 \
            RRA:AVERAGE:0.5:1440:30 \
            RRA:AVERAGE:0.5:43200:12
    fi
    local output=$(gawk -f $HOME/bin/net.awk /proc/net/dev)

    log "net" $output
    rrdtool update $datafile \
        --template ppp0_bytes_in:ppp0_bytes_out:ppp0_packets_in:ppp0_packets_out:eth0_bytes_in:eth0_bytes_out:eth0_packets_in:eth0_packets_out:eth1_bytes_in:eth1_bytes_out:eth1_packets_in:eth1_packets_out:wlan0_bytes_in:wlan0_bytes_out:wlan0_packets_in:wlan0_packets_out \
        "$output"
}

get_mem()
{
    local datafile=$datadir/mem.rrd
    if [ ! -e $datafile ]; then
        rrdtool create $datafile --step 60 \
            DS:used:GAUGE:120:0:U \
            DS:buffers:GAUGE:120:0:U \
            DS:cached:GAUGE:120:0:U \
            RRA:AVERAGE:0.5:1:1440 \
            RRA:AVERAGE:0.5:60:168 \
            RRA:AVERAGE:0.5:1440:30 \
            RRA:AVERAGE:0.5:43200:12
    fi

    local output=$(free | gawk '
    /Mem/ {print "N:" $3 ":" $6 ":" $7}'
    )

    log "mem" $output

    rrdtool update $datafile --template used:buffers:cached "$output"
}

get_bat()
{
    local datafile=$datadir/bat.rrd
    local powerdir=/sys/class/power_supply
    if [ -d $powerdir ]; then
        if [ ! -e $datafile ]; then
            rrdtool create $datafile --step 60 \
                DS:ac:GAUGE:120:0:U \
                DS:energy_now:GAUGE:120:0:U \
                DS:energy_speed:DERIVE:120:U:U \
                DS:voltage_now:GAUGE:120:U:U \
                DS:voltage_speed:DERIVE:120:U:U \
                RRA:MAX:0.5:1:1500 \
                RRA:AVERAGE:0.5:60:24
        fi
        local ac=$(cat $powerdir/AC0/online)
        local energy_now=$(cat $powerdir/BAT0/energy_now)
        local voltage_now=$(cat $powerdir/BAT0/voltage_now)
        local output=N:$ac:$energy_now:$energy_now:$voltage_now:$voltage_now

        log "bat" $output

        rrdtool update $datafile \
            --template ac:energy_now:energy_speed:voltage_now:voltage_speed \
            $output
    fi
}

get_mem
get_bat
get_net
