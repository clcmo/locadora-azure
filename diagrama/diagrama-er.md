# Diagrama ER — Locadora de Filmes e Livros

Diagrama Entidade-Relacionamento completo do sistema, em sintaxe [Mermaid](https://mermaid.js.org/syntax/entityRelationshipDiagram.html). O GitHub renderiza este bloco automaticamente ao visualizar o arquivo.

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

## Cardinalidades

| Relacionamento | Cardinalidade | Significado |
|---|---|---|
| PESSOA — CLIENTE | 1:0..1 | Uma pessoa pode (ou não) ser cliente |
| PESSOA — FUNCIONARIO | 1:0..1 | Uma pessoa pode (ou não) ser funcionário |
| CLIENTE — LOCACAO | 1:N | Um cliente pode realizar várias locações |
| FUNCIONARIO — LOCACAO | 1:N | Um funcionário pode registrar várias locações |
| LOCACAO — LOCACAO_ITEM | 1:N (mínimo 1) | Toda locação tem ao menos um item |
| ITEM — LOCACAO_ITEM | 1:N | Um item pode aparecer em várias locações ao longo do tempo |
| CATEGORIA — ITEM | 1:N | Uma categoria classifica vários itens |
| ITEM — FILME | 1:0..1 | Um item pode (ou não) ser especializado como filme |
| ITEM — LIVRO | 1:0..1 | Um item pode (ou não) ser especializado como livro |
