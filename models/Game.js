const { Sequelize, DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const Game = sequelize.define('Game', {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true
    },
    winner: {
      type: DataTypes.STRING,
      allowNull: false,
      validate: {
        isIn: [['X', 'O', 'draw']]
      }
    },
    moves: {
      type: DataTypes.JSON,
      allowNull: false,
      defaultValue: []
    },
    finalBoard: {
      type: DataTypes.JSON,
      allowNull: false,
      defaultValue: Array(9).fill('')
    },
    duration: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 0
    },
    createdAt: {
      type: DataTypes.DATE,
      defaultValue: Sequelize.NOW
    },
    updatedAt: {
      type: DataTypes.DATE,
      defaultValue: Sequelize.NOW
    }
  }, {
    tableName: 'games',
    timestamps: true
  });

  return Game;
};
