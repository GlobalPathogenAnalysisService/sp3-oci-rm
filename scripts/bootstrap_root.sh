#!/bin/bash

set -x

cp /etc/motd /etc/motd.bkp
cat << EOF > /etc/motd
 
I have been modified by cloud-init at $(date)

EOF

sleep 60

cp -p /home/ubuntu/.bashrc /home/ubuntu/.bashrc.bkp
cat << EOF >> /home/ubuntu/.bashrc
 
# Default OCI CLI to use Instance Principal authentication
export OCI_CLI_AUTH=instance_principal
EOF

apt update -y

# Install jq

apt install -y jq

# Set sshd settings

sed -i 's/#MaxStartups.*/MaxStartups 50:100:300/g' /etc/ssh/sshd_config
sed -i 's/#MaxSessions.*/MaxSessions 300/g' /etc/ssh/sshd_config
systemctl restart sshd ssh

sleep 10

# Install NFS Server

apt-get install nfs-server -y

# Mount the volumes

mkdir /data /work

echo ${sp3_file_mount_ip} 

mount ${sp3_file_mount_ip}:/data /data 
mount ${sp3_file_mount_ip}:/work /work 

# Add to fstab

echo '${sp3_file_mount_ip}:/work /work nfs defaults 0 0' >> /etc/fstab
echo '${sp3_file_mount_ip}:/data /data nfs defaults 0 0' >> /etc/fstab

# Set mountd and nlockmgr port numbers

cp /etc/default/nfs-kernel-server /etc/default/nfs-kernel-server.orig
sed -i 's/RPCMOUNTDOPTS="--manage-gids"/RPCMOUNTDOPTS="--manage-gids -p 2000"/g' /etc/default/nfs-kernel-server

cat << EOF > /etc/sysctl.d/30-nfs-ports.conf
fs.nfs.nlm_tcpport = 2001
fs.nfs.nlm_udpport = 2002
EOF

sysctl --system
systemctl restart nfs-server.service

# Add NFS to iptables

iptables -I INPUT 6 -s 10.0.0.0/16 -p tcp -m multiport --ports 111,2000,2001,2049 -j ACCEPT
iptables -I INPUT 7 -s 10.0.0.0/16 -p udp -m multiport --ports 111,2000,2002,2049 -j ACCEPT
iptables -I INPUT 8 -s 10.0.0.0/16 -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
iptables -I INPUT 9 -s 10.0.0.0/16 -p tcp -m state --state NEW -m tcp --dport 443 -j ACCEPT
iptables-save > /etc/iptables/rules.v4