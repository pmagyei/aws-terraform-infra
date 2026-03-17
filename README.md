AWS_Networking_CI 

Project Overview

This project build a Virtual Private Network on AWS with public and private subnets that supports Dual Stack (IPv4 and IPv6), the learning goal is to demonstrate routing behaviour between each subnet and understand how packets are forwarded from: NAT Gateway, Egress-only gateway and IGW.

The project uses Terraform for encoding the AWS Networking Infrastructure, GitHub for version control, GitHub Actions to implement continous Integration to automate the deployment pipeline.

There are no advanced abstractions such as ASG,Load balancers.


Architecture Diagram

Components

VPC:
Defines the network boundary:10.10.10.0/25
Enables IP addressing isolation
If misconfigured: overlapping CIDR breaks routing 

Public Subnets:
Associated to public route table that routes traffic to the "IGW"
Allows direct internet connectivity
If misconfigured: compute resources cannot reach intenet directly 

Private Subnets:
IPv4 traffic has no direct route to "IGW", IPv4 traffic routed to NAT
IPv6 traffic has direct route to "Egress-only-IGW". IPv6 traffic routed to "Egress-only-IGW"
If misconfigured it becomes publicly accessible or loses outbound access

Dual Stack IP protocol:
IPv4 traffic that's translated by NAT is forwarded to the IGW; 
IPv4 uses NAT

IPv6 traffic does not use NAT, instead it uses globally routable addresses.
Egress-only IGW blocks inbound traffic

Internet Gateway:
Enables communication between VPC and internet
Public Subnets requie IGW for public internet connectivity
If missing: no internet access for IPv4 traffic

Egress-Only-IGW:
Enables IPv6 communication between VPC and internet
If missing: no internet access for IPv6 traffic

Nat Gateway:
Placed in a public subnet, beacause it has dependacy in IGW to access/reach the internet
Provides outbound IPv4 access for private subnets
Performs address translation (RFC1918 to Public) 
If missing, private instances cannot reach internet through IPv4

Route Tables:
Controls packet routing and forwarding decisions
Public: 0.0.0.0/0 to IGW
::/0 to E_IGW
Private: 0.0.0.0/0 to NAT
::/0 to E_IGW

If misconfigured: traffic is misourted or dropped

Route table associations:

Binds subnets to route tables
Defines routingn behaviour for wach subnet
If misconfigured: public/private classification breaks.


Network Flow:

1) Public Subnet to Internet
Instance sends packet
Route table matches 0.0.0.0/0 to IGW
IGW forwards traffic to internet

2) Private Subnet to Internet
IPv4: Instance sends packet
Route table matches 0.0.0.0/0 to NAT
NAT translates source IP
Traffic forwarded VIA IGW

IPv6: Instance sends packet
Route table table matches ::/0 to "Egress only IGW" 
Traffic is forwarded outbound only

3) Internal Communication
Subnet A to Subnet B
uses implicit VPC routing(local)

Resource Dependecies: 
1) VPC

2) Subnets

3) Internet Gateway

4) Elastic IP

5) NAT Gateway

6) Route Tables

7) Route Tables Associations

Critical Dependac=ncy Examples:

NAT Gateway depends on:
Elastic IP
Public Subnet
Internet Gateway to be attached to the VPC

Private route depends on:
NAT Gateway Existing

Public route depends on:
IGW attached to VPC

Failure Cases

NAT without IGW attached to VPC: No outbound intenret

Route to NAT before NAT exists: Deployment fails

Wrong association: subnet behaves not as planned