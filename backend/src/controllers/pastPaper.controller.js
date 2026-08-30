const prisma = require('../config/db');

const getPastPapers = async (req, res, next) => {
  try {
    const { board, year } = req.query;
    const filter = {};

    if (board) filter.board = board;
    if (year) filter.year = parseInt(year);

    const papers = await prisma.pastPaper.findMany({
      where: filter,
      orderBy: [{ year: 'desc' }, { paper_number: 'asc' }]
    });

    res.status(200).json({ success: true, data: papers });
  } catch (error) {
    next(error);
  }
};

module.exports = { getPastPapers };
