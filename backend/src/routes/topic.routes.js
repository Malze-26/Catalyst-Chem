const express = require('express');
const { getTopics } = require('../controllers/topic.controller');
const { authenticateJWT } = require('../middlewares/auth.middleware');
const router = express.Router();

router.get('/', authenticateJWT, getTopics);

module.exports = router;
