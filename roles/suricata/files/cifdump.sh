#!/bin/bash

timestamp=$(date +"%Y%m%d%H%M")
exdir='/var/www/cif'

count=3
save_bro_feeds()
{
        for i in {1..3}; do
                /opt/cif/bin/cif -C /root/.cif -q "$1" -c "$2" -p "$3" > "$4".tmp."$timestamp";
                if [[ $(find "$4".tmp."$timestamp" -type f -size +4096c 2>/dev/null) ]]; then
                        mv "$4".tmp."$timestamp" "$4"
                        break;
                fi;
        done
}

out_type='bro'
save_bro_feeds 'infrastructure/botnet' 65 "$out_type" "$exdir"/cif.ip.infrastructure.botnet.65.intel
save_bro_feeds 'infrastructure/malware' 85 "$out_type" "$exdir"/cif.ip.infrastructure.malware.85.intel
save_bro_feeds 'domain/botnet' 65 "$out_type" "$exdir"/cif.dns.domain.botnet.65.intel
save_bro_feeds 'domain/malware' 85 "$out_type" "$exdir"/cif.dns.domain.malware.85.intel
save_bro_feeds 'url/botnet' 85 "$out_type" "$exdir"/cif.http.url.botnet.85.intel
save_bro_feeds 'url/malware' 85 "$out_type" "$exdir"/cif.http.url.malware.85.intel
save_bro_feeds 'url/phishing' 85 "$out_type" "$exdir"/cif.http.url.phishing.85.intel

# need taps before installed to check baseline performance.
# cif@cifserver1:~$ cif -c 65 -q infrastructure/suspicious | wc -l
# 664
# cif@cifserver1:~$ cif -c 65 -q infrastructure/spam | wc -l
# 2668
# cif@cifserver1:~$ cif -c 65 -q infrastructure/malware | wc -l
# 11050
# cif@cifserver1:~$ cif -c 65 -q domain/malware | wc -l
# 13437
# cif -c 65 -q malware/md5 -p csv and parse it later

#/opt/cif/bin/cif -C /root/.cif -q infrastructure/botnet -c 65 -p bro > $exdir/cif.ip.infrastructure.botnet.65.intel
#/opt/cif/bin/cif -C /root/.cif -q infrastructure/malware -c 85 -p bro > $exdir/cif.ip.infrastructure.malware.85.intel
#/opt/cif/bin/cif -C /root/.cif -q domain/botnet -c 65 -p bro > $exdir/cif.dns.domain.botnet.65.intel
#/opt/cif/bin/cif -C /root/.cif -q domain/malware -c 85 -p bro > $exdir/cif.dns.domain.malware.85.intel
#/opt/cif/bin/cif -C /root/.cif -q url/botnet -c 85 -p bro > $exdir/cif.http.url.botnet.85.intel
#/opt/cif/bin/cif -C /root/.cif -q url/malware -c 85 -p bro > $exdir/cif.http.url.malware.85.intel
#/opt/cif/bin/cif -C /root/.cif -q url/phishing -c 85 -p bro > $exdir/cif.http.url.phishing.85.intel

sudo chown root:root "$exdir"/cif.*.intel
sudo chmod 0644 "$exdir"/cif.*.intel

