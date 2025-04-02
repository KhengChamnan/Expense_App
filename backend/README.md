# Personal Expense Tracker - Backend API

This is the backend API for the Personal Expense Tracker application built with Node.js, Express, and SQLite.

## Technologies Used
- Node.js v20
- Express.js
- SQLite3
- JWT Authentication
- bcrypt for password hashing

## Setup Instructions

1. Install dependencies
```
npm install
```

2. Create a `.env` file in the root directory with the following variables:
```
PORT=3000
JWT_SECRET=your_jwt_secret_key_change_this_in_production
DB_PATH=./src/db/database.sqlite
```

3. Start the server
```
npm start
```

For development with auto-restart:
```
npm run dev
```

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register a new user
- `POST /api/auth/login` - Login a user
- `GET /api/auth/profile` - Get user profile (protected)

### Expenses
- `GET /api/expenses` - Get all expenses (protected)
- `GET /api/expenses/:id` - Get expense by ID (protected)
- `GET /api/expenses/month/:year/:month` - Get expenses by month (protected)
- `POST /api/expenses` - Create a new expense (protected)
- `PUT /api/expenses/:id` - Update an expense (protected)
- `DELETE /api/expenses/:id` - Delete an expense (protected)

## Database Schema

### USERS Table
- `ID` (primary key, auto-increment)
- `USERNAME` (unique)
- `EMAIL` (unique)
- `HASHED_PASS` (securely hashed password)
- `CREATED_AT` (default: current timestamp)

### EXPENSE Table
- `ID` (primary key, auto-increment)
- `USER_ID` (foreign key referencing USERS.ID)
- `AMOUNT` (decimal)
- `CATEGORY` (text)
- `DATE` (date)
- `NOTES` (text, optional)
- `CREATED_AT` (default: current timestamp) 