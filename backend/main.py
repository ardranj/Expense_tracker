from fastapi import FastAPI
from database import engine, SessionLocal
import models
import schemas

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