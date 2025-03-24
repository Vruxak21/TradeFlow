from flask import Flask, request, jsonify
from flask_cors import CORS
import json
from stock_data import fetch_stock_data
from stock_recommender import recommend_stocks
from stock_symbols import INDIAN_STOCK_SYMBOLS

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Pre-fetch stock data when the server starts to improve response time
stock_data = {}

@app.route('/fetch-stock-data', methods=['GET'])
def get_stock_data():
    """Endpoint to fetch stock data - can be used for initialization or refresh"""
    global stock_data
    try:
        stock_data = fetch_stock_data(INDIAN_STOCK_SYMBOLS)
        return jsonify({"status": "success", "message": f"Fetched data for {len(stock_data)} stocks"})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route('/recommend', methods=['POST'])
def get_recommendations():
    """Endpoint to get stock recommendations based on user input"""
    global stock_data
    
    # If stock data is empty, fetch it first
    if not stock_data:
        stock_data = fetch_stock_data(INDIAN_STOCK_SYMBOLS)
    
    try:
        # Get user input from request
        user_input = request.json
        
        # Validate required fields
        required_fields = [
            "risk_appetite", "investment_horizon", "investment_goal",
            "sector_preference", "market_cap_preference", 
            "dividend_preference", "investment_amount"
        ]
        
        for field in required_fields:
            if field not in user_input:
                return jsonify({
                    "status": "error", 
                    "message": f"Missing required field: {field}"
                }), 400
        
        # Get recommendations
        recommended_stocks = recommend_stocks(user_input, stock_data)
        
        # Format the response
        result = []
        for symbol in recommended_stocks:
            result.append({
                "symbol": symbol,
                "price": stock_data[symbol]["current_price"],
                "sector": stock_data[symbol].get("sector", "Unknown"),
                "market_cap": stock_data[symbol].get("market_cap", 0),
                "beta": stock_data[symbol].get("beta", 1.0),
                "dividend_yield": stock_data[symbol].get("dividend_yield", 0)
            })
        
        return jsonify({
            "status": "success", 
            "recommendations": result
        })
    
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

if __name__ == "__main__":
    # Fetch initial stock data when server starts
    stock_data = fetch_stock_data(INDIAN_STOCK_SYMBOLS)
    app.run(host='0.0.0.0', port=5001, debug=True)