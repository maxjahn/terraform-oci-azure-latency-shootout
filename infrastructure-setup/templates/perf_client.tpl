#cloud-config
package_upgrade: true
packages:
  - qperf
  - iperf
  - iperf3
runcmd:
  # Run firewall commands to open iperf and iperf3 ports
  - firewall-offline-cmd --zone=public --add-port=5001/tcp --add-port=5001/udp
  - firewall-offline-cmd --zone=public --add-port=5001/tcp --add-port=5101/udp
  - firewall-offline-cmd --zone=public --add-port=5201/tcp --add-port=5201/udp
  # restart firewalld
  - systemctl restart firewalld
