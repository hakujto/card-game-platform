from sqlalchemy import Column, Integer, String
from app.db import Base


class User(Base):
    __tablename__ = "user"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(150), unique=True, index=True)
    email = Column(String(255), unique=True, index=True)
    hashed_password = Column(String(255))
    is_active = Column(Integer, default=1)

    def __repr__(self) -> str:
        return f"<User id={self.id} username={self.username!r}>"
