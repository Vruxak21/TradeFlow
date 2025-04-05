import yfinance as yf
import math
import time
import random

def fetch_stock_data(stock_symbols):
    """
    Fetches real-time stock data and additional attributes for the given list of stock symbols.
    Adds technical indicators and resiliency features to improve data quality.
    """
    stock_data = {}
    missing_data_count = 0
    
    for symbol in stock_symbols:
        try:
            # Add delay to avoid rate limiting (can be adjusted)
            if len(stock_data) % 10 == 0 and len(stock_data) > 0:
                time.sleep(1)
                
            stock = yf.Ticker(symbol)
            
            # Get historical data for calculations - more data for better indicators
            hist_short = stock.history(period="1mo")  # Short term for recent indicators
            hist_long = stock.history(period="6mo")   # Longer term for trend analysis
            
            if not hist_short.empty and len(hist_short) >= 5:
                # Get basic info
                info = stock.info
                
                # Fetch additional attributes with fallback values
                market_cap = info.get("marketCap", info.get("totalAssets", 0))
                sector = info.get("sector", info.get("industry", "Unknown"))
                beta = info.get("beta", calculate_beta_fallback(hist_long))
                dividend_yield = info.get("dividendYield", calculate_div_yield_fallback(info, hist_long))
                
                # Calculate change percentage
                change_percent = 0.0
                if len(hist_short) >= 2:
                    previous_close = hist_short['Close'].iloc[-2]
                    current_close = hist_short['Close'].iloc[-1]
                    if previous_close > 0:
                        change_percent = ((current_close - previous_close) / previous_close) * 100
                
                # Calculate additional technical indicators
                rsi = calculate_rsi(hist_short)
                moving_avg_50 = calculate_moving_average(hist_long, 50)
                moving_avg_200 = calculate_moving_average(hist_long, 200)
                price_to_ma_ratio = hist_short['Close'].iloc[-1] / moving_avg_50 if moving_avg_50 > 0 else 1.0
                
                # Calculate volatility (standard deviation of returns)
                returns = hist_short['Close'].pct_change().dropna()
                volatility = returns.std() * 100 if len(returns) > 0 else 0
                
                # Ensure we have valid values
                if beta is None or beta == 0 or math.isnan(beta):
                    beta = 1.0
                if dividend_yield is None or math.isnan(dividend_yield):
                    dividend_yield = 0
                if market_cap is None or math.isnan(market_cap):
                    market_cap = 0
                
                # Store all data
                stock_data[symbol] = {
                    "current_price": hist_short['Close'].iloc[-1],
                    "day_high": hist_short['High'].iloc[-1],
                    "day_low": hist_short['Low'].iloc[-1],
                    "volume": hist_short['Volume'].iloc[-1],
                    "market_cap": market_cap,
                    "sector": sector if sector is not None else "Unknown",
                    "beta": beta,
                    "dividend_yield": dividend_yield,
                    "change_percent": change_percent,
                    # New technical indicators
                    "rsi": rsi,
                    "moving_avg_50": moving_avg_50,
                    "moving_avg_200": moving_avg_200,
                    "price_to_ma_ratio": price_to_ma_ratio,
                    "volatility": volatility,
                    "above_ma50": hist_short['Close'].iloc[-1] > moving_avg_50,
                    "above_ma200": hist_short['Close'].iloc[-1] > moving_avg_200
                }
            else:
                missing_data_count += 1
                print(f"Skipping {symbol}: Insufficient data found.")
        except Exception as e:
            missing_data_count += 1
            print(f"Skipping {symbol}: Error fetching data ({str(e)}).")
    
    print(f"Fetched data for {len(stock_data)} stocks. Skipped {missing_data_count} stocks.")
    return stock_data


def calculate_beta_fallback(historical_data):
    """Calculate a fallback beta value from price volatility if API doesn't provide it"""
    if len(historical_data) < 30:
        return 1.0
    
    # A simple estimation based on price volatility relative to average
    returns = historical_data['Close'].pct_change().dropna()
    
    if len(returns) < 20:
        return 1.0
        
    volatility = returns.std() * 100
    
    # Map volatility to beta (rough estimation)
    if volatility < 1.0:
        return 0.8
    elif volatility < 2.0:
        return 1.0
    elif volatility < 3.0:
        return 1.2
    elif volatility < 4.0:
        return 1.5
    else:
        return min(volatility / 2.5, 2.5)  # Cap at 2.5


def calculate_div_yield_fallback(info, historical_data):
    """Calculate a fallback dividend yield if API doesn't provide it"""
    # Try to compute from dividends in historical data
    if 'Dividends' in historical_data.columns and not historical_data['Dividends'].empty:
        annual_div = historical_data['Dividends'].sum() * (252 / len(historical_data))
        if 'previousClose' in info and info['previousClose'] > 0:
            return annual_div / info['previousClose']
    
    return 0.0  # Default if no dividend info available


def calculate_rsi(data, window=14):
    """Calculate the Relative Strength Index"""
    if len(data) < window + 1:
        return 50  # Default value if not enough data
        
    delta = data['Close'].diff()
    gain = delta.where(delta > 0, 0).rolling(window=window).mean()
    loss = -delta.where(delta < 0, 0).rolling(window=window).mean()
    
    if loss.iloc[-1] == 0:
        return 100
        
    rs = gain.iloc[-1] / loss.iloc[-1]
    return 100 - (100 / (1 + rs))


def calculate_moving_average(data, window):
    """Calculate moving average of closing prices"""
    if len(data) < window:
        return data['Close'].mean() if not data.empty else 0
    
    return data['Close'].rolling(window=window).mean().iloc[-1]