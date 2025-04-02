class ApiConstants {
  // Base API URL
  // For Android emulator
  // static const String baseUrl = 'http://10.0.2.2:3000/api';
  
  // For physical device - using your actual Wi-Fi IP address
  static const String baseUrl = 'http://192.168.1.51:3000/api'; 
  
  // For web or testing with localhost
  // static const String baseUrl = 'http://localhost:3000/api';

  // Auth endpoints
  static const String registerUrl = '$baseUrl/auth/register';
  static const String loginUrl = '$baseUrl/auth/login';
  static const String profileUrl = '$baseUrl/auth/profile';

  // Expense endpoints
  static const String expensesUrl = '$baseUrl/expenses';
  static String expenseByIdUrl(int id) => '$expensesUrl/$id';
  static String expensesByMonthUrl(int year, int month) => '$expensesUrl/month/$year/$month';
} 