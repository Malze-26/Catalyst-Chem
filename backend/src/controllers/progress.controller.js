const prisma = require('../config/db');

const getUserProgress = async (req, res, next) => {
  try {
    const userId = req.user.id;

    const progressRecords = await prisma.userProgress.findMany({
      where: { user_id: userId },
      include: {
        topic: { select: { id: true, title: true, board: true, level: true } }
      },
      orderBy: { completed_at: 'desc' }
    });

    res.status(200).json({ success: true, data: progressRecords });
  } catch (error) {
    next(error);
  }
};

module.exports = { getUserProgress };
