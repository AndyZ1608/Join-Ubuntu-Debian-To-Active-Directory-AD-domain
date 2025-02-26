#!/bin/bash

# Biến cấu hình
DOMAIN="yourdomain.com"
REALM="YOURDOMAIN.COM"
DC_IP="your_ip"
HOSTNAME="your_hostname"

# Đặt hostname
sudo hostnamectl set-hostname $HOSTNAME

echo "[INFO] Cấu hình /etc/hosts"
echo "$DC_IP   $HOSTNAME.$DOMAIN   $HOSTNAME" | sudo tee -a /etc/hosts

# Cấu hình DNS
echo "[INFO] Cấu hình /etc/resolv.conf"
echo -e "nameserver $DC_IP\nsearch $DOMAIN" | sudo tee /etc/resolv.conf

# Cài đặt các gói cần thiết
echo "[INFO] Cài đặt các gói cần thiết"
sudo apt update
sudo apt install -y realmd sssd sssd-tools samba-common-bin oddjob oddjob-mkhomedir adcli krb5-user libpam-krb5

# Cấu hình Kerberos
echo "[INFO] Cấu hình Kerberos (/etc/krb5.conf)"
cat <<EOF | sudo tee /etc/krb5.conf
[libdefaults]
    default_realm = $REALM
    dns_lookup_realm = false
    dns_lookup_kdc = true
    ticket_lifetime = 24h
    renew_lifetime = 7d
    forwardable = true
    permitted_enctypes = aes256-cts-hmac-sha1-96 aes128-cts-hmac-sha1-96 rc4-hmac

[realms]
    $REALM = {
        kdc = $DC_IP
        admin_server = $DC_IP
        default_domain = $DOMAIN
    }

[domain_realm]
    .$DOMAIN = $REALM
    $DOMAIN = $REALM
EOF

# Kiểm tra domain
echo "[INFO] Kiểm tra domain"
realm discover $DOMAIN

# Join vào AD
echo "[INFO] Đang join vào domain $DOMAIN"
sudo realm join $DOMAIN -U Administrator

# Kiểm tra join thành công
realm list

# Xác thực Kerberos
echo "[INFO] Xác thực Kerberos"
kinit Administrator@$REALM
klist

# Cấu hình SSSD
echo "[INFO] Cấu hình SSSD (/etc/sssd/sssd.conf)"
cat <<EOF | sudo tee /etc/sssd/sssd.conf
[sssd]
services = nss, pam, ssh
config_file_version = 2
domains = $DOMAIN

[domain/$DOMAIN]
id_provider = ad
access_provider = ad
EOF

# Restart dịch vụ SSSD
sudo systemctl restart sssd

echo "[INFO] Hoàn thành! Máy đã được join vào domain $DOMAIN"
