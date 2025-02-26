# Join-Ubuntu-Debian-To-Active-Directory-AD-domain
Question: How can I join Ubuntu 22.04|20.04|18.04 to Windows domain?, can I join Debian to Active Directory domain?. This article has been written to show you how to use realmd to join Ubuntu / Debian Linux server or Desktop to an Active Directory domain.

## **1. Điều kiện cần**
- Máy Ubuntu có kết nối mạng với **Domain Controller (DC)**.
- **DNS trên Ubuntu** phải trỏ về **IP của DC**:
  ```bash
  nslookup hanlab.com
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

## **3. Kiểm tra domain**
```bash
realm discover hanlab.com
```
Nếu domain hiển thị thông tin hợp lệ, tiếp tục bước tiếp theo.

---

## **4. Join Ubuntu vào AD**
```bash
sudo realm join hanlab.com -U Administrator
```
Nhập mật khẩu **Administrator** khi được yêu cầu.

🔹 **Kiểm tra join thành công:**
```bash
realm list
```

---

## **5. Xác thực Kerberos**
1. **Lấy vé Kerberos:**
   ```bash
   kinit Administrator@HANLAB.COM
   ```
2. **Kiểm tra vé:**
   ```bash
   klist
   ```

---

## **6. Cấu hình đăng nhập người dùng AD trên Ubuntu**
1. **Chỉnh sửa cấu hình SSSD:**
   ```bash
   sudo nano /etc/sssd/sssd.conf
   ```
   Thêm nội dung sau:
   ```ini
   [sssd]
   services = nss, pam, ssh
   config_file_version = 2
   domains = hanlab.com

   [domain/hanlab.com]
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
su - Administrator@hanlab.com
```

---

## **📌 Kết luận**
✔ **Join Ubuntu vào AD** bằng `realm join`.
✔ **Xác thực với Kerberos** bằng `kinit`.
✔ **Cấu hình SSSD để cho phép đăng nhập**.

🚀 **Sau các bước trên, máy Ubuntu đã là thành viên của AD và có thể đăng nhập bằng tài khoản AD!**

