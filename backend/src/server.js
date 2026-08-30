require('dotenv').config();
const express = require('express');
const cors = require('cors');
const apiRoutes = require('./routes');
const { errorHandler } = require('./middlewares/error.middleware');

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

// Root route
app.get('/', (req, res) => {
  res.json({
    message: 'ChemBridge Prep API Server is Running!',
    healthCheck: '/health',
    apiBase: '/api'
  });
});

// API health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'ChemBridge Prep API', timestamp: new Date().toISOString() });
});

// API Routes
app.use('/api', apiRoutes);

// Centralized Error Handling
app.use(errorHandler);

if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, () => {
    console.log(`[ChemBridge Prep API] Server running on http://localhost:${PORT}`);
  });
}

module.exports = app;
