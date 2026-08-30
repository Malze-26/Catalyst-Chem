const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');

const prisma = new PrismaClient();

async function main() {
  console.log('Seeding ChemBridge Prep database...');

  // 1. Create a demo user
  const salt = await bcrypt.genSalt(10);
  const password_hash = await bcrypt.hash('password123', salt);

  const demoUser = await prisma.user.upsert({
    where: { email: 'student@chembridge.com' },
    update: {},
    create: {
      name: 'Alex Student',
      email: 'student@chembridge.com',
      password_hash,
      target_board: 'Edexcel',
    },
  });
  console.log(`Demo User created: ${demoUser.email} (password: password123)`);

  // 2. Create Topics for Edexcel
  const edexcelTopic1 = await prisma.topic.create({
    data: {
      board: 'Edexcel',
      level: 'IGCSE',
      title: 'Atomic Structure & Periodic Table',
      description: 'Fundamental particles, isotopes, and electron configurations across periods and groups.',
      questions: {
        create: [
          {
            question_text: 'Which subatomic particle has a relative mass of 1 and a relative charge of +1?',
            options: JSON.stringify(['Electron', 'Proton', 'Neutron', 'Positron']),
            correct_option: 1,
            explanation: 'Protons have a relative mass of 1 and a positive charge of +1. Neutrons have a mass of 1 and charge of 0, while electrons have almost 0 mass and a -1 charge.'
          },
          {
            question_text: 'What is the electronic configuration of a chlorine atom (Atomic Number = 17)?',
            options: JSON.stringify(['2, 8, 8', '2, 8, 7', '2, 7, 8', '2, 8, 6, 1']),
            correct_option: 1,
            explanation: 'Chlorine has 17 electrons: 2 in the first shell, 8 in the second, and 7 in the outermost valence shell (2,8,7).'
          },
          {
            question_text: 'Why do elements in the same group of the Periodic Table have similar chemical properties?',
            options: JSON.stringify([
              'They have the same number of electron shells',
              'They have the same atomic mass',
              'They have the same number of outer shell electrons',
              'They have identical boiling points'
            ]),
            correct_option: 2,
            explanation: 'Chemical properties are determined by the number of electrons in the outer valence shell.'
          }
        ]
      }
    }
  });

  const edexcelTopic2 = await prisma.topic.create({
    data: {
      board: 'Edexcel',
      level: 'IGCSE',
      title: 'Organic Chemistry: Hydrocarbons & Alkanes',
      description: 'Homologous series, structural isomerism, and fractional distillation of crude oil.',
      questions: {
        create: [
          {
            question_text: 'What is the general formula for alkanes?',
            options: JSON.stringify(['CnH2n', 'CnH2n+2', 'CnH2n-2', 'CnH2n+1OH']),
            correct_option: 1,
            explanation: 'Alkanes are saturated hydrocarbons conforming to CnH2n+2.'
          },
          {
            question_text: 'What type of reaction occurs when methane reacts with bromine in the presence of UV light?',
            options: JSON.stringify(['Addition', 'Free-radical substitution', 'Elimination', 'Esterification']),
            correct_option: 1,
            explanation: 'Methane undergoes free-radical substitution with halogens in the presence of ultraviolet light.'
          }
        ]
      }
    }
  });

  // 3. Create Topics for Cambridge
  const cambridgeTopic1 = await prisma.topic.create({
    data: {
      board: 'Cambridge',
      level: 'A_Level',
      title: 'Chemical Energetics & Enthalpy Changes',
      description: 'Hess Law cycles, lattice energy, and standard enthalpy of combustion & formation.',
      questions: {
        create: [
          {
            question_text: 'Which statement accurately describes standard enthalpy of formation (ΔHf°)?',
            options: JSON.stringify([
              'Enthalpy change when 1 mole of a compound is formed from its elements in standard states',
              'Enthalpy change when 1 mole of a substance is completely burned in oxygen',
              'Enthalpy change when 1 mole of water is formed from acid-base neutralization',
              'Enthalpy change when gaseous atoms are formed from 1 mole of compound'
            ]),
            correct_option: 0,
            explanation: 'ΔHf° is the enthalpy change when 1 mole of a compound is formed from its constituent elements in their standard states under standard conditions (298 K, 1 atm).'
          },
          {
            question_text: 'According to Hess’s Law, how does reaction pathway affect the total enthalpy change?',
            options: JSON.stringify([
              'A catalyzed pathway has a lower total enthalpy change',
              'The total enthalpy change is independent of the pathway taken',
              'Indirect pathways always release more thermal energy',
              'Enthalpy change doubles with two-step pathways'
            ]),
            correct_option: 1,
            explanation: 'Hess’s Law states that total enthalpy change for a reaction is independent of the route taken, as enthalpy is a state function.'
          }
        ]
      }
    }
  });

  // 4. Create Past Papers
  await prisma.pastPaper.createMany({
    data: [
      {
        board: 'Edexcel',
        year: 2023,
        paper_number: '1C (Chemistry)',
        pdf_url: 'https://qualifications.pearson.com/content/dam/pdf/International%20GCSE/Chemistry/2017/exam-materials/4CH1_1C_que_20230518.pdf'
      },
      {
        board: 'Edexcel',
        year: 2023,
        paper_number: '2C (Chemistry)',
        pdf_url: 'https://qualifications.pearson.com/content/dam/pdf/International%20GCSE/Chemistry/2017/exam-materials/4CH1_2C_que_20230612.pdf'
      },
      {
        board: 'Cambridge',
        year: 2023,
        paper_number: 'Paper 1 (Multiple Choice 9701/12)',
        pdf_url: 'https://papers.gceguide.com/A%20Levels/Chemistry%20(9701)/2023/9701_s23_qp_12.pdf'
      },
      {
        board: 'Cambridge',
        year: 2023,
        paper_number: 'Paper 2 (AS Level Structured 9701/22)',
        pdf_url: 'https://papers.gceguide.com/A%20Levels/Chemistry%20(9701)/2023/9701_s23_qp_22.pdf'
      }
    ]
  });

  // 5. Create initial progress for demo user
  await prisma.userProgress.create({
    data: {
      user_id: demoUser.id,
      topic_id: edexcelTopic1.id,
      score: 100.0,
    }
  });

  console.log('Database seeding completed successfully!');
}

main()
  .catch((e) => {
    console.error('Seeding error:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
