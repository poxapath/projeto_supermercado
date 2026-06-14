# 📋 Guia Completo — Projeto Avaliativo 2º Bimestre

## Estrutura do que você vai entregar

```
projeto_supermercado/          ← seu repo Flutter (já existe)
  lib/
    main.dart
    theme/app_theme.dart
    models/produto.dart
    repositories/
      produto_local_repository.dart   ← SQLite
      produto_api_repository.dart     ← API Render
    services/produto_service.dart     ← camada service
    screens/
      home_screen.dart
      produto_form_screen.dart
      produto_detalhe_screen.dart
  pubspec.yaml

supermercado_api/              ← novo repo separado para o backend
  main.py
  requirements.txt
  Procfile
  render.yaml
```

---

## PARTE 1 — Subir a API no Render (backend)

### 1.1 — Criar repositório da API no GitHub

1. Acesse https://github.com/new
2. Nome: `supermercado_api`
3. Visibilidade: **Public**
4. Clique em **Create repository**
5. No terminal da sua máquina:

```bash
cd supermercado_api   # pasta com os arquivos que você baixou
git init
git add .
git commit -m "feat: API FastAPI com PostgreSQL"
git remote add origin https://github.com/SEU_USUARIO/supermercado_api.git
git push -u origin main
```

### 1.2 — Criar conta no Render

1. Acesse https://render.com
2. Clique em **Get Started** → faça login com sua conta do GitHub

### 1.3 — Criar o banco PostgreSQL no Render

1. No dashboard do Render, clique em **New +** → **PostgreSQL**
2. Preencha:
   - **Name:** `supermercado-db`
   - **Plan:** Free
3. Clique em **Create Database**
4. Aguarde alguns minutos até ficar **Available**
5. Anote a **Internal Database URL** (vai precisar no próximo passo)

### 1.4 — Criar o Web Service (API)

1. Clique em **New +** → **Web Service**
2. Conecte ao repositório `supermercado_api` do GitHub
3. Preencha:
   - **Name:** `supermercado-api`
   - **Runtime:** Python 3
   - **Build Command:** `pip install -r requirements.txt`
   - **Start Command:** `uvicorn main:app --host 0.0.0.0 --port $PORT`
   - **Plan:** Free
4. Em **Environment Variables**, adicione:
   - Key: `DATABASE_URL`
   - Value: cole a **Internal Database URL** do passo anterior
5. Clique em **Create Web Service**
6. Aguarde o deploy (pode demorar 5-10 min na primeira vez)
7. Ao terminar, você terá uma URL tipo: `https://supermercado-api-xxxx.onrender.com`

### 1.5 — Testar a API

Acesse no navegador:
```
https://supermercado-api-xxxx.onrender.com/
https://supermercado-api-xxxx.onrender.com/produtos
https://supermercado-api-xxxx.onrender.com/docs   ← documentação automática!
```

⚠️ **IMPORTANTE:** O plano gratuito do Render "dorme" após 15 min sem uso.
A primeira requisição pode demorar ~30 segundos para "acordar". Isso é normal.

---

## PARTE 2 — Atualizar o Flutter com a URL da API

Após obter a URL do Render, abra o arquivo:
```
lib/repositories/produto_api_repository.dart
```

Troque a linha:
```dart
static const String _baseUrl = 'https://SEU-APP.onrender.com';
```
Por:
```dart
static const String _baseUrl = 'https://supermercado-api-xxxx.onrender.com';
```
(substitua pelo endereço real do seu app no Render)

---

## PARTE 3 — Atualizar o Flutter (adicionar os arquivos novos)

### 3.1 — Substituir os arquivos

Copie os arquivos gerados para dentro da pasta `projeto_supermercado`:

```
lib/main.dart                          → substitui o existente
lib/theme/app_theme.dart               → pasta nova
lib/models/produto.dart                → pasta nova
lib/repositories/produto_local_repository.dart
lib/repositories/produto_api_repository.dart
lib/services/produto_service.dart      → pasta nova
lib/screens/home_screen.dart           → pasta nova
lib/screens/produto_form_screen.dart
lib/screens/produto_detalhe_screen.dart
pubspec.yaml                           → substitui o existente
```

### 3.2 — Instalar as dependências

```bash
cd projeto_supermercado
flutter pub get
```

### 3.3 — Testar no emulador/celular

```bash
flutter run
```

---

## PARTE 4 — Commitar e subir no GitHub

Faça commits organizados (o professor avalia a clareza dos commits):

```bash
git add pubspec.yaml
git commit -m "feat: adiciona dependências sqflite e http"

git add lib/theme/
git commit -m "feat: implementa tema visual global AppTheme"

git add lib/models/
git commit -m "feat: modelo Produto com suporte a JSON e Map"

git add lib/repositories/
git commit -m "feat: repositórios local (SQLite) e remoto (API)"

git add lib/services/
git commit -m "feat: camada service com estratégia offline-first"

git add lib/screens/
git commit -m "feat: telas de listagem, formulário e detalhes"

git add lib/main.dart
git commit -m "feat: entry point com MaterialApp e tema global"

git push origin main
```

---

## PARTE 5 — Vídeo de demonstração

O professor pede um vídeo demonstrando o funcionamento. Sugestão de roteiro:

1. Abrir o app → mostrar tela inicial
2. Adicionar um produto novo (cadastro)
3. Ver o produto na lista
4. Tocar no produto → ver detalhes
5. Editar o produto
6. Filtrar por categoria
7. Excluir um produto
8. Mostrar a API funcionando em `https://SEU-APP.onrender.com/docs`

Use o gravador de tela do celular ou emulador (no Android Studio: Extended Controls → Screen Record).

---

## Checklist final antes de entregar

- [ ] Repositório Flutter público no GitHub (ou professor adicionado como colaborador)
- [ ] Commits organizados com mensagens descritivas
- [ ] `pubspec.yaml` com sqflite e http
- [ ] SQLite funcionando (criar/listar/editar/excluir localmente)
- [ ] API publicada no Render com PostgreSQL
- [ ] URL da API correta em `produto_api_repository.dart`
- [ ] Integração Flutter ↔ API funcionando
- [ ] Camadas model / repository / service separadas
- [ ] Tema visual consistente (ThemeData global)
- [ ] Vídeo gravado e enviado
