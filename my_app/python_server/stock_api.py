from flask import Flask, jsonify, request
from flask_cors import CORS
import yfinance as yf
import pandas as pd
import matplotlib
# Set matplotlib to use 'Agg' backend (non-interactive, thread-safe)
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import io
import base64
import time
import logging
from threading import Lock

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Create a lock for thread-safe chart generation
chart_lock = Lock()

# Define stock categories and their tickers (BSE and NSE stocks)
# Updated ticker symbols to ensure they're all valid
STOCK_CATEGORIES = {
    'Technology': [
        {'ticker': 'TCS.NS', 'name': 'Tata Consultancy Services', 'sector': 'Technology', 'industry': 'IT Services'},
        {'ticker': 'INFY.NS', 'name': 'Infosys Ltd', 'sector': 'Technology', 'industry': 'IT Services'},
        {'ticker': 'WIPRO.NS', 'name': 'Wipro Ltd', 'sector': 'Technology', 'industry': 'IT Services'},
        {'ticker': 'HCLTECH.NS', 'name': 'HCL Technologies', 'sector': 'Technology', 'industry': 'IT Services'},
        {'ticker': 'TECHM.NS', 'name': 'Tech Mahindra', 'sector': 'Technology', 'industry': 'IT Services'}
    ],
    'Defence': [
        {'ticker': 'HAL.NS', 'name': 'Hindustan Aeronautics Ltd', 'sector': 'Defence', 'industry': 'Aerospace'},
        {'ticker': 'BEL.NS', 'name': 'Bharat Electronics Ltd', 'sector': 'Defence', 'industry': 'Electronic Systems'},
        {'ticker': 'BEML.NS', 'name': 'BEML Limited', 'sector': 'Defence', 'industry': 'Heavy Engineering'},
        {'ticker': 'COCHINSHIP.NS', 'name': 'Cochin Shipyard', 'sector': 'Defence', 'industry': 'Shipbuilding'},
        {'ticker': 'DATAPATTNS.NS', 'name': 'Data Patterns India', 'sector': 'Defence', 'industry': 'Electronics'} # Fixed ticker
    ],
    'Environment': [
        {'ticker': 'SUZLON.NS', 'name': 'Suzlon Energy', 'sector': 'Environment', 'industry': 'Renewable Energy'},
        {'ticker': 'TATAPOWER.NS', 'name': 'Tata Power', 'sector': 'Environment', 'industry': 'Power Generation'},
        {'ticker': 'ADANIGREEN.NS', 'name': 'Adani Green Energy', 'sector': 'Environment', 'industry': 'Renewable Energy'},
        {'ticker': 'NTPC.NS', 'name': 'NTPC Ltd', 'sector': 'Environment', 'industry': 'Power Generation'},
        {'ticker': 'JSWENERGY.NS', 'name': 'JSW Energy', 'sector': 'Environment', 'industry': 'Renewable Energy'} # Replaced INOXWIND with a more reliable ticker
    ],
}

def generate_stock_chart(ticker, period='1mo'):
    """Generate a price chart for a given stock ticker and return as base64 encoded string"""
    try:
        # Get historical data
        stock = yf.Ticker(ticker)
        history = stock.history(period=period)
        
        # If we have data, create the chart
        if not history.empty:
            # Use lock to prevent thread-related issues
            with chart_lock:
                plt.figure(figsize=(8, 4))
                plt.plot(history.index, history['Close'], color='#E65100')  # Using app primary color
                plt.fill_between(history.index, history['Close'], alpha=0.2, color='#EF6C00')  # Using app secondary color
                plt.grid(True, alpha=0.3)
                plt.xticks(rotation=45)
                plt.tight_layout()
                
                # Save plot to a bytes buffer
                buffer = io.BytesIO()
                plt.savefig(buffer, format='png')
                plt.close()  # Close the figure to prevent memory leaks
                buffer.seek(0)
                
                # Encode the image to base64
                image_png = buffer.getvalue()
                buffer.close()
                
                encoded_string = base64.b64encode(image_png).decode('utf-8')
                return encoded_string
        else:
            logger.warning(f"No historical data available for {ticker}")
            return None
    except Exception as e:
        logger.error(f"Error generating chart for {ticker}: {str(e)}")
        return None

