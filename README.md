# Join-Ubuntu-Debian-To-Active-Directory-AD-domain
Question: How can I join Ubuntu 22.04|20.04|18.04 to Windows domain?, can I join Debian to Active Directory domain?. This article has been written to show you how to use realmd to join Ubuntu / Debian Linux server or Desktop to an Active Directory domain.

# Join Ubuntu vào Active Directory (AD) trên Windows Server

## **1. Điều kiện cần**
- Máy Ubuntu có kết nối mạng với **Domain Controller (DC)**.
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
sudo apt install realmd sssd sssd-tools samba-common-bin oddjob oddjob-mkhomedir adcli -y
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
    permitted_enctypes = aes256-cts-hmac-sha1-96 aes128-cts-hmac-sha1-96 rc4-hmac

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

---

## **66. Cấu hình đăng nhập người dùng AD trên Ubuntu**
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

## **7. Đăng nhập bằng tài khoản AD trên Ubuntu**
```bash
su - Administrator@yourdomain.com
```

---


🚀 **Sau các bước trên, máy Ubuntu đã là thành viên của AD và có thể đăng nhập bằng tài khoản AD!**

