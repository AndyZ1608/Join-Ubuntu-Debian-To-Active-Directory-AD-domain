# Join-Ubuntu-Debian-To-Active-Directory-AD-domain
Question: How can I join Ubuntu 22.04|20.04|18.04 to Windows domain?, can I join Debian to Active Directory domain?. This article has been written to show you how to use realmd to join Ubuntu / Debian Linux server or Desktop to an Active Directory domain.

# Join Ubuntu vào Active Directory (AD) trên Windows Server

## **1. Điều kiện cần**
- **Cấu hình hostname** trên Ubuntu:
  ```bash
  sudo hostnamectl set-hostname your_hostname@yourdomain.com
  ```
- **Cấu hình file `/etc/hosts`**:
  ```bash
  sudo nano /etc/hosts
  ```
  Thêm dòng:
  ```ini
  your_ip     your_hostname
  ```
- **Cấu hình NTP để đồng bộ thời gian với AD Server**:
  ```bash
  sudo timedatectl set-ntp true
  ```
- **DNS trên Ubuntu phải trỏ về IP của DC**:
  ```bash
  sudo nano /etc/resolv.conf
  ```
  Thêm dòng:
  ```ini
  nameserver your_ip
  search yourdomain.com
  ```
- Máy Ubuntu có kết nối mạng với **Domain Controller (DC)**.
  ```bash
  for port in 88 389 636 464 53 135 445; do nc -zv 10.10.9.2 $port; done
  ```
- **DNS trên Ubuntu** phải trỏ về **IP của DC**:
  ```bash
  nslookup yourdomain.com
  ```
- Các **port cần mở** trên Windows Server:
  - **88 (Kerberos)**
  - **389 (LDAP)**
  - **464 (Kerberos Password Change)**
  - **53 (DNS)**
  - **445 (SMB)**

---

## **2. Cài đặt các gói cần thiết**
```bash
sudo apt update
sudo apt install realmd sssd sssd-tools samba-common-bin oddjob oddjob-mkhomedir adcli krb5-user libpam-krb5 -y
```

---

## **3. Cấu hình Kerberos**
Mở file cấu hình Kerberos:
```bash
sudo nano /etc/krb5.conf
```
Thêm nội dung sau:
```ini
[libdefaults]
    default_realm = YOURDOMAIN.COM
    dns_lookup_realm = false
    dns_lookup_kdc = true
    ticket_lifetime = 24h
    renew_lifetime = 7d
    forwardable = true

[realms]
    YOURDOMAIN.COM = {
        kdc = your_ip
        admin_server = your_ip
        default_domain = yourdomain.com
    }

[domain_realm]
    .yourdomain.com = YOURDOMAIN.COM
    yourdomain.com = YOURDOMAIN.COM
```
Lưu file (`CTRL + X`, `Y`, `Enter`).

---

## **4. Kiểm tra domain**
```bash
realm discover yourdomain.com
```
Nếu domain hiển thị thông tin hợp lệ, tiếp tục bước tiếp theo.

---

## **5. Join Ubuntu vào AD**
```bash
sudo realm join yourdomain.com -U Administrator
```
Nhập mật khẩu **Administrator** khi được yêu cầu.

🔹 **Kiểm tra join thành công:**
```bash
realm list
```

---

## **6. Xác thực Kerberos**
1. **Lấy vé Kerberos:**
   ```bash
   kinit Administrator@YOURDOMAIN.COM
   ```
2. **Kiểm tra vé:**
   ```bash
   klist
   ```

---

## **7. Cấu hình đăng nhập người dùng AD trên Ubuntu**
1. **Chỉnh sửa cấu hình SSSD:**
   ```bash
   sudo nano /etc/sssd/sssd.conf
   ```
   Thêm nội dung sau:
   ```ini
   [sssd]
   services = nss, pam, ssh
   config_file_version = 2
   domains = yourdomain.com

   [domain/yourdomain.com]
   id_provider = ad
   access_provider = ad
   ```
   Lưu file (`CTRL + X`, `Y`, `Enter`).

2. **Khởi động lại dịch vụ:**
   ```bash
   sudo systemctl restart sssd
   ```

---

## **8. Đăng nhập bằng tài khoản AD trên Ubuntu**
```bash
su - Administrator@yourdomain.com
```

---

## **📌 Kết luận**
✔ **Join Ubuntu vào AD** bằng `realm join`.
✔ **Xác thực với Kerberos** bằng `kinit`.
✔ **Cấu hình SSSD để cho phép đăng nhập**.

🚀 **Sau các bước trên, máy Ubuntu đã là thành viên của AD và có thể đăng nhập bằng tài khoản AD!**

