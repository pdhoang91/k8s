#!/bin/bash

# This script automates the installation and configuration of Docker and Kubernetes on CentOS.

# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Update the system
yum update -y

# Install necessary packages
yum install -y yum-utils device-mapper-persistent-data lvm2

# Add Docker repository
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Install Docker
yum install docker-ce-18.06.2.ce -y

# Add current user to docker group
usermod -aG docker $(whoami)

# Create Docker daemon configuration
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

# Restart Docker
systemctl enable docker.service
systemctl daemon-reload
systemctl restart docker

# Disable SELinux
setenforce 0
sed -i --follow-symlinks 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux

# Disable Firewall
systemctl disable firewalld >/dev/null 2>&1
systemctl stop firewalld

# Configure sysctl parameters
cat >> /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system >/dev/null 2>&1

# Deactivate swap
sed -i '/swap/d' /etc/fstab
swapoff -a

# Add Kubernetes repository
cat >> /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# Install Kubernetes components
yum install -y -q kubeadm kubelet kubectl

# Enable and start kubelet service
systemctl enable kubelet
systemctl start kubelet

# Configure NetworkManager for Calico networking
cat >> /etc/NetworkManager/conf.d/calico.conf <<EOF
[keyfile]
unmanaged-devices=interface-name:cali*;interface-name:tunl*
EOF

# Restart NetworkManager
systemctl restart NetworkManager

# All steps completed
echo "Setup completed successfully!"
