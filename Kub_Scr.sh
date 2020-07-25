#!/bin/bash


#Set Hostname on Nodes
echo "Enter Your Master Full Name"
read mastername

echo "Enter Your Master IP"
read masterip

echo "
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
$masterip   $mastername
" > hosts

sudo hostnamectl set-hostname $mastername


echo "Enter number of Nodes"
read number

for i in $(seq 1 $number)
do

echo "Enter Your Worker Full Name"
read workername

echo "
#!/bin/bash
echo 'Enter Your ====This===== Worker Full Name Again'
read workername
sudo hostnamectl set-hostname $workername
" > worker_scr.sh

echo "Enter Your worker IP "
read ip

ssh-keygen -t rsa
ssh root@$ip mkdir -p .ssh
cat /root/.ssh/id_rsa.pub | ssh root@$ip 'cat >> .ssh/authorized_keys'
ssh root@$ip "chmod 700 .ssh; chmod 640 .ssh/authorized_keys"

echo "
$ip   $workername
" >> hosts

scp ./worker_scr.sh root@$ip:./worker_scr.sh

ssh -t root@$ip "bash worker_scr.sh"

done
echo "Worker Host Name Changed "

cat hosts  > /etc/hosts

#Insatll Docker:

source ./install_docker.sh



#Configure Kubernetes Repository

source ./install_Kuba.sh

#Update Iptables Settings

source ./swap_IP.sh

#Build the cluster
sudo kubeadm init --pod-network-cidr=10.48.0.0/14 --apiserver-advertise-address=0.0.0.0 --apiserver-bind-port=8443 --service-cidr=10.2.0.0/20 --kubernetes-version=v1.14.10 > Join

echo "
#!/bin/bash
" > join.sh
tail -n 2  Join >> join.sh




#create user

sudo useradd k8s
sudo passwd k8s
echo "k8s ALL=(ALL) NOPASSWD: ALL" >> /etc/sudores
#sudo su - k8s

#Setup kubeconfig

mkdir -p $HOME/.kube

sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl get nodes

#join worker nodes
##

#Workers Script

echo "Enter number of Nodes"
read number

for i in $(seq 1 $number)
do

echo "Enter Node IP "
read ip

scp ./hosts root@$ip:./hosts

ssh -t root@$ip "cat hosts  > /etc/hosts"


scp ./install_docker.sh root@$ip:./install_docker.sh


ssh -t root@$ip "bash install_docker.sh"

scp ./install_Kuba.sh root@$ip:./install_Kuba.sh

ssh -t root@$ip "bash install_Kuba.sh"


echo "
#!/bin/bash
systemctl stop firewalld
systemctl disable firewalld
" > worker_scr.sh

scp ./worker_scr.sh root@$ip:./worker_scr.sh

ssh -t root@$ip "bash worker_scr.sh"


scp ./swap_IP.sh root@$ip:./swap_IP.sh


ssh -t root@$ip "bash swap_IP.sh"

scp ./join.sh root@$ip:./join.sh


ssh -t root@$ip "bash join.sh"

done
echo " Kubernetes Installed on The Nodes"

kubectl get nodes
kubectl version

#Install Funnle network solutin

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.12.0/Documentation/kube-flannel.yml
kubectl get nodes
kubectl get pods --all-namespaces

