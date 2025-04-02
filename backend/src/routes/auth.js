const express = require('express');
const { register, login, getProfile } = require('../controllers/authController');
const authenticateToken = require('../middleware/auth');

const router = express.Router();

// Register new user
router.post('/register', register);

// Login
router.post('/login', login);

// Get profile (protected route)
router.get('/profile', authenticateToken, getProfile);

module.exports = router; 