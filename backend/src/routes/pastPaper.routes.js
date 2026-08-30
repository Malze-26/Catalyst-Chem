const express = require('express');
const { getPastPapers } = require('../controllers/pastPaper.controller');
const { authenticateJWT } = require('../middlewares/auth.middleware');
const router = express.Router();

router.get('/', authenticateJWT, getPastPapers);

module.exports = router;
