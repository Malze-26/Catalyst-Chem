const express = require('express');
const router = express.Router();

const authRoutes = require('./auth.routes');
const topicRoutes = require('./topic.routes');
const quizRoutes = require('./quiz.routes');
const pastPaperRoutes = require('./pastPaper.routes');
const progressRoutes = require('./progress.routes');

router.use('/auth', authRoutes);
router.use('/topics', topicRoutes);
router.use('/quizzes', quizRoutes);
router.use('/past-papers', pastPaperRoutes);
router.use('/progress', progressRoutes);

module.exports = router;
