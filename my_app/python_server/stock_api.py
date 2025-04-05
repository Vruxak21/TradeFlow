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
import threading
import requests
from requests.exceptions import RequestException
import traceback

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Define stock categories and their tickers (BSE and NSE stocks)
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
        {'ticker': 'DATAPATTNS.NS', 'name': 'Data Patterns India', 'sector': 'Defence', 'industry': 'Electronics'}
    ],
    'Environment': [
        {'ticker': 'SUZLON.NS', 'name': 'Suzlon Energy', 'sector': 'Environment', 'industry': 'Renewable Energy'},
        {'ticker': 'TATAPOWER.NS', 'name': 'Tata Power', 'sector': 'Environment', 'industry': 'Power Generation'},
        {'ticker': 'ADANIGREEN.NS', 'name': 'Adani Green Energy', 'sector': 'Environment', 'industry': 'Renewable Energy'},
        {'ticker': 'NTPC.NS', 'name': 'NTPC Ltd', 'sector': 'Environment', 'industry': 'Power Generation'},
        {'ticker': 'JSWENERGY.NS', 'name': 'JSW Energy', 'sector': 'Environment', 'industry': 'Renewable Energy'}
    ],
}

# Cache mechanism to store data and reduce API calls
cache = {
    'data': {},
    'charts': {},
    'timestamp': {},
    'lock': threading.RLock()  # Use RLock for thread safety
}

# Cache expiration time (in seconds)
CACHE_EXPIRY = 300  # 5 minutes

def is_cache_valid(category):
    """Check if cache for a category is still valid"""
    with cache['lock']:
        if category in cache['timestamp']:
            return (time.time() - cache['timestamp'][category]) < CACHE_EXPIRY
        return False

def generate_stock_chart(ticker, period='1mo'):
    """Generate a price chart for a given stock ticker and return as base64 encoded string"""
    # Check if chart is in cache
    with cache['lock']:
        if ticker in cache['charts']:
            logger.info(f"Using cached chart for {ticker}")
            return cache['charts'][ticker]
    
    try:
        # Get historical data
        stock = yf.Ticker(ticker)
        history = stock.history(period=period)
        
        # If we have data, create the chart
        if not history.empty:
            # Calculate daily returns for volume coloring
            history['DailyReturn'] = history['Close'].pct_change()
            
            # Create figure with transparent background
            fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(8, 4.5), 
                                          gridspec_kw={'height_ratios': [3, 1]},
                                          sharex=True)
            fig.patch.set_alpha(0.0)  # Make figure background transparent
            
            # Plot price chart on top subplot
            ax1.patch.set_alpha(0.0)  # Make plot background transparent
            ax1.plot(history.index, history['Close'], color='#FF5722', linewidth=2, label='Price')
            
            # Fill between price and bottom
            ax1.fill_between(history.index, history['Close'], history['Close'].min()*0.95, 
                            alpha=0.1, color='#FF7043')
            
            # Plot volume on bottom subplot
            ax2.patch.set_alpha(0.0)  # Make volume plot background transparent
            colors = ['#4CAF50' if r >= 0 else '#F44336' for r in history['DailyReturn']]
            ax2.bar(history.index, history['Volume'], color=colors, alpha=0.7, width=0.8)
            
            # Style the plots
            for ax in [ax1, ax2]:
                ax.grid(color='#E0E0E0', linestyle='--', linewidth=0.5, alpha=0.7)
                ax.spines['top'].set_visible(False)
                ax.spines['right'].set_visible(False)
                ax.spines['bottom'].set_color('#E0E0E0')
                ax.spines['left'].set_color('#E0E0E0')
                ax.tick_params(colors='#757575', labelsize=8)
            
            # Reduce number of x-axis labels to avoid crowding
            if len(history) > 20:
                num_ticks = 7
                ax2.xaxis.set_major_locator(plt.MaxNLocator(num_ticks))
            
            ax1.set_title(f"{ticker} Stock Price", color='#5D4037', fontsize=10, pad=5)
            ax1.legend(loc='upper left', frameon=False, fontsize=8)
            
            # Format y-axis with currency
            import matplotlib.ticker as mtick
            ax1.yaxis.set_major_formatter(mtick.StrMethodFormatter('₹{x:,.2f}'))
            
            # Format volume axis with K/M suffix for thousands/millions
            def volume_formatter(x, pos):
                if x >= 1e6:
                    return f'{x*1e-6:.1f}M'
                elif x >= 1e3:
                    return f'{x*1e-3:.1f}K'
                else:
                    return f'{x:.0f}'
            
            ax2.yaxis.set_major_formatter(mtick.FuncFormatter(volume_formatter))
            
            # Set y-axis limits slightly above/below the data range for better appearance
            ax1_ymin = history['Close'].min() * 0.95
            ax1_ymax = history['Close'].max() * 1.05
            ax1.set_ylim(ax1_ymin, ax1_ymax)
            
            # Adjust layout
            plt.tight_layout()
            fig.subplots_adjust(hspace=0.1)  # Reduce space between subplots
            
            # Save plot to a bytes buffer with transparency
            buffer = io.BytesIO()
            plt.savefig(buffer, format='png', transparent=True, dpi=120)
            plt.close(fig)  # Close the figure to prevent memory leaks
            buffer.seek(0)
            
            # Encode the image to base64
            image_png = buffer.getvalue()
            buffer.close()
            
            encoded_string = base64.b64encode(image_png).decode('utf-8')
            
            # Cache the chart
            with cache['lock']:
                cache['charts'][ticker] = encoded_string
                
            return encoded_string
        else:
            logger.warning(f"No historical data available for {ticker}")
            return None
    except Exception as e:
        logger.error(f"Error generating chart for {ticker}: {str(e)}")
        logger.error(traceback.format_exc())
        return None

