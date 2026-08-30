const express = require('express');
const { getUserProgress } = require('../controllers/progress.controller');
const { authenticateJWT } = require('../middlewares/auth.middleware');
const router = express.Router();

router.get('/', authenticateJWT, getUserProgress);

module.exports = router;
