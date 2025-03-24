def get_user_input():
    """
    Collects user input for risk appetite, income, investment horizon, and additional preferences.
    """
    print("Welcome to the Financial Advisor!")
    risk_appetite = input("Enter your risk appetite (low/medium/high): ").strip().lower()
    income = float(input("Enter your annual income (in INR): "))
    investment_horizon = int(input("Enter your investment horizon in years: "))
    investment_goal = input("Enter your investment goal (growth/dividends/both): ").strip().lower()
    sector_preference = input("Enter your preferred sector (e.g., IT, banking, healthcare, all): ").strip().lower()
    market_cap_preference = input("Enter your market cap preference (large-cap/mid-cap/small-cap): ").strip().lower()
    dividend_preference = input("Do you prefer high-dividend stocks? (yes/no): ").strip().lower()
    investment_amount = float(input("Enter the amount you want to invest (in INR): "))

    return {
        "risk_appetite": risk_appetite,
        "income": income,
        "investment_horizon": investment_horizon,
        "investment_goal": investment_goal,
        "sector_preference": sector_preference,
        "market_cap_preference": market_cap_preference,
        "dividend_preference": dividend_preference,
        "investment_amount": investment_amount,
    }