def recommend_stocks(user_input, stock_data):
    """
    Recommends stocks based on user input and stock data.
    Uses a fallback mechanism to ensure recommendations are always provided.
    """
    risk_appetite = user_input["risk_appetite"]
    investment_horizon = user_input["investment_horizon"]
    investment_goal = user_input["investment_goal"]
    sector_preference = user_input["sector_preference"]
    market_cap_preference = user_input["market_cap_preference"]
    dividend_preference = user_input["dividend_preference"]
    investment_amount = user_input["investment_amount"]

    # Step 1: Apply strict filtering
    filtered_stocks = apply_filters(stock_data, risk_appetite, investment_horizon, investment_goal,
                                    sector_preference, market_cap_preference, dividend_preference)

    # Step 2: If no stocks match, relax sector preference
    if not filtered_stocks and sector_preference != "all":
        print("No stocks match your sector preference. Relaxing sector filter...")
        filtered_stocks = apply_filters(stock_data, risk_appetite, investment_horizon, investment_goal,
                                        "all", market_cap_preference, dividend_preference)

    # Step 3: If still no stocks match, relax market cap preference
    if not filtered_stocks and market_cap_preference != "all":
        print("No stocks match your market cap preference. Relaxing market cap filter...")
        filtered_stocks = apply_filters(stock_data, risk_appetite, investment_horizon, investment_goal,
                                        sector_preference, "all", dividend_preference)

    # Step 4: If still no stocks match, relax dividend preference
    if not filtered_stocks and dividend_preference == "yes":
        print("No stocks match your dividend preference. Relaxing dividend filter...")
        filtered_stocks = apply_filters(stock_data, risk_appetite, investment_horizon, investment_goal,
                                        sector_preference, market_cap_preference, "no")

    # Step 5: If still no stocks match, relax risk appetite
    if not filtered_stocks:
        print("No stocks match your risk appetite. Broadening risk category...")
        if risk_appetite == "low":
            filtered_stocks = apply_filters(stock_data, "medium", investment_horizon, investment_goal,
                                            sector_preference, market_cap_preference, dividend_preference)
        elif risk_appetite == "medium":
            filtered_stocks = apply_filters(stock_data, "high", investment_horizon, investment_goal,
                                            sector_preference, market_cap_preference, dividend_preference)
        else:
            filtered_stocks = apply_filters(stock_data, "medium", investment_horizon, investment_goal,
                                            sector_preference, market_cap_preference, dividend_preference)

    # Step 6: Final fallback - recommend default diversified stocks
    if not filtered_stocks:
        print("No stocks match your criteria. Recommending default diversified stocks...")
        filtered_stocks = list(stock_data.keys())[:10]  # Top 10 stocks as default

    return filtered_stocks


def apply_filters(stock_data, risk_appetite, investment_horizon, investment_goal,
                  sector_preference, market_cap_preference, dividend_preference):
    """
    Applies filters to the stock data based on user input.
    """
    # Filter stocks based on market cap preference
    if market_cap_preference == "large-cap":
        filtered_stocks = [symbol for symbol, data in stock_data.items() if data["market_cap"] >= 50000]  # Large-cap: >= 50,000 crore INR
    elif market_cap_preference == "mid-cap":
        filtered_stocks = [symbol for symbol, data in stock_data.items() if 10000 <= data["market_cap"] < 50000]  # Mid-cap: 10,000 to 50,000 crore INR
    elif market_cap_preference == "small-cap":
        filtered_stocks = [symbol for symbol, data in stock_data.items() if data["market_cap"] < 10000]  # Small-cap: < 10,000 crore INR
    else:
        filtered_stocks = list(stock_data.keys())  # No preference, consider all stocks

    # Filter stocks based on sector preference
    if sector_preference != "all":
        filtered_stocks = [symbol for symbol in filtered_stocks if stock_data[symbol]["sector"].lower() == sector_preference]

    # Filter stocks based on dividend preference
    if dividend_preference == "yes":
        filtered_stocks = [symbol for symbol in filtered_stocks if stock_data[symbol]["dividend_yield"] > 2.0]  # High-dividend stocks (yield > 2%)

    # Filter stocks based on risk appetite and investment horizon
    if risk_appetite == "low":
        # Low-risk: Focus on low-volatility stocks (beta < 1.0)
        filtered_stocks = [symbol for symbol in filtered_stocks if stock_data[symbol]["beta"] < 1.0]
    elif risk_appetite == "medium":
        # Medium-risk: Focus on moderate-volatility stocks (1.0 <= beta < 1.5)
        filtered_stocks = [symbol for symbol in filtered_stocks if 1.0 <= stock_data[symbol]["beta"] < 1.5]
    elif risk_appetite == "high":
        # High-risk: Focus on high-volatility stocks (beta >= 1.5)
        filtered_stocks = [symbol for symbol in filtered_stocks if stock_data[symbol]["beta"] >= 1.5]

    # Filter stocks based on investment goal
    if investment_goal == "growth":
        # Growth: Focus on stocks with high historical returns
        filtered_stocks = [symbol for symbol in filtered_stocks if stock_data[symbol]["current_price"] > stock_data[symbol]["day_low"] * 1.1]  # Example: Price > 10% above 52-week low
    elif investment_goal == "dividends":
        # Dividends: Focus on high-dividend stocks
        filtered_stocks = [symbol for symbol in filtered_stocks if stock_data[symbol]["dividend_yield"] > 2.0]
    elif investment_goal == "both":
        # Both growth and dividends: No additional filtering
        pass

    return filtered_stocks