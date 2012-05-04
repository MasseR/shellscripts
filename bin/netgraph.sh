#!/bin/bash

if [ -z $1 ]; then
    echo "Usage: stats interface"
    exit 1
fi
interface=$1

datadir=$HOME/.local/share/rrdb
datafile=$datadir/net.rrd

graph()
{
    local imagefile=$datadir/"net_${interface}_$1.png"
    local starttime=$2
    local incolor='#00FF00'
    local outcolor='#FF0000'
    rrdtool graph $imagefile \
        --start $starttime \
        --vertical-label "bytes" \
        DEF:bytes_in=$datafile:"${interface}_bytes_in":AVERAGE \
        DEF:bytes_out=$datafile:"${interface}_bytes_out":AVERAGE \
        "CDEF:bytes_in_kilo=bytes_in,1024,/" \
        "CDEF:bytes_out_kilo=bytes_out,1024,/" \
        GPRINT:bytes_in_kilo:MAX:"Max in\: %5.2lfkbps" \
        GPRINT:bytes_out_kilo:MAX:"Max out\: %5.2lfkbps" \
        LINE1:bytes_in$incolor:"Bytes in" \
        LINE1:bytes_out$outcolor:"Bytes out"
    echo "Wrote $imagefile"
}

graph_hourly()
{
    graph "hour" "-3600"
}

graph_daily()
{
    graph "day" "-86400"
}

graph_weekly()
{
    graph "week" "-604800"
}

graph_hourly
graph_daily
graph_weekly
