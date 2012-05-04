/ppp0/ {
    ppp0_bytes_in = $2;
    ppp0_packets_in = $3;
    ppp0_bytes_out = $10;
    ppp0_packets_out = $11;
    }
/eth0/ {
    eth0_bytes_in = $2;
    eth0_packets_in = $3;
    eth0_bytes_out = $10;
    eth0_packets_out = $11;
    }
/eth1/ {
    eth1_bytes_in = $2;
    eth1_packets_in = $3;
    eth1_bytes_out = $10;
    eth1_packets_out = $11;
    }
/wlan0/ {
    wlan0_bytes_in = $2;
    wlan0_packets_in = $3;
    wlan0_bytes_out = $10;
    wlan0_packets_out = $11;
    }
END {
    ppp0_bytes_in    = ppp0_bytes_in    ? ppp0_bytes_in    : 0;
    ppp0_packets_in  = ppp0_packets_in  ? ppp0_packets_in  : 0;
    ppp0_bytes_out   = ppp0_bytes_out   ? ppp0_bytes_out   : 0;
    ppp0_packets_out = ppp0_packets_out ? ppp0_packets_out : 0;
    eth1_bytes_in    = eth1_bytes_in    ? eth1_bytes_in    : 0;
    eth1_packets_in  = eth1_packets_in  ? eth1_packets_in  : 0;
    eth1_bytes_out   = eth1_bytes_out   ? eth1_bytes_out   : 0;
    eth1_packets_out = eth1_packets_out ? eth1_packets_out : 0;
    print "N:" \
          ppp0_bytes_in ":" \
          ppp0_bytes_out ":" \
          ppp0_packets_in ":" \
          ppp0_packets_out ":" \
          eth0_bytes_in ":" \
          eth0_bytes_out ":" \
          eth0_packets_in ":" \
          eth0_packets_out ":" \
          eth1_bytes_in ":" \
          eth1_bytes_out ":" \
          eth1_packets_in ":" \
          eth1_packets_out ":" \
          wlan0_bytes_in ":" \
          wlan0_bytes_out ":" \
          wlan0_packets_in ":" \
          wlan0_packets_out;
    }
