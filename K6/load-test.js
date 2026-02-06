import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  stages: [
    { duration: '30s', target: 50 },  // Tăng nhanh lên 50 user
    { duration: '2m', target: 200 }, // Bơm mạnh lên 200 user để ép CPU lên cao
    { duration: '1m', target: 0 },   // Giảm tải về 0
  ],
};

export default function () {
  // Thay domain thật của bạn vào đây
  http.get('https://atx.lovelydevops.xyz/time');
  sleep(0.1); // Nghỉ 0.1s mỗi request
}