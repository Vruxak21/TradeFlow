# TradeFlow

TradeFlow is a comprehensive financial application that provides personalized stock recommendations, market insights, and financial education for users. Powered by AI and real-time market data, TradeFlow helps users make informed investment decisions based on their personal preferences and financial goals.

![TradeFlow App](https://via.placeholder.com/800x400)

## Features

### 🔐 Authentication

- User registration and login with email/password
- Sign in with Google integration
- Secure authentication through Firebase

### 💬 FinAI Chatbot

- Financial advisor chatbot powered by Google's Gemini API
- Specialized to answer finance-related questions only
- Real-time assistance for investment queries

### 📈 Market Insights & Trends

- Current market analysis and trends
- Real-time stock data using yfinance API
- Latest financial news from Indian markets via Alpha Vantage and GNews

### 🌱 Socially Responsible Investing

- Categorized ethical investment options
- Interactive graphs for each stock category
- Focus on sustainable and socially conscious investments

### 📚 Financial Glossary

- Educational cards explaining financial terminology
- Live stock tracking of popular companies
- Beginner-friendly financial literacy resources

### 🤖 AI Investment Recommendations

- Personalized stock suggestions based on user inputs:
  - Risk appetite (low/medium/high)
  - Annual income
  - Investment horizon
  - Investment goals (growth/dividends/both)
  - Sector preferences
  - Market cap preferences
  - Dividend preferences
  - Investment amount

## Tech Stack

### Frontend

- Flutter for cross-platform mobile development

### Backend

- Flask servers for API handling and model serving
- Python for data analysis and stock recommendations

### APIs & Services

- Firebase for authentication and database
- yfinance for stock market data
- Alpha Vantage for financial metrics
- GNews for market news
- Gemini API for AI chatbot functionality

## Installation

### Prerequisites

- Flutter SDK
- Python 3.7+
- Firebase account
- API keys for Gemini, Alpha Vantage, and GNews

### Dependencies

#### Python Dependencies

```bash
# Core Dependencies
pip install flask flask-cors yfinance pandas matplotlib requests

# Optional (for development/debugging)
pip install python-dotenv  # For environment variables (if used)
```

#### Flutter Dependencies

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^latest_version
  firebase_auth: ^latest_version
  google_sign_in: ^latest_version
  http: ^latest_version
  charts_flutter: ^latest_version
  # Add other dependencies as needed
```

## Getting Started

### Step 1: Clone the repository

```bash
git clone https://github.com/yourusername/tradeflow.git
cd tradeflow
```

### Step 2: Start the Flask servers

Terminal 1 - Start the main Python server:

```bash
cd project-model/my_app/python_server
python app.py
```

Terminal 2 - Start the stock API server:

```bash
cd project-model/my_app/python_server
python stock_api.py
```

### Step 3: Run the Flutter app

```bash
cd project-model/my_app
flutter run
```

## Usage

1. **Sign In/Register**: Create an account or sign in with Google
2. **Home Screen**: Explore financial glossary cards and live stock tracking
3. **FinAI Chatbot**: Ask finance-related questions to get expert advice
4. **Market Insights**: View current market trends and news
5. **Socially Responsible Investing**: Explore ethical investment options by category
6. **AI Investment Picks**: Take the investment questionnaire to receive personalized stock recommendations

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- yfinance for providing stock market data
- Alpha Vantage for financial metrics
- GNews for market news
- Google Gemini for AI capabilities
- Firebase for authentication services

---
