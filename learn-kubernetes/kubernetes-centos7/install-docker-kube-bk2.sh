#!/bin/bash

# This script provides steps to troubleshoot and resolve issues related to the container runtime.

# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Stop kubelet before making changes
systemctl stop kubelet

# Remove Docker and Containerd
yum remove -y docker-ce
rm -rf /var/lib/docker
rm -rf /var/run/docker
rm -rf /etc/docker

# Remove Containerd
yum remove -y containerd.io
rm -rf /var/lib/containerd

# Install Docker and Containerd
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce-18.06.2.ce
systemctl start docker

# Install Containerd
yum install -y https://download.docker.com/linux/centos/7/x86_64/stable/Packages/containerd.io-1.4.9-3.1.el7.x86_64.rpm
systemctl start containerd

# Restart kubelet
systemctl start kubelet

# Check Docker and Containerd status
systemctl status docker
systemctl status containerd

# Retry kubeadm init command
kubeadm init --apiserver-advertise-address=172.16.10.100 --pod-network-cidr=192.168.0.0/16
