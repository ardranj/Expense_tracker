from pydantic import BaseModel


class UserCreate(BaseModel):

    name: str
    email: str
    phone: str
    password: str


class UserLogin(BaseModel):

    email: str
    password: str


class ExpenseCreate(BaseModel):

    title: str
    category: str
    amount: float
    type: str
    date: str