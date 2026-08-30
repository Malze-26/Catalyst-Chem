const prisma = require('../config/db');

const getQuestionsByTopic = async (req, res, next) => {
  try {
    const { topicId } = req.params;

    const rawQuestions = await prisma.question.findMany({
      where: { topic_id: topicId },
      select: {
        id: true,
        topic_id: true,
        question_text: true,
        options: true,
        correct_option: true,
        explanation: true
      }
    });

    const questions = rawQuestions.map((q) => ({
      ...q,
      options: typeof q.options === 'string' ? JSON.parse(q.options) : q.options
    }));

    res.status(200).json({ success: true, data: questions });
  } catch (error) {
    next(error);
  }
};

const submitQuiz = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { topic_id, score } = req.body;

    if (!topic_id || score === undefined) {
      return res.status(400).json({ success: false, message: 'topic_id and score are required' });
    }

    const progress = await prisma.userProgress.create({
      data: {
        user_id: userId,
        topic_id,
        score: parseFloat(score)
      }
    });

    res.status(201).json({
      success: true,
      message: 'Quiz result saved successfully',
      data: progress
    });
  } catch (error) {
    next(error);
  }
};

module.exports = { getQuestionsByTopic, submitQuiz };
