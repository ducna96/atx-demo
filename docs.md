System Architecture Description
Dự án này triển khai một hệ thống ứng dụng web hiện đại trên nền tảng AWS EKS, tập trung vào khả năng tự động mở rộng (Autoscaling), tối ưu hóa chi phí (Cost Optimization) và bảo mật (Security).

1. Thành phần hạ tầng (Infrastructure)
Hạ tầng được quản lý hoàn toàn bằng Terraform, đảm bảo tính nhất quán và khả năng tái sử dụng (Infrastructure as Code):


VPC (Virtual Private Cloud): Thiết kế với các Subnet công khai (Public) và riêng tư (Private) phân bổ trên nhiều Availability Zones (AZs) để đảm bảo High Availability (HA).


AWS EKS (Elastic Kubernetes Service): Cụm Kubernetes trung tâm quản lý các container ứng dụng.


Managed Node Group (Core): Nhóm các node quản lý bởi AWS, chạy các dịch vụ cốt lõi của hệ thống như Karpenter và Metrics Server.

2. Chiến lược Autoscaling & Quản lý Node (Karpenter)
Hệ thống sử dụng Karpenter v1 thay vì Cluster Autoscaler để đạt tốc độ giãn nở nhanh và linh hoạt hơn. Kiến trúc chia làm 2 NodePool chính để tối ưu chi phí:

On-Demand NodePool (Frontend/Ingress):


Loại tài nguyên: Sử dụng EC2 On-Demand (ví dụ: dòng t3, m5) để đảm bảo tính ổn định cao nhất cho cổng vào hệ thống.


Đối tượng: Chạy Nginx Ingress Controller.


Isolation: Sử dụng Taints/Tolerations (app=nginx) để đảm bảo không có ứng dụng khác chạy lẫn vào.

Spot NodePool (Application/Backend):


Loại tài nguyên: Sử dụng EC2 Spot Instances để tiết kiệm đến 70-90% chi phí.


Hệ điều hành: Sử dụng Bottlerocket OS (Bonus) - một OS chuyên dụng cho container, giúp tăng tốc độ boot và bảo mật hệ thống.


Đối tượng: Chạy ứng dụng Node.js.


Isolation: Sử dụng Taints/Tolerations (app=nodejs).

3. Luồng xử lý giao dịch (Traffic Flow)

Người dùng truy cập qua Domain đã được cấu hình TLS/SSL.


AWS Network Load Balancer (NLB): Tiếp nhận request và chuyển tiếp đến cụm Ingress Nginx.


Nginx Ingress Controller: Giải mã TLS (với chứng chỉ từ Let's Encrypt được quản lý bởi Cert-Manager) và định tuyến request dựa trên Hostname/Path.


NodeJS API: Xử lý request tại endpoint /time và trả về kết quả ISO date string.

4. Cơ chế tự động giãn nở (Autoscaling Logic)
Hệ thống triển khai cơ chế Autoscaling 2 lớp:


HPA (Horizontal Pod Autoscaler): Theo dõi mức tiêu thụ CPU thực tế của Pod NodeJS thông qua Metrics Server. Khi tải tăng (vượt ngưỡng 50% CPU), HPA sẽ tự động tăng số lượng Pod.


Karpenter Scaling: Khi số lượng Pod tăng vượt quá khả năng đáp ứng của các Node hiện tại, Karpenter phát hiện các Pod ở trạng thái Pending và ngay lập tức khởi tạo các Node Spot mới phù hợp với cấu hình máy yêu cầu.

5. Kiểm thử tải (Load Testing)
Sử dụng k6 để giả lập các kịch bản tăng tải thực tế:

Kịch bản tăng dần số lượng người dùng ảo (VUs) để quan sát điểm bùng phát của HPA.

Kiểm chứng khả năng tự động cấp phát Node Spot của Karpenter dưới áp lực tải cao.

6. Các điểm Bonus đã hoàn thành 


Hệ điều hành Bottlerocket: Tối ưu hóa thời gian khởi động Node và thu hẹp bề mặt tấn công bảo mật.


TLS/SSL tự động: Tích hợp Cert-Manager và Let's Encrypt cho HTTPS.


Mix Spot/On-Demand: Chiến lược chia tách tài nguyên thông minh để vừa tiết kiệm chi phí vừa đảm bảo độ tin cậy của Gateway.