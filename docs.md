# 🏗️ System Architecture & Implementation Guide

Tài liệu này mô tả kiến trúc hạ tầng và quy trình triển khai ứng dụng NodeJS trên AWS EKS, sử dụng Karpenter để tối ưu hóa việc cấp phát tài nguyên và Cert-Manager để quản lý chứng chỉ bảo mật.

---

## 1. Tổng quan kiến trúc (High-Level Architecture)

Hệ thống được thiết kế theo mô hình **Cloud-Native**, tập trung vào khả năng tự động hóa hoàn toàn từ khâu cấp phát hạ tầng đến quản lý vòng đời ứng dụng.

### Sơ đồ luồng xử lý:
1. **Request:** Người dùng truy cập qua HTTPS (Port 443).
2. **Ingress:** Nginx Ingress Controller (chạy trên Node On-Demand) tiếp nhận request.
3. **SSL/TLS:** Chứng chỉ được tự động cấp phát bởi Let's Encrypt thông qua Cert-Manager.
4. **App:** Request được chuyển hướng đến Service NodeJS (chạy trên Node Spot).
5. **Autoscale:** Khi tải tăng, HPA tăng số lượng Pod -> Karpenter tăng số lượng Node Spot.

[Image of EKS architecture with Karpenter and Nginx Ingress Controller]

---

## 2. Chi tiết các thành phần hạ tầng

### 🔹 2.1. Quản lý Node với Karpenter (v1)
Chúng ta sử dụng chiến thuật **Mixed Instance Strategy** để cân bằng giữa chi phí và độ ổn định:

| NodePool | Loại Instance | OS | Tầng (Tier) | Mục đích |
| :--- | :--- | :--- | :--- | :--- |
| **nginx-od** | On-Demand | AL2023 | Frontend | Chạy Ingress Controller, yêu cầu ổn định 100%. |
| **nodejs-spot**| Spot | Bottlerocket | Backend | Chạy NodeJS App, tối ưu chi phí (tiết kiệm ~70%). |

* **Bottlerocket OS