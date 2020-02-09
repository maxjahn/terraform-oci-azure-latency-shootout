# Environment for testing latency of Microsoft Azure - Oracle Cloud (OCI) interconnect

Here you can find terraform scripts for setting up an environment for testing the interconnect between Azure and OCI. These scripts were used for gathering [some results posted on my blog.](https://blog.maxjahn.at/2020/02/azure-oracle-cloud-oci-interconnect-network-latency-shootout/)

The various connection options you can evaluate with this environment include
- interconnect using FastConnect (OCI) and ExpressRoute (Azure)
- connect via public internet
- connect via VPN

![alt text](docs/interconnect_env.png "Environment")


Several VMs are set up with tooling for testing connectivity:
- iperf
- iperf3
- qperf
- sockperf
