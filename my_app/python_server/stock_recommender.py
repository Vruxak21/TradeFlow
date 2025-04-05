def recommend_stocks(user_input, stock_data):
    """
    Recommends stocks based on user input and stock data.
    Uses a scoring system for better accuracy and provides price guidance.
    """
    risk_appetite = user_input["risk_appetite"]
    investment_horizon = user_input["investment_horizon"]
    investment_goal = user_input["investment_goal"]
    sector_preference = user_input["sector_preference"]
    market_cap_preference = user_input["market_cap_preference"]
    dividend_preference = user_input["dividend_preference"]
    investment_amount = user_input["investment_amount"]

    # Step 1: Score all stocks based on user preferences
    scored_stocks = score_all_stocks(stock_data, risk_appetite, investment_horizon, investment_goal,
                                    sector_preference, market_cap_preference, dividend_preference)
    
    # Step 2: Filter stocks by minimum threshold score
    # Higher threshold for stricter filtering
    threshold_score = 60  # Minimum score out of 100
    
    filtered_stocks = [symbol for symbol, score in scored_stocks if score >= threshold_score]
    
    # Step 3: If no stocks match, gradually reduce threshold until we get matches
    if not filtered_stocks:
        for lower_threshold in [50, 40, 30, 20]:
            filtered_stocks = [symbol for symbol, score in scored_stocks if score >= lower_threshold]
            if filtered_stocks:
                break
    
    # Step 4: Final fallback - use top scored stocks regardless of threshold
    if not filtered_stocks and scored_stocks:
        filtered_stocks = [symbol for symbol, score in scored_stocks[:10]]
    
    # Step 5: Add buy/sell guidance for each recommended stock
    recommended_stocks = []
    for symbol in filtered_stocks[:10]:  # Limit to top 10
        if symbol in stock_data:
            price_guidance = generate_price_guidance(symbol, stock_data[symbol], risk_appetite, investment_horizon)
            recommended_stocks.append((symbol, price_guidance))
    
    return recommended_stocks


def score_all_stocks(stock_data, risk_appetite, investment_horizon, investment_goal,
                    sector_preference, market_cap_preference, dividend_preference):
    """
    Scores all stocks based on user preferences on a scale of 0-100.
    Returns a list of (symbol, score) tuples sorted by score in descending order.
    """
    scored_stocks = []
    
    for symbol, data in stock_data.items():
        # Skip if missing critical data
        if "beta" not in data or "market_cap" not in data or "sector" not in data:
            continue
        
        # Initialize score components
        risk_score = 0
        market_cap_score = 0
        sector_score = 0
        dividend_score = 0
        goal_score = 0
        
        # Calculate risk score (0-25 points)
        beta = data.get("beta", 1.0)
        if risk_appetite == "low":
            # Lower beta is better for low risk
            risk_score = max(0, 25 - (beta * 10)) if beta < 1.5 else 0
        elif risk_appetite == "medium":
            # Beta close to 1.0 is ideal for medium risk
            risk_score = max(0, 25 - (abs(beta - 1.0) * 20))
        else:  # high risk
            # Higher beta is better for high risk (up to about 2.0)
            risk_score = min(beta * 12.5, 25) if beta > 0.8 else 0
        
        # Calculate market cap score (0-15 points)
        market_cap = data.get("market_cap", 0)
        if market_cap_preference == "all":
            market_cap_score = 15
        elif market_cap_preference == "large-cap" and market_cap >= 50000000000:
            market_cap_score = 15
        elif market_cap_preference == "mid-cap" and market_cap >= 10000000000 and market_cap < 50000000000:
            market_cap_score = 15
        elif market_cap_preference == "small-cap" and market_cap < 10000000000:
            market_cap_score = 15
        else:
            # Partial score for close matches
            if market_cap_preference == "large-cap" and market_cap >= 30000000000:
                market_cap_score = 8
            elif market_cap_preference == "mid-cap" and market_cap >= 5000000000:
                market_cap_score = 8
            elif market_cap_preference == "small-cap" and market_cap < 20000000000:
                market_cap_score = 8
        
        # Calculate sector score (0-20 points)
        if sector_preference == "all":
            sector_score = 20
        elif data.get("sector", "").lower() == sector_preference.lower():
            sector_score = 20
        
        # Calculate dividend score (0-15 points)
        dividend_yield = data.get("dividend_yield", 0)
        if dividend_preference == "yes":
            dividend_score = min(dividend_yield * 750, 15)  # Max score at 2% dividend yield
        else:
            dividend_score = 15 - min(dividend_yield * 300, 10)  # Lower dividends preferred
        
        # Calculate goal score (0-25 points)
        if investment_goal == "growth":
            # For growth: higher beta, lower dividend, positive momentum
            change_percent = data.get("change_percent", 0)
            momentum_factor = min(max(change_percent, -5), 10) + 5  # Scale from 0-15
            
            goal_score = min(beta * 8, 15) + (15 - min(dividend_yield * 375, 15)) + (momentum_factor * 0.5)
            goal_score = min(goal_score, 25)  # Cap at 25
            
        elif investment_goal == "dividends":
            # For dividends: stable beta, higher dividend yield
            stability_factor = 15 - min(abs(beta - 0.8) * 10, 15)  # More stable stocks
            goal_score = min(dividend_yield * 1000, 20) + stability_factor * 0.25
            goal_score = min(goal_score, 25)  # Cap at 25
            
        else:  # "both"
            # For both: balanced approach
            balanced_factor = 15 - min(abs(beta - 1.0) * 15, 15)  # Beta around 1.0
            goal_score = min(dividend_yield * 500, 12.5) + balanced_factor + min(max(data.get("change_percent", 0), 0), 5)
            goal_score = min(goal_score, 25)  # Cap at 25
        
        # Investment horizon alignment bonus (0-10)
        horizon_bonus = 0
        if investment_horizon <= 2:  # Short term
            # Favor lower beta stocks for short term investments
            horizon_bonus = max(0, 10 - (beta * 5)) if beta < 1.5 else 0
        elif investment_horizon <= 5:  # Medium term
            # Balanced stocks for medium term
            horizon_bonus = max(0, 10 - (abs(beta - 1.0) * 8))
        else:  # Long term
            # Growth stocks for long term
            if investment_goal == "growth":
                horizon_bonus = min(beta * 5, 10) if beta < 2 else 5
            elif investment_goal == "dividends":
                horizon_bonus = min(dividend_yield * 500, 10)
            else:
                horizon_bonus = min((beta * 2.5) + (dividend_yield * 250), 10)
        
        # Total score (max 100)
        total_score = risk_score + market_cap_score + sector_score + dividend_score + goal_score + horizon_bonus
        
        # Save score
        scored_stocks.append((symbol, total_score))
    
    # Sort by score in descending order
    return sorted(scored_stocks, key=lambda x: x[1], reverse=True)


