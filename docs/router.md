### Router Setup

- Setup VLANs
  - 0
    - 10.0.0.0/16
  - 10
    - 10.10.0.0/16
    - 10.10.0.1 - 254 - static reserved
  - 20
    - 10.20.0.0/16
    - 10.20.0.1 - 254 - static reserved
  - 30
    - 10.30.0.0/16
    - 10.30.0.1 - 254 - static reserved
  - 100
    - 10.100.0.0/16
  - 200
    - 10.200.0.0/16

- Create firewall rules
  - allow vlan 10 -> any
  - allow vlan 10 -> internet
  - allow vlan 20 -> 10.10.0.11:53
  - allow vlan 20 -> vlan 10 (established/related)
  - allow vlan 20 -> internet
  - allow vlan 30 -> 10.10.0.11:53
  - allow vlan 30 -> vlan 10 (established/related)
  - allow vlan 100 -> internet
  - allow vlan 200 -> internet

- Setup dhcp
  - DNS: 10.10.0.11