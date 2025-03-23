from flask import Flask, jsonify, request
import requests
import base64
import io
import matplotlib
matplotlib.use('Agg')  # Non-interactive backend
import matplotlib.pyplot as plt
import time
import pandas as pd
from datetime import datetime
import random
import numpy as np
import yfinance as yf  # Import yfinance

app = Flask(__name__)

# Predefined list of Indian stock tickers for each category
STATIC_STOCKS = {
    "Technology": [
        "TCS.NS", "INFY.NS", "HCLTECH.NS", "WIPRO.NS", "TECHM.NS",
        "LTIM.NS", "MPHASIS.NS", "COFORGE.NS", "ZENSARTECH.NS", "MINDTREE.NS"
    ],
    "Defence": [
        "HAL.NS", "BEL.NS", "BEML.NS", "MIDHANI.NS", "L&T.NS",
        "GRSE.NS", "GSL.NS", "MDL.NS", "AVNL.NS", "BHEL.NS"
    ],
    "Environment": [
        "NTPC.NS", "TATAPOWER.NS", "JSWENERGY.NS", "ADANIGREEN.NS", "SJVN.NS",
        "NHPC.NS", "POWERGRID.NS", "TATASTEEL.NS", "JSWSTEEL.NS", "SAIL.NS"
    ],
    "Financial": [
        "HDFCBANK.NS", "ICICIBANK.NS", "SBIN.NS", "KOTAKBANK.NS", "AXISBANK.NS",
        "BAJFINANCE.NS", "BAJAJFINSV.NS", "INDUSINDBK.NS", "PNB.NS", "BANDHANBNK.NS"
    ],
    "Energy": [
        "RELIANCE.NS", "ONGC.NS", "IOC.NS", "BPCL.NS", "HPCL.NS",
        "GAIL.NS", "OIL.NS", "PETRONET.NS", "ADANIGAS.NS", "GUJGASLTD.NS"
    ],
    "Consumer": [
        "HINDUNILVR.NS", "ITC.NS", "TITAN.NS", "ASIANPAINT.NS", "MARUTI.NS",
        "BRITANNIA.NS", "DABUR.NS", "NESTLEIND.NS", "GODREJCP.NS", "UBL.NS"
    ]
}

# Function to fetch real-time price and metadata for a stock
def get_real_time_data(ticker):
    try:
        stock = yf.Ticker(ticker)
        info = stock.info
        return {
            'ticker': ticker,
            'name': info.get('longName', ticker),
            'price': info.get('currentPrice', 0),
            'sector': info.get('sector', 'Unknown'),
            'industry': info.get('industry', 'Unknown'),
            'marketCap': info.get('marketCap', 0)
        }
    except Exception as e:
        print(f"Error fetching data for {ticker}: {e}")
        return None

# Function to generate stock graph as base64 image
def generate_stock_graph(ticker):
    try:
        stock = yf.Ticker(ticker)
        history = stock.history(period="1y")  # Fetch 1 year of historical data
        
        if history.empty:
            raise ValueError("No historical data available")
        
        plt.figure(figsize=(10, 5))
        plt.plot(history['Close'], label=ticker)
        plt.title(f"{ticker} - Historical Price Chart")
        plt.xlabel("Date")
        plt.ylabel("Price (₹)")
        plt.legend()
        plt.grid()
        
        # Save plot to a bytes buffer
        buf = io.BytesIO()
        plt.savefig(buf, format='png')
        plt.close()
        buf.seek(0)
        
        # Convert to base64 string
        image_base64 = base64.b64encode(buf.getvalue()).decode('utf-8')
        return image_base64
    except Exception as e:
        print(f"Error generating graph for {ticker}: {e}")
        return None

# Function to sort and filter stocks by category
def sort_and_filter_stocks(category, order="A"):
    # Get static stocks for the selected category
    tickers = STATIC_STOCKS.get(category, [])
    stocks_data = []

    # Fetch real-time data for all tickers
    for ticker in tickers:
        stock_data = get_real_time_data(ticker)
        if stock_data:
            stocks_data.append(stock_data)

    # Sort stocks by price
    if order.upper() == "A":
        sorted_stocks = sorted(stocks_data, key=lambda x: x['price'])  # Ascending
    else:
        sorted_stocks = sorted(stocks_data, key=lambda x: x['price'], reverse=True)  # Descending
    
    # Return top 10 stocks
    return sorted_stocks[:10]

@app.route('/stocks/<category>')
def get_stocks_by_category(category):
    # Get sorting order from query parameter, default to ascending
    order = request.args.get('order', 'A')
    
    # Get stocks data
    stocks = sort_and_filter_stocks(category, order)
    
    # If no stocks found, return empty array
    if not stocks:
        return jsonify({"error": "No stocks found in this category", "stocks": []})
    
    # Enhance stocks data with chart
    for stock in stocks:
        stock['chart'] = generate_stock_graph(stock['ticker'])
    
    return jsonify({"stocks": stocks})

@app.route('/categories')
def get_categories():
    return jsonify({
        "categories": list(STATIC_STOCKS.keys())
    })

@app.route('/health')
def health_check():
    return jsonify({"status": "healthy"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)