def generate_price_guidance(symbol, stock_data, risk_appetite, investment_horizon):
    """
    Generates buy and sell price guidance based on current price, risk appetite and investment horizon.
    Returns a dictionary with buy and sell targets.
    """
    current_price = stock_data.get("current_price", 0)
    beta = stock_data.get("beta", 1.0)
    change_percent = stock_data.get("change_percent", 0)
    
    # Base volatility based on beta
    volatility_factor = max(beta, 0.5)
    
    # Adjust based on risk appetite
    if risk_appetite == "low":
        buy_discount = 0.03 * volatility_factor  # Conservative entry point
        profit_target = 0.08 * volatility_factor  # Conservative profit target
        stop_loss = 0.05 * volatility_factor  # Tight stop loss
    elif risk_appetite == "medium":
        buy_discount = 0.05 * volatility_factor
        profit_target = 0.15 * volatility_factor
        stop_loss = 0.08 * volatility_factor
    else:  # high
        buy_discount = 0.08 * volatility_factor
        profit_target = 0.25 * volatility_factor
        stop_loss = 0.12 * volatility_factor
    
    # Adjust based on recent price movement
    if change_percent > 5:
        # Don't chase rallies too high
        buy_discount += 0.02
    elif change_percent < -5:
        # Be cautious on sharp drops
        buy_discount += 0.01
        stop_loss += 0.02
    
    # Adjust based on investment horizon
    if investment_horizon > 5:  # Long term
        profit_target *= 1.5  # Higher profit targets for longer terms
        buy_discount *= 1.2   # More patient entry for long term
    elif investment_horizon < 2:  # Short term
        profit_target *= 0.7  # Lower profit expectations for short term
        stop_loss *= 0.8      # Tighter stops for short term
    
    # Calculate the actual price targets
    buy_target = round(current_price * (1 - buy_discount), 2)
    sell_target = round(current_price * (1 + profit_target), 2)
    stop_loss_price = round(current_price * (1 - stop_loss), 2)
    
    return {
        "buy_target": buy_target,
        "sell_target": sell_target,
        "stop_loss": stop_loss_price,
        "suitability_score": min(stock_data.get("suitability_score", 70), 100),
        # Adding additional trading strategy guidance based on metrics
        "strategy": determine_trading_strategy(stock_data, risk_appetite, investment_horizon)
    }


def determine_trading_strategy(stock_data, risk_appetite, investment_horizon):
    """
    Determines an appropriate trading strategy based on stock metrics and user preferences.
    Returns a string with strategy advice.
    """
    beta = stock_data.get("beta", 1.0)
    dividend_yield = stock_data.get("dividend_yield", 0) * 100  # Convert to percentage
    change_percent = stock_data.get("change_percent", 0)
    
    strategies = []
    
    # Core strategy based on beta and risk
    if beta < 0.8 and risk_appetite == "low":
        strategies.append("Buy and hold")
    elif beta > 1.5 and risk_appetite == "high":
        strategies.append("Momentum trading")
    elif beta > 1.2 and risk_appetite == "medium":
        strategies.append("Swing trading")
    else:
        strategies.append("Position trading")
    
    # Additional advice based on dividend yield
    if dividend_yield > 3:
        strategies.append("Income generator")
    
    # Market timing guidance
    if change_percent > 4:
        strategies.append("Wait for pullback")
    elif change_percent < -4:
        strategies.append("Buy incrementally")
    
    # Volume and investment horizon considerations
    if investment_horizon > 5 and beta < 1.3:
        strategies.append("Long-term investment")
    elif investment_horizon < 2:
        strategies.append("Monitor closely")
    
    return " | ".join(strategies)