from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import create_engine, Column, Integer, String, Float, text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
from pydantic import BaseModel
from typing import Optional
import os

# ── Configuração do banco ──────────────────────────────────────────────────────
DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./supermercado.db")

# Render fornece URLs postgres://, SQLAlchemy precisa de postgresql://
if DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# ── Modelo do banco ────────────────────────────────────────────────────────────
class ProdutoModel(Base):
    __tablename__ = "produtos"

    id       = Column(Integer, primary_key=True, index=True)
    nome     = Column(String, nullable=False)
    categoria = Column(String, nullable=False)
    preco    = Column(Float, nullable=False)
    estoque  = Column(Integer, nullable=False, default=0)
    unidade  = Column(String, default="un")

Base.metadata.create_all(bind=engine)

# ── Schemas Pydantic ───────────────────────────────────────────────────────────
class ProdutoCreate(BaseModel):
    nome: str
    categoria: str
    preco: float
    estoque: int
    unidade: str = "un"

class ProdutoUpdate(BaseModel):
    nome: Optional[str] = None
    categoria: Optional[str] = None
    preco: Optional[float] = None
    estoque: Optional[int] = None
    unidade: Optional[str] = None

class ProdutoResponse(BaseModel):
    id: int
    nome: str
    categoria: str
    preco: float
    estoque: int
    unidade: str

    class Config:
        from_attributes = True

# ── App ────────────────────────────────────────────────────────────────────────
app = FastAPI(title="Supermercado API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# ── Rotas ──────────────────────────────────────────────────────────────────────

@app.get("/")
def root():
    return {"message": "Supermercado API online 🛒"}

@app.get("/produtos", response_model=list[ProdutoResponse])
def listar_produtos(db: Session = Depends(get_db)):
    return db.query(ProdutoModel).all()

@app.get("/produtos/{produto_id}", response_model=ProdutoResponse)
def buscar_produto(produto_id: int, db: Session = Depends(get_db)):
    produto = db.query(ProdutoModel).filter(ProdutoModel.id == produto_id).first()
    if not produto:
        raise HTTPException(status_code=404, detail="Produto não encontrado")
    return produto

@app.post("/produtos", response_model=ProdutoResponse, status_code=201)
def criar_produto(produto: ProdutoCreate, db: Session = Depends(get_db)):
    db_produto = ProdutoModel(**produto.model_dump())
    db.add(db_produto)
    db.commit()
    db.refresh(db_produto)
    return db_produto

@app.put("/produtos/{produto_id}", response_model=ProdutoResponse)
def atualizar_produto(produto_id: int, produto: ProdutoUpdate, db: Session = Depends(get_db)):
    db_produto = db.query(ProdutoModel).filter(ProdutoModel.id == produto_id).first()
    if not db_produto:
        raise HTTPException(status_code=404, detail="Produto não encontrado")
    for campo, valor in produto.model_dump(exclude_unset=True).items():
        setattr(db_produto, campo, valor)
    db.commit()
    db.refresh(db_produto)
    return db_produto

@app.delete("/produtos/{produto_id}", status_code=204)
def excluir_produto(produto_id: int, db: Session = Depends(get_db)):
    db_produto = db.query(ProdutoModel).filter(ProdutoModel.id == produto_id).first()
    if not db_produto:
        raise HTTPException(status_code=404, detail="Produto não encontrado")
    db.delete(db_produto)
    db.commit()
