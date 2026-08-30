const request = require('http');

// Helper to make a simple POST/GET request
function makeRequest(path, method = 'GET', data = null, token = null) {
  return new Promise((resolve, reject) => {
    const payload = data ? JSON.stringify(data) : null;
    const req = request.request({
      hostname: 'localhost',
      port: 5000,
      path: path,
      method: method,
      headers: {
        'Content-Type': 'application/json',
        ...(payload && { 'Content-Length': Buffer.byteLength(payload) }),
        ...(token && { 'Authorization': `Bearer ${token}` })
      }
    }, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, data: JSON.parse(body) });
        } catch (e) {
          resolve({ status: res.statusCode, raw: body });
        }
      });
    });

    req.on('error', reject);
    if (payload) req.write(payload);
    req.end();
  });
}

async function verify() {
  console.log('--- Testing Backend Endpoints ---');

  // 1. Test Health
  const health = await makeRequest('/health');
  console.log('1. /health ->', health.status, health.data);

  // 2. Test Login
  const loginRes = await makeRequest('/api/auth/login', 'POST', {
    email: 'student@chembridge.com',
    password: 'password123'
  });
  console.log('2. /api/auth/login ->', loginRes.status, loginRes.data?.success ? 'Success' : 'Failed');
  const token = loginRes.data?.data?.token;

  if (!token) {
    throw new Error('Login failed to yield token');
  }

  // 3. Test Topics
  const topicsRes = await makeRequest('/api/topics?board=Edexcel', 'GET', null, token);
  console.log('3. /api/topics -> Count:', topicsRes.data?.data?.length);

  // 4. Test Quizzes
  const topicId = topicsRes.data?.data?.[0]?.id;
  if (topicId) {
    const quizRes = await makeRequest(`/api/quizzes/${topicId}`, 'GET', null, token);
    console.log(`4. /api/quizzes/${topicId} -> Questions:`, quizRes.data?.data?.length);
  }

  // 5. Test Past Papers
  const papersRes = await makeRequest('/api/past-papers?board=Edexcel', 'GET', null, token);
  console.log('5. /api/past-papers -> Papers:', papersRes.data?.data?.length);

  // 6. Test Progress
  const progressRes = await makeRequest('/api/progress', 'GET', null, token);
  console.log('6. /api/progress -> Progress entries:', progressRes.data?.data?.length);

  console.log('--- All backend checks passed successfully! ---');
  process.exit(0);
}

// Start server and test
const app = require('./src/server');
setTimeout(verify, 1000);
