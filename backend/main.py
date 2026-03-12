from fastapi import FastAPI
from database import engine, SessionLocal
import models
import schemas

app = FastAPI()

models.Base.metadata.create_all(bind=engine)


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