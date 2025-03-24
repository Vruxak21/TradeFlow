import yfinance as yf

def fetch_stock_data(stock_symbols):
    """
    Fetches real-time stock data and additional attributes for the given list of stock symbols.
    Skips delisted or unavailable stocks.
    """
    stock_data = {}
    for symbol in stock_symbols:
        try:
            stock = yf.Ticker(symbol)
            stock_info = stock.history(period="1d")
            if not stock_info.empty:
                # Fetch additional attributes
                market_cap = stock.info.get("marketCap", 0)  # Market capitalization
                sector = stock.info.get("sector", "Unknown")  # Sector
                beta = stock.info.get("beta", 1.0)  # Beta (volatility measure)
                dividend_yield = stock.info.get("dividendYield", 0)  # Dividend yield
                stock_data[symbol] = {
                    "current_price": stock_info['Close'].iloc[-1],
                    "day_high": stock_info['High'].iloc[-1],
                    "day_low": stock_info['Low'].iloc[-1],
                    "volume": stock_info['Volume'].iloc[-1],
                    "market_cap": market_cap,
                    "sector": sector,
                    "beta": beta,
                    "dividend_yield": dividend_yield,
                }
            else:
                print(f"Skipping {symbol}: No data found (possibly delisted).")
        except Exception as e:
            print(f"Skipping {symbol}: Error fetching data ({str(e)}).")
    return stock_data