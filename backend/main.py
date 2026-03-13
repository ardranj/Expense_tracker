from fastapi import FastAPI
from database import engine, SessionLocal
import models
import schemas
from sqlalchemy.orm import Session

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
# ADD GOAL
# -------------------------

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


# -------------------------
# GET GOALS
# -------------------------

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

# -------------------------
# AI ANALYSIS
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
            "saving_suggestion": "Track more expenses",
            "goal_prediction_months": 0
        }

    total_spending = sum(e.amount for e in expenses)

    predicted_monthly_spending = total_spending

    category_totals = {}

    for e in expenses:
        category_totals[e.category] = category_totals.get(e.category, 0) + e.amount

    top_category = max(category_totals, key=category_totals.get)

    budget_prediction = "You may exceed your budget"

    saving_suggestion = f"Reduce spending on {top_category}"

    goal_prediction = round(20000 / (total_spending / len(expenses))) if len(expenses) > 0 else 0

    return {
        "predicted_monthly_spending": predicted_monthly_spending,
        "top_spending_category": top_category,
        "budget_prediction": budget_prediction,
        "saving_suggestion": saving_suggestion,
        "goal_prediction_months": goal_prediction
    }