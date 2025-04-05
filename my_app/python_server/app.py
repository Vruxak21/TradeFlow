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
        try:
            stock_data = fetch_stock_data(INDIAN_STOCK_SYMBOLS)
        except Exception as e:
            return jsonify({"status": "error", "message": f"Failed to fetch stock data: {str(e)}"}), 500
    
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
        
        # Validate input values
        if user_input["risk_appetite"] not in ["low", "medium", "high"]:
            return jsonify({"status": "error", "message": "Invalid risk appetite value"}), 400
        
        if user_input["investment_goal"] not in ["growth", "dividends", "both"]:
            return jsonify({"status": "error", "message": "Invalid investment goal value"}), 400
        
        # Get recommendations - now returns symbols with price guidance
        recommended_stocks_with_guidance = recommend_stocks(user_input, stock_data)
        
        # Format the response
        result = []
        for symbol, guidance in recommended_stocks_with_guidance:
            if symbol in stock_data:
                # Calculate a match quality score based on various factors
                result.append({
                    "symbol": symbol,
                    "price": stock_data[symbol]["current_price"],
                    "sector": stock_data[symbol].get("sector", "Unknown"),
                    "market_cap": stock_data[symbol].get("market_cap", 0),
                    "beta": stock_data[symbol].get("beta", 1.0),
                    "dividend_yield": stock_data[symbol].get("dividend_yield", 0),
                    "change_percent": stock_data[symbol].get("change_percent", 0),
                    # Add the new price guidance information
                    "buy_target": guidance["buy_target"],
                    "sell_target": guidance["sell_target"],
                    "stop_loss": guidance["stop_loss"],
                    "strategy": guidance["strategy"]
                })
        
        return jsonify({
            "status": "success", 
            "recommendations": result
        })
    
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

if __name__ == "__main__":
    # Fetch initial stock data when server starts
    try:
        stock_data = fetch_stock_data(INDIAN_STOCK_SYMBOLS)
        print(f"Successfully fetched data for {len(stock_data)} stocks")
    except Exception as e:
        print(f"Error fetching initial stock data: {str(e)}")
    
    app.run(host='0.0.0.0', port=5001, debug=True)