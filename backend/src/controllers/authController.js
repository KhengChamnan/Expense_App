const jwt = require('jsonwebtoken');
const User = require('../models/User');
const dotenv = require('dotenv');

dotenv.config();

const JWT_SECRET = process.env.JWT_SECRET;

const register = async (req, res) => {
  try {
    const { username, email, password } = req.body;

    // Validate input
    if (!username || !email || !password) {
      return res.status(400).json({ error: 'All fields are required' });
    }

    // Check if user already exists
    const existingUserByUsername = await User.findByUsername(username);
    if (existingUserByUsername) {
      return res.status(400).json({ error: 'Username already exists' });
    }

    const existingUserByEmail = await User.findByEmail(email);
    if (existingUserByEmail) {
      return res.status(400).json({ error: 'Email already exists' });
    }

    // Create new user
    const newUser = await User.create(username, email, password);

    // Generate JWT
    const token = jwt.sign(
      { id: newUser.id, username: newUser.username },
      JWT_SECRET,
      { expiresIn: '24h' }
    );

    res.status(201).json({
      message: 'User registered successfully',
      token,
      user: {
        id: newUser.id,
        username: newUser.username,
        email: newUser.email
      }
    });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({ error: 'Registration failed' });
  }
};

const login = async (req, res) => {
  try {
    const { username, email, password, isEmail } = req.body;
    
    // Validate input based on login type
    if (isEmail === true) {
      if (!email || !password) {
        return res.status(400).json({ error: 'Email and password are required' });
      }
    } else {
      if (!username || !password) {
        return res.status(400).json({ error: 'Username and password are required' });
      }
    }

    // Find user based on login method
    let user;
    if (isEmail === true) {
      user = await User.findByEmail(email);
      if (!user) {
        return res.status(401).json({ error: 'Invalid email or password' });
      }
    } else {
      user = await User.findByUsername(username);
      if (!user) {
        return res.status(401).json({ error: 'Invalid username or password' });
      }
    }

    // Validate password
    const isValidPassword = await User.validatePassword(user, password);
    if (!isValidPassword) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Generate JWT
    const token = jwt.sign(
      { id: user.ID, username: user.USERNAME },
      JWT_SECRET,
      { expiresIn: '24h' }
    );

    res.json({
      message: 'Login successful',
      token,
      user: {
        id: user.ID,
        username: user.USERNAME,
        email: user.EMAIL
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Login failed' });
  }
};

const getProfile = async (req, res) => {
  try {
    const userId = req.user.id;
    const user = await User.findById(userId);

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({
      id: user.ID,
      username: user.USERNAME,
      email: user.EMAIL,
      createdAt: user.CREATED_AT
    });
  } catch (error) {
    console.error('Profile error:', error);
    res.status(500).json({ error: 'Failed to get profile' });
  }
};

module.exports = { register, login, getProfile }; 