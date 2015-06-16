# suricata and myricom
cap_name: p2p1
cap_type: myricom
nsm_role_suricata: true

#cap_name: p2p1
#cap_type: myricom
#bro_proc_num: 24

#nsm_role_bro: true
#cap_name: eth2
#nsm_role_pcap: true

# pf_ring and the office
#cap_name: eth5
#cap_type: pf_ring
#bro_proc_num: 6

# nsm server
#nsm_role_offices: true
#nsm_role_server: true

