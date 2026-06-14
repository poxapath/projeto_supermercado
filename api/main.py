from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import text
import os

app = Flask(__name__)

DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///supermercado.db")
if DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)

app.config["SQLALCHEMY_DATABASE_URI"] = DATABASE_URL
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

db = SQLAlchemy(app)

class Produto(db.Model):
    __tablename__ = "produtos"
    id       = db.Column(db.Integer, primary_key=True)
    nome     = db.Column(db.String, nullable=False)
    categoria = db.Column(db.String, nullable=False)
    preco    = db.Column(db.Float, nullable=False)
    estoque  = db.Column(db.Integer, nullable=False, default=0)
    unidade  = db.Column(db.String, default="un")

    def to_dict(self):
        return {
            "id": self.id,
            "nome": self.nome,
            "categoria": self.categoria,
            "preco": self.preco,
            "estoque": self.estoque,
            "unidade": self.unidade,
        }

with app.app_context():
    db.create_all()

@app.route("/")
def root():
    return jsonify({"message": "Supermercado API online 🛒"})

@app.route("/produtos", methods=["GET"])
def listar():
    produtos = Produto.query.order_by(Produto.nome).all()
    return jsonify([p.to_dict() for p in produtos])

@app.route("/produtos/<int:id>", methods=["GET"])
def buscar(id):
    p = db.get_or_404(Produto, id)
    return jsonify(p.to_dict())

@app.route("/produtos", methods=["POST"])
def criar():
    d = request.json
    p = Produto(**d)
    db.session.add(p)
    db.session.commit()
    return jsonify(p.to_dict()), 201

@app.route("/produtos/<int:id>", methods=["PUT"])
def atualizar(id):
    p = db.get_or_404(Produto, id)
    for k, v in request.json.items():
        setattr(p, k, v)
    db.session.commit()
    return jsonify(p.to_dict())

@app.route("/produtos/<int:id>", methods=["DELETE"])
def excluir(id):
    p = db.get_or_404(Produto, id)
    db.session.delete(p)
    db.session.commit()
    return "", 204