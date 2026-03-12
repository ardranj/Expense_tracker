from sqlalchemy import Column, Integer, String, Float
from database import Base


class User(Base):

    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)

    name = Column(String)

    email = Column(String, unique=True)

    phone = Column(String)

    password = Column(String)


class Expense(Base):

    __tablename__ = "expenses"

    id = Column(Integer, primary_key=True, index=True)

    title = Column(String)

    category = Column(String)

    amount = Column(Float)

    type = Column(String)

    date = Column(String)