def get_stock_data(ticker):
    """Get current stock data for a given ticker with better error handling"""
    try:
        stock = yf.Ticker(ticker)
        
        # Try to get some basic info first to check if the ticker is valid
        info = {}
        try:
            info = stock.fast_info
            if hasattr(info, 'last_price') and info.last_price is not None:
                return info.last_price
        except:
            pass
            
        # Fall back to the full info if fast_info doesn't work
        try:
            info = stock.info
        except:
            # If we can't get info, try to get the last closing price from history
            history = stock.history(period="1d")
            if not history.empty and 'Close' in history.columns:
                return history['Close'].iloc[-1]
            return 0.0
        
        # Check if we have price data in various fields
        if 'regularMarketPrice' in info and info['regularMarketPrice'] is not None:
            return info['regularMarketPrice']
        elif 'currentPrice' in info and info['currentPrice'] is not None:
            return info['currentPrice']
        elif 'previousClose' in info and info['previousClose'] is not None:
            return info['previousClose']
        else:
            # Last resort: try to get the price from history
            history = stock.history(period="1d")
            if not history.empty and 'Close' in history.columns:
                return history['Close'].iloc[-1]
            
            logger.warning(f"No price data available for {ticker}")
            return 0.0
    except Exception as e:
        logger.error(f"Error fetching data for {ticker}: {str(e)}")
        return 0.0

def get_fallback_data(ticker_info):
    """Generate fallback data when a stock can't be fetched"""
    try:
        # Create a minimal stock object with the info we have
        return {
            'ticker': ticker_info['ticker'],
            'name': ticker_info['name'],
            'price': 0.0,  # Placeholder price
            'sector': ticker_info['sector'],
            'industry': ticker_info['industry'],
            'chart': None,  # No chart available
            'error': 'Data unavailable'
        }
    except Exception as e:
        logger.error(f"Error creating fallback data: {str(e)}")
        return None

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint to verify server is running"""
    return jsonify({'status': 'healthy', 'timestamp': time.time()})

@app.route('/stocks/<category>', methods=['GET'])
def get_stocks_by_category(category):
    """Get stocks by category with optional sorting by price"""
    try:
        # Check if the category exists
        if category not in STOCK_CATEGORIES:
            return jsonify({"error": f"Category '{category}' not found"}), 404
        
        # Get sort order from query parameter (A for ascending, D for descending)
        sort_order = request.args.get('order', 'A')
        
        # Get stocks for the selected category
        stocks = []
        
        for stock_info in STOCK_CATEGORIES[category]:
            ticker = stock_info['ticker']
            
            try:
                # Get current price
                price = get_stock_data(ticker)
                
                # Generate chart
                chart = generate_stock_chart(ticker)
                
                # Create stock object
                stock = {
                    'ticker': ticker,
                    'name': stock_info['name'],
                    'price': price,
                    'sector': stock_info['sector'],
                    'industry': stock_info['industry'],
                    'chart': chart
                }
                
                stocks.append(stock)
            except Exception as e:
                logger.error(f"Error processing stock {ticker}: {str(e)}")
                # Add fallback data
                fallback = get_fallback_data(stock_info)
                if fallback:
                    stocks.append(fallback)
        
        # Sort stocks by price (handle 0 values appropriately)
        stocks.sort(key=lambda x: x['price'] if x['price'] > 0 else float('inf'), reverse=(sort_order == 'D'))
        
        return jsonify(stocks)
    
    except Exception as e:
        logger.error(f"Error processing request: {str(e)}")
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    # Add instructions for users
    print("=" * 80)
    print("Stock API Server")
    print("=" * 80)
    print("Make sure you have the required packages installed:")
    print("  pip install flask flask-cors yfinance pandas matplotlib")
    print("\nThe server will run on http://localhost:5000")
    print("Endpoints:")
    print("  - /health - Health check endpoint")
    print("  - /stocks/<category>?order=A|D - Get stocks by category with optional sorting")
    print("\nAvailable categories:")
    for category in STOCK_CATEGORIES:
        print(f"  - {category}")
    print("=" * 80)
    
    # Run the app
    app.run(host='0.0.0.0', port=5000, debug=True, threaded=True)