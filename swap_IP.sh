#!/bin/bash

#Update Iptables Settings

echo "net.bridge.bridge-nf-call-iptables=1" | sudo tee -a /etc/sysctl.conf

sudo sysctl -p

sudo sysctl --system

#Disable SELinux

sudo setenforce 0

sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

#Disable SWAP: enable the kubelet to work properly as swap is slow

sudo sed -i '/swap/d' /etc/fstab

sudo swapoff -a

systemctl stop firewalld
systemctl disable firewalld


