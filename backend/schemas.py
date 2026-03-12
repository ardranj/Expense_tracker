from pydantic import BaseModel

class ExpenseCreate(BaseModel):

    title: str
    category: str
    amount: float
    type: str
    date: str