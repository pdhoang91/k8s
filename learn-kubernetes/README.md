#!/bin/bash

# Path to the known_hosts file
known_hosts_file="$HOME/.ssh/known_hosts"

# IP or hostname of the remote server
remote_server="172.16.10.100"

# Remove the line for the remote server from known_hosts file
ssh-keygen -R "$remote_server"

echo "Removed entry for $remote_server from $known_hosts_file"

#good good
mv /etc/containerd/config.toml /root/config.toml.bak
systemctl restart containerd
#good good:

kubeadm init --apiserver-advertise-address=172.16.10.100 --pod-network-cidr=192.168.0.0/16
sudo kubeadm init --apiserver-advertise-address=172.16.10.100 --pod-network-cidr=192.168.0.0/16 --kubernetes-version=v1.21.3


sudo kubeadm init --apiserver-advertise-address=172.16.10.100 --pod-network-cidr=192.168.0.0/16 --kubernetes-version=v1.21.5

ssh -o C:\Users\NC\.ssh=/dev/null -o StrictHostKeyChecking=no

ssh-copy-id -i ~/.ssh/id_ecdsa root@172.16.10.100


# Check Docker and Containerd status
systemctl status docker
systemctl status containerd
systemctl status kubelet
systemctl status kubeadm


systemctl enable kubelet
systemctl start kubelet

kubeadm

kubeadm init --pod-network-cidr=10.10.0.0/16 --apiserver-advertise-address=172.16.10.100

kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=172.16.10.100




















	1  ls
    2  sudo systemctl stop firewalld
    3  sudo systemctl disable firewalld
    4  lsmod | grep br_netfilter
    5  sudo modprobe br_netfilter
    6  touch /etc/modules-load.d/k8s.conf
    7  vi /etc/modules-load.d/k8s.conf
		Content:
		br_netfilter
    9  touch /etc/sysctl.d/k8s.conf
   10  vi /etc/sysctl.d/k8s.conf
    Content:
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
   11  sudo sysctl --system
   12  sudo yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-lo  grotate docker-logrotate docker-engine
   13  sudo yum install -y yum-utils
   14  yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
   15  sudo yum install -y docker-ce docker-ce-cli containerd.io
   16  vi /etc/docker/daemon.json
     {
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
   17  sudo systemctl daemon-reload
   18  cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

   19  sysctl --system >/dev/null 2>&1
   20  cat >>/etc/yum.repos.d/kubernetes.repo<<EOF
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-pa  ckage-key.gpg
EOF

   21  sudo setenforce 0
   22  sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
   23  sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
   24  cat /etc/containerd/config.toml
   25  vi /etc/containerd/config.toml

enabled_plugins = ["cri"]
[plugins."io.containerd.grpc.v1.cri".containerd]
  endpoint = "unix:///var/run/containerd/containerd.sock"
  
   26  cat /root/config.toml.bak
   27  systemctl restart containerd
   28  kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=172.16.10.100





