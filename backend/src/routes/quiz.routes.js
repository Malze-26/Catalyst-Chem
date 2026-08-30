const express = require('express');
const { getQuestionsByTopic, submitQuiz } = require('../controllers/quiz.controller');
const { authenticateJWT } = require('../middlewares/auth.middleware');
const router = express.Router();

router.get('/:topicId', authenticateJWT, getQuestionsByTopic);
router.post('/submit', authenticateJWT, submitQuiz);

module.exports = router;