def get_stock_data(ticker):
    """Get current stock data for a given ticker with better error handling"""
    try:
        stock = yf.Ticker(ticker)
        
        # Try to get some basic info first to check if the ticker is valid
        info = {}
        try:
            # Use fast_info for better performance
            info = stock.fast_info
            if hasattr(info, 'last_price') and info.last_price is not None:
                return info.last_price
        except Exception as e:
            logger.warning(f"Fast info retrieval failed for {ticker}: {str(e)}")
            
        # Fall back to the full info if fast_info doesn't work
        try:
            info = stock.info
        except Exception as e:
            logger.warning(f"Full info retrieval failed for {ticker}: {str(e)}")
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
        logger.error(traceback.format_exc())
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

def fetch_stocks_data(category, sort_order='A'):
    """Fetch and process stock data for a category"""
    if category not in STOCK_CATEGORIES:
        return []
    
    # Check if we have valid cached data
    if is_cache_valid(category):
        with cache['lock']:
            stocks = cache['data'].get(category, [])
            logger.info(f"Using cached data for {category}")
            # Still apply sorting as requested
            stocks.sort(key=lambda x: x['price'] if x['price'] > 0 else float('inf'), 
                       reverse=(sort_order == 'D'))
            return stocks
    
    # If not in cache or expired, fetch fresh data
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
            logger.error(traceback.format_exc())
            # Add fallback data
            fallback = get_fallback_data(stock_info)
            if fallback:
                stocks.append(fallback)
    
    # Sort stocks by price
    stocks.sort(key=lambda x: x['price'] if x['price'] > 0 else float('inf'), 
               reverse=(sort_order == 'D'))
    
    # Update cache
    with cache['lock']:
        cache['data'][category] = stocks.copy()  # Store a copy to prevent modification
        cache['timestamp'][category] = time.time()
    
    return stocks

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

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
        
        # Process request in a separate thread pool to avoid blocking
        stocks = fetch_stocks_data(category, sort_order)
        
        return jsonify(stocks)
    
    except Exception as e:
        logger.error(f"Error processing request: {str(e)}")
        logger.error(traceback.format_exc())
        return jsonify({"error": str(e)}), 500

# Preload cache on startup in a separate thread
def preload_cache():
    """Preload cache with data for all categories"""
    logger.info("Preloading cache...")
    for category in STOCK_CATEGORIES:
        try:
            fetch_stocks_data(category)
            logger.info(f"Preloaded data for {category}")
        except Exception as e:
            logger.error(f"Error preloading cache for {category}: {str(e)}")

if __name__ == '__main__':
    # Start preloading cache in a separate thread
    threading.Thread(target=preload_cache).start()
    
    # Run the Flask app
    app.run(host='0.0.0.0', port=5000, debug=True, threaded=True)