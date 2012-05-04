#!/bin/bash

datadir=$HOME/.local/share/rrdb
datafile=$datadir/mem.rrd

if [ ! -e $datafile ]; then
    echo "Database hasn't been created"
    exit 1
fi

graph()
{
    local image=$datadir/"memory-$1.png"
    local starttime=$2
    local usedcolor='#0000ff'
    local buffercolor='#ff0000'
    local cachecolor='#00ff00'
    rrdtool graph $image \
        --slope-mode \
        --vertical-label "GB" \
        --start $starttime --end now \
        -w 786 -h 120 \
        DEF:used=$datafile:used:AVERAGE \
        DEF:buffers=$datafile:buffers:AVERAGE \
        DEF:cached=$datafile:cached:AVERAGE \
        "CDEF:rused=used,buffers,-,cached,-,1000000,/" \
        "CDEF:usedG=used,1000000,/" \
        "CDEF:buffersG=buffers,1000000,/" \
        "CDEF:cachedG=cached,1000000,/" \
        GPRINT:rused:LAST:"Cur\: %5.2lfG" \
        LINE1:rused$usedcolor:"In use" \
        LINE1:buffersG$buffercolor:"Buffers" \
        LINE1:cachedG$cachecolor:"Cached"
    echo "Wrote $image"
}


graph "hour" -3600
graph "day" -86400
graph "week" -604800
