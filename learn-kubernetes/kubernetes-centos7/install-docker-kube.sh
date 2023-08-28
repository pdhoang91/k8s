#!/bin/bash

# Cập nhật 08/2023

#Step 1: Pre-requisites
#1.a.. Check the OS, Hardware Configurations & Network connectivity
#1.b.. Turn off the swap & firewall
swapoff -a
systemctl stop firewalld
systemctl disable firewalld

#Step 2. Configure the local IP tables to see the Bridged Traffic
#2.a.. Enable the bridged traffic
lsmod | grep br_netfilter
modprobe br_netfilter

#2.b.. Copy the below contents in this file.. /etc/modules-load.d/k8s.conf
#Content:
#br_netfilter
touch /etc/modules-load.d/k8s.conf
cat >>/etc/modules-load.d/k8s.conf<<EOF
br_netfilter
EOF

#2.c.. Copy the below contents in this file.. /etc/sysctl.d/k8s.conf
#Content:
#net.bridge.bridge-nf-call-ip6tables = 1
#net.bridge.bridge-nf-call-iptables = 1
touch /etc/sysctl.d/k8s.conf
cat >>/etc/sysctl.d/k8s.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sysctl --system

#Step 3. Install Docker as a Container RUNTIME
# Cai dat Docker
yum update
yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-lo  grotate docker-logrotate docker-engine
yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce docker-ce-cli containerd.io


#Step 4. Configure Docker Daemon for cgroups management & Start Docker
## Create /etc/docker directory.
mkdir /etc/docker

# Setup daemon.
cat >>/etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

#daemon-reload
systemctl daemon-reload
systemctl restart docker
systemctl enable docker
systemctl status docker

cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

# cat >>/etc/sysctl.d/kubernetes.conf<<EOF
# net.bridge.bridge-nf-call-ip6tables = 1
# net.bridge.bridge-nf-call-iptables = 1
# EOF

sysctl --system >/dev/null 2>&1

#Step 5. Install kubeadm, kubectl, kubelet
#5.a.. Copy the below contents in this file.. /etc/yum.repos.d/kubernetes.repo
# cat >>/etc/yum.repos.d/kubernetes.repo<<EOF
# [kubernetes]
# name=Kubernetes
# baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
# enabled=1
# gpgcheck=1
# repo_gpgcheck=1
# gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-pa  ckage-key.gpg
# exclude=kubelet kubeadm kubectl
# EOF

cat >/etc/yum.repos.d/kubernetes.repo<<EOF
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

#5.b.. Set SELinux in permissive mode (effectively disabling it)
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
#yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
yum install -y kubelet kubeadm kubectl
#sudo systemctl enable --now kubelet
systemctl enable kubelet && systemctl start kubelet

cat >/etc/containerd/config.toml<<EOF
#   Copyright 2018-2022 Docker Inc.

#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at

#       http://www.apache.org/licenses/LICENSE-2.0

#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

enabled_plugins = ["cri"]
[plugins."io.containerd.grpc.v1.cri".containerd]
  endpoint = "unix:///var/run/containerd/containerd.sock"

#root = "/var/lib/containerd"
#state = "/run/containerd"
#subreaper = true
#oom_score = 0

#[grpc]
#  address = "/run/containerd/containerd.sock"
#  uid = 0
#  gid = 0

#[debug]
#  address = "/run/containerd/debug.sock"
#  uid = 0
#  gid = 0
#  level = "info"
EOF



cat >>/etc/crictl.yaml<<EOF
runtime-endpoint: "unix:///run/containerd/containerd.sock"
timeout: 0
debug: false
EOF


# Configure NetworkManager before attempting to use Calico networking.
cat >>/etc/NetworkManager/conf.d/calico.conf<<EOF
[keyfile]
unmanaged-devices=interface-name:cali*;interface-name:tunl*
EOF

systemctl restart containerd


#kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=172.16.10.100

#mkdir -p $HOME/.kube
#sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
#sudo chown $(id -u):$(id -g) $HOME/.kube/config

#kubectl apply -f https://docs.projectcalico.org/v3.10/manifests/calico.yaml

# Thông tin cluster
#kubectl cluster-info
# Các node trong cluster
#kubectl get nodes
# Các pod đang chạy trong tất cả các namespace
#kubectl get pods -A

#kubeadm token create --print-join-command

#https://www.youtube.com/watch?v=Ro2qeYeisZQ
#https://xuanthulab.net/gioi-thieu-va-cai-dat-kubernetes-cluster.html
#https://www.youtube.com/watch?v=yOBeQNGX278&list=PLwJr0JSP7i8D-QS50lYsXpAg-jYoqxMVy