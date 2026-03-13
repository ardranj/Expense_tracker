from fastapi import FastAPI
from database import engine, SessionLocal
import models
import schemas
from sqlalchemy.orm import Session

from sklearn.linear_model import LinearRegression
import numpy as np
import pandas as pd

app = FastAPI()

models.Base.metadata.create_all(bind=engine)


# -------------------------
# REGISTER USER
# -------------------------

@app.post("/register")
def register(user: schemas.UserCreate):

    db = SessionLocal()

    existing_user = db.query(models.User).filter(
        models.User.email == user.email
    ).first()

    if existing_user:
        return {"error": "User already exists"}

    new_user = models.User(
        name=user.name,
        email=user.email,
        phone=user.phone,
        password=user.password
    )

    db.add(new_user)
    db.commit()

    return {"message": "Account created successfully"}


# -------------------------
# LOGIN USER
# -------------------------

@app.post("/login")
def login(user: schemas.UserLogin):

    db = SessionLocal()

    existing_user = db.query(models.User).filter(
        models.User.email == user.email
    ).first()

    if not existing_user:
        return {"error": "User not found"}

    if existing_user.password != user.password:
        return {"error": "Invalid password"}

    return {
        "message": "Login successful",
        "email": existing_user.email
    }


# -------------------------
# ADD EXPENSE
# -------------------------

@app.post("/add-expense")
def add_expense(expense: schemas.ExpenseCreate):

    db = SessionLocal()

    new_expense = models.Expense(
        title=expense.title,
        category=expense.category,
        amount=expense.amount,
        type=expense.type,
        date=expense.date
    )

    db.add(new_expense)
    db.commit()

    return {"message": "Expense added successfully"}


# -------------------------
# GET TRANSACTIONS
# -------------------------

@app.get("/transactions")
def get_transactions():

    db = SessionLocal()

    expenses = db.query(models.Expense).all()

    return [
        {
            "title": e.title,
            "category": e.category,
            "amount": e.amount,
            "type": e.type,
            "date": e.date
        }
        for e in expenses
    ]


# -------------------------
# AI ANALYSIS USING LINEAR REGRESSION
# -------------------------

@app.get("/ai-analysis")
def ai_analysis():

    db: Session = SessionLocal()

    expenses = db.query(models.Expense).all()

    if not expenses:
        return {
            "predicted_monthly_spending": 0,
            "top_spending_category": "None",
            "budget_prediction": "No data",
            "saving_suggestion": "Add some expenses",
            "goal_prediction_months": 0
        }

    # total spending
    total_spent = 0

    # category totals
    category_totals = {}

    # monthly totals
    monthly_totals = {}

    for e in expenses:

        if e.type == "expense":

            amount = float(e.amount)

            total_spent += amount

            # category totals
            category_totals[e.category] = (
                category_totals.get(e.category, 0) + amount
            )

            # month key
            month = e.date[:7]  # YYYY-MM

            monthly_totals[month] = (
                monthly_totals.get(month, 0) + amount
            )

    # predicted monthly spending = average monthly spending
    predicted_monthly_spending = (
        sum(monthly_totals.values()) / len(monthly_totals)
    )

    # top category
    top_category = max(category_totals, key=category_totals.get)

    # simple budget prediction
    monthly_budget = 5000

    if predicted_monthly_spending > monthly_budget:
        budget_prediction = "You may exceed your budget"
    else:
        budget_prediction = "You are within budget"

    saving_suggestion = f"Reduce spending on {top_category}"

    # goal prediction
    target_goal = 20000

    if predicted_monthly_spending > 0:
        goal_months = round(target_goal / predicted_monthly_spending)
    else:
        goal_months = 0

    return {
        "predicted_monthly_spending": round(predicted_monthly_spending, 2),
        "top_spending_category": top_category,
        "budget_prediction": budget_prediction,
        "saving_suggestion": saving_suggestion,
        "goal_prediction_months": goal_months
    }

@app.post("/add-goal")
def add_goal(goal: schemas.GoalCreate):

    db = SessionLocal()

    new_goal = models.Goal(
        title=goal.title,
        target=goal.target,
        saved=goal.saved,
        monthlyContribution=goal.monthlyContribution,
        deadline=goal.deadline
    )

    db.add(new_goal)
    db.commit()

    return {"message": "Goal added successfully"}

@app.get("/goals")
def get_goals():

    db = SessionLocal()

    goals = db.query(models.Goal).all()

    return [
        {
            "title": g.title,
            "target": g.target,
            "saved": g.saved,
            "monthlyContribution": g.monthlyContribution,
            "deadline": g.deadline
        }
        for g in goals
    ]

