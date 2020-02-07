#cloud-config
package_upgrade: true
packages:
  - qperf
  - iperf
  - iperf3
  - sockperf
runcmd:
  # Run firewall commands to open iperf, iperf3, qperf and sockperf ports
  - firewall-offline-cmd --zone=public --add-port=5001/tcp --add-port=5001/udp
  - firewall-offline-cmd --zone=public --add-port=5101/tcp --add-port=5101/udp
  - firewall-offline-cmd --zone=public --add-port=5201/tcp --add-port=5201/udp
  - firewall-offline-cmd --zone=public --add-port=5055/tcp --add-port=5055/udp
  # restart firewalld
  - systemctl restart firewalld
