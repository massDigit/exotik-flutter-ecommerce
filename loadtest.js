import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  vus: 20,
  duration: '30s',
};

export default function () {
  const res = http.get('https://mds-m2-flutter-exotik-ecom.web.app/');
  check(res, {
    'status is 200': (r) => r.status === 200,
    'body size > 1000': (r) => r.body.length > 1000,
  });
  sleep(1);
}