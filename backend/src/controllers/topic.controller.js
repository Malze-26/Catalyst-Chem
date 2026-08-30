const prisma = require('../config/db');

const getTopics = async (req, res, next) => {
  try {
    const { board, level } = req.query;
    const filter = {};

    if (board) filter.board = board;
    if (level) filter.level = level;

    const topics = await prisma.topic.findMany({
      where: filter,
      include: {
        _count: { select: { questions: true } }
      },
      orderBy: { title: 'asc' }
    });

    res.status(200).json({ success: true, data: topics });
  } catch (error) {
    next(error);
  }
};

module.exports = { getTopics };
