#cloud-config
package_upgrade: true
packages:
  - qperf
  - iperf
  - iperf3
runcmd:
  # Run firewall commands to open iperf, qperf and iperf3 ports
  - firewall-offline-cmd --zone=public --add-port=5001/tcp --add-port=5001/udp
  - firewall-offline-cmd --zone=public --add-port=19765/tcp --add-port=19766/tcp --add-port=19765/udp --add-port=19766/udp 
  - firewall-offline-cmd --zone=public --add-port=5201/tcp --add-port=5201/udp
  # restart firewalld
  - systemctl restart firewalld
  - iperf3 -s -D -J --logfile /tmp/iperf3.json
  - nohup qperf &
