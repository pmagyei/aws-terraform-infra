AWS_Networking_CI 

Project Overview

This project build a Virtual Private Network on AWS with public and private subnets that supports Dual Stack (IPv4 and IPv6), the learning goal is to demonstrate routing behaviour between each subnet and undesrstand how oacket are forwarded from: NAT Gateway, Egress-only gateway and IGW.

The project uses Terraform for encoding the AWS Networking Infrastructure, GitHub for version control, GitHub Actions to implement continous Integration to automate the deployment pipeline.

There are no advanced abstractions such as ASG,Load balancers.


Architecture Diagram

Components

VPC
Defines the network boundary:
10.10.10.0/25
Controlled IP addressing and isolation of resources
If misconfigured routing breaks 

Public Subnets
Associated to public route table that routes traffic to the "IGW"
Allows direct internet connectivity
If misconfigured: compute resources cannot reach intenet directly 

Private Subnets
IPv4 traffic has no direct route to "IGW", IPv4 traffic routed to NAT
IPv6 traffic has direct route to "Egress-only-IGW". IPv6 traffic routed to "Egress-only-IGW"
If misconfigured it becomes publicly accessible or loses outbound access

Internet Gateway
Enables communication between VPC and internet
Public Subnets requie IGW for public internet connectivity
If missing: no internet access for IPv4 traffic

Egress-Only-IGW
Enables IPv6 communication between VPC and internet
If missing: no internet access for IPv6 traffic

Nat Gateway
Provides outbound internet access for private subnets
Translates unroutable RF1918 address into routable publip IP
If missing, private instances cannot reach internet through IPv4

Route Tables
Controls packet routing and forwarding decisions
Public: 0.0.0.0/0 to IGW
::/0 to E_IGW
Private: 0.0.0.0/0 to NAT
::/0 to E_IGW

If misconfigured: traffic is misourted or dropped

Route table associations

Binds subnets to route tables
Defines routingn behaviour for wach subnet

If misconfigured: public/private classification breaks.


Network Flows

1) Public Subnet to Internet
instance sends packet to igw
iwg forwards to internet

2) Private Subnet to Internet
IPv4: Instance sends packet
Route table routes traffic to NAT
NAT translates RFC1918 addres, traffic forwarded through IGW

IPv6: Instance sends packet
Route table routes traffic to "Egress only IGW"
"Egress only IGW" forward traffic to internet

3) Internal Communication
Subnet A to Subnet B
uses implicit VPC routing(local)

