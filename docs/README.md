# 🎬📚 Locadora de Filmes e Livros — Modelagem de Banco de Dados

Repositório criado como entregável do desafio prático da [Digital Innovation One (DIO)](https://www.dio.me/), parte da trilha de fundamentos de banco de dados com **Azure SQL Database**. Aqui está documentada a modelagem completa de um sistema de **locadora de filmes e livros**: do modelo conceitual ao script SQL executável, com dados de exemplo e consultas de teste.

---

## 📌 Sobre o projeto

O objetivo é modelar e implementar um banco de dados relacional capaz de controlar:

- O acervo de **filmes** e **livros** disponíveis para locação;
- O cadastro de **clientes** e **funcionários**;
- O processo de **locação**, permitindo que um cliente alugue múltiplos itens em uma única transação;
- O controle de **devolução**, prazos e status de cada locação.

---

## 🧠 Modelo conceitual (Diagrama ER)

O modelo usa duas estratégias de **generalização/especialização** para evitar duplicação de dados:

1. **PESSOA** é a base comum para **CLIENTE** e **FUNCIONARIO** — ambos são "pessoas" que compartilham nome, CPF, telefone e endereço, mas têm atributos específicos do seu papel no sistema.
2. **ITEM** é a base comum para **FILME** e **LIVRO** — ambos são "itens locáveis" que compartilham título, categoria, valor de locação e estoque, mas têm atributos específicos do seu tipo de mídia.

```mermaid
erDiagram
  PESSOA ||--o| CLIENTE : "e"
  PESSOA ||--o| FUNCIONARIO : "e"
  CLIENTE ||--o{ LOCACAO : realiza
  FUNCIONARIO ||--o{ LOCACAO : registra
  LOCACAO ||--|{ LOCACAO_ITEM : contem
  ITEM ||--o{ LOCACAO_ITEM : "e referenciado em"
  CATEGORIA ||--o{ ITEM : classifica
  ITEM ||--o| FILME : especializa
  ITEM ||--o| LIVRO : especializa

  PESSOA {
    int id_pessoa PK
    string nome
    string cpf
    string telefone
    string endereco
  }
  CLIENTE {
    int id_pessoa PK_FK
    date data_cadastro
    string status
  }
  FUNCIONARIO {
    int id_pessoa PK_FK
    string cargo
    decimal salario
  }
  CATEGORIA {
    int id_categoria PK
    string nome
    string tipo
  }
  ITEM {
    int id_item PK
    string titulo
    int id_categoria FK
    decimal valor_locacao
    int qtd_estoque
    string tipo_item
  }
  FILME {
    int id_item PK_FK
    string diretor
    int duracao_min
    string classificacao
  }
  LIVRO {
    int id_item PK_FK
    string autor
    string isbn
    int num_paginas
  }
  LOCACAO {
    int id_locacao PK
    int id_cliente FK
    int id_funcionario FK
    date data_locacao
    date data_prevista_devolucao
    date data_devolucao
    string status
  }
  LOCACAO_ITEM {
    int id_locacao PK_FK
    int id_item PK_FK
    decimal valor_cobrado
    string condicao_devolucao
  }
```

> 💡 O GitHub renderiza blocos `mermaid` automaticamente — esse diagrama aparece visualmente ao abrir o README na plataforma.

### Por que essa modelagem?

| Decisão | Justificativa |
|---|---|
| `PESSOA` separada de `CLIENTE`/`FUNCIONARIO` | Evita duplicar nome/CPF/telefone caso uma mesma pessoa um dia precise ser ambos, e centraliza validações de dado pessoal. |
| `ITEM` separado de `FILME`/`LIVRO` | Permite consultas genéricas sobre "todo o acervo" sem UNION, e mantém os atributos específicos de cada mídia isolados. |
| `LOCACAO` + `LOCACAO_ITEM` (cabeçalho + itens) | Modela corretamente o cenário real: uma locação pode conter vários itens, como em uma nota fiscal com vários produtos. |
| `CATEGORIA` com campo `tipo` | Permite categorias exclusivas de filme, de livro, ou compartilhadas entre os dois. |

---

## 🗂️ Estrutura do repositório

```
locadora-db/
├── README.md
├── scripts/
│   ├── 01_ddl_criacao_tabelas.sql      # Criação de todas as tabelas, PKs, FKs e constraints
│   ├── 02_dml_dados_exemplo.sql         # Inserção de dados de exemplo para testes
│   └── 03_queries_teste.sql              # 10 consultas de validação e exemplos de uso
├── diagrama/
│   └── diagrama-er.md                     # Diagrama ER em sintaxe Mermaid (renderiza no GitHub)
└── docs/
    └── dicionario-dados.md                # Dicionário de dados completo (tabelas e colunas)
```

---

## 🚀 Como executar no Azure SQL Database

1. Crie um banco de dados Azure SQL Database (ou use uma Managed Instance) via [Azure Portal](https://portal.azure.com);
2. Conecte-se usando o **Azure Data Studio**, **SSMS** ou a extensão **mssql** do VS Code;
3. Execute os scripts **na ordem**:

```sql
-- 1. Estrutura do banco
:r scripts/01_ddl_criacao_tabelas.sql

-- 2. Dados de exemplo
:r scripts/02_dml_dados_exemplo.sql

-- 3. Consultas de teste
:r scripts/03_queries_teste.sql
```

> 💡 Se estiver usando a interface gráfica, basta abrir cada arquivo `.sql` e executar com `Ctrl+Shift+E` (Azure Data Studio) ou `F5` (SSMS), respeitando a ordem 01 → 02 → 03.

---

## 🔍 Exemplos de consultas incluídas

O arquivo [`03_queries_teste.sql`](scripts/03_queries_teste.sql) traz 10 consultas prontas, incluindo:

- Listagem de todo o acervo com categoria;
- Locações em andamento ou atrasadas;
- Cálculo de valor total cobrado por locação usando `SUM() OVER (PARTITION BY ...)`;
- Ranking dos itens mais alugados;
- Faturamento total por funcionário;
- Itens disponíveis em estoque por categoria.

---

## 📖 Dicionário de dados

A documentação completa de cada tabela e coluna está em [`docs/dicionario-dados.md`](docs/dicionario-dados.md).

---

## 💡 Possíveis melhorias futuras

- [ ] Adicionar tabela de **multas** para locações devolvidas com atraso;
- [ ] Criar **stored procedures** para registrar locação e devolução com validação de estoque;
- [ ] Adicionar **trigger** para decrementar `qtd_estoque` automaticamente ao registrar uma locação;
- [ ] Implementar **views** para relatórios gerenciais recorrentes;
- [ ] Adicionar tabela de **reservas** para itens temporariamente esgotados.

---

## 📚 Referências

- [Documentação oficial do Azure SQL Database](https://learn.microsoft.com/pt-br/azure/azure-sql/database/)
- [Guia de Markdown do GitHub](https://docs.github.com/pt/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax)
- [Sintaxe de diagramas ER do Mermaid](https://mermaid.js.org/syntax/entityRelationshipDiagram.html)

---

## 👤 Autora

**Milla** — desenvolvedora e estudante de pós-graduação em Monitoramento Atmosférico.
🔗 [camilaloliveira.com](https://camilaloliveira.com) · ✉️ ola@camilaloliveira.com · 💻 GitHub: [@clcmo](https://github.com/clcmo)

---

> 📝 Repositório criado como parte do bootcamp/trilha da [Digital Innovation One (DIO)](https://www.dio.me/), com fins exclusivamente educacionais.
