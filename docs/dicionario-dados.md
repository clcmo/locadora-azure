# 📖 Dicionário de Dados — Locadora de Filmes e Livros

Documentação detalhada de cada tabela e coluna do banco de dados.

---

## PESSOA

Tabela base que armazena os dados pessoais comuns a clientes e funcionários.

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id_pessoa` | INT | PK, IDENTITY | Identificador único, gerado automaticamente |
| `nome` | NVARCHAR(120) | NOT NULL | Nome completo da pessoa |
| `cpf` | CHAR(11) | NOT NULL, UNIQUE | CPF sem formatação (somente números) |
| `telefone` | NVARCHAR(20) | NULL | Telefone de contato |
| `endereco` | NVARCHAR(200) | NULL | Endereço completo |
| `data_criacao` | DATETIME2 | NOT NULL, DEFAULT | Data/hora de criação do registro |

---

## CLIENTE

Especialização de `PESSOA` para clientes da locadora.

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id_pessoa` | INT | PK, FK → PESSOA | Referência à pessoa correspondente |
| `data_cadastro` | DATE | NOT NULL, DEFAULT | Data de cadastro como cliente |
| `status` | NVARCHAR(20) | NOT NULL, CHECK | `ativo`, `inativo` ou `bloqueado` |

---

## FUNCIONARIO

Especialização de `PESSOA` para funcionários da locadora.

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id_pessoa` | INT | PK, FK → PESSOA | Referência à pessoa correspondente |
| `cargo` | NVARCHAR(60) | NOT NULL | Cargo/função do funcionário |
| `salario` | DECIMAL(10,2) | NOT NULL, CHECK ≥ 0 | Salário mensal |

---

## CATEGORIA

Classificação temática dos itens do acervo.

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id_categoria` | INT | PK, IDENTITY | Identificador único |
| `nome` | NVARCHAR(60) | NOT NULL, UNIQUE | Nome da categoria (ex: Drama, Ação) |
| `tipo` | NVARCHAR(20) | NOT NULL, CHECK | `filme`, `livro` ou `ambos` |

---

## ITEM

Tabela base que armazena os dados comuns a qualquer item locável (filme ou livro).

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id_item` | INT | PK, IDENTITY | Identificador único |
| `titulo` | NVARCHAR(150) | NOT NULL | Título do filme ou livro |
| `id_categoria` | INT | NOT NULL, FK → CATEGORIA | Categoria do item |
| `valor_locacao` | DECIMAL(8,2) | NOT NULL, CHECK ≥ 0 | Valor cobrado por locação |
| `qtd_estoque` | INT | NOT NULL, DEFAULT 1, CHECK ≥ 0 | Quantidade disponível em estoque |
| `tipo_item` | NVARCHAR(10) | NOT NULL, CHECK | `filme` ou `livro` |

---

## FILME

Especialização de `ITEM` com atributos próprios de filmes.

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id_item` | INT | PK, FK → ITEM | Referência ao item correspondente |
| `diretor` | NVARCHAR(120) | NOT NULL | Nome do diretor |
| `duracao_min` | INT | NOT NULL, CHECK > 0 | Duração em minutos |
| `classificacao` | NVARCHAR(10) | NULL | Classificação indicativa (ex: Livre, 12, 16, 18) |

---

## LIVRO

Especialização de `ITEM` com atributos próprios de livros.

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id_item` | INT | PK, FK → ITEM | Referência ao item correspondente |
| `autor` | NVARCHAR(120) | NOT NULL | Nome do autor |
| `isbn` | CHAR(13) | NULL, UNIQUE | Código ISBN-13 do livro |
| `num_paginas` | INT | NOT NULL, CHECK > 0 | Número de páginas |

---

## LOCACAO

Cabeçalho de uma transação de locação — pode conter múltiplos itens.

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id_locacao` | INT | PK, IDENTITY | Identificador único |
| `id_cliente` | INT | NOT NULL, FK → CLIENTE | Cliente que realizou a locação |
| `id_funcionario` | INT | NOT NULL, FK → FUNCIONARIO | Funcionário que atendeu/registrou |
| `data_locacao` | DATE | NOT NULL, DEFAULT | Data em que a locação foi feita |
| `data_prevista_devolucao` | DATE | NOT NULL | Data limite para devolução |
| `data_devolucao` | DATE | NULL | Data real de devolução (NULL se ainda não devolvido) |
| `status` | NVARCHAR(20) | NOT NULL, CHECK | `em_andamento`, `finalizada`, `atrasada` ou `cancelada` |

---

## LOCACAO_ITEM

Tabela associativa entre `LOCACAO` e `ITEM` — representa cada item específico dentro de uma locação.

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id_locacao` | INT | PK (composta), FK → LOCACAO | Locação à qual o item pertence |
| `id_item` | INT | PK (composta), FK → ITEM | Item alugado |
| `valor_cobrado` | DECIMAL(8,2) | NOT NULL, CHECK ≥ 0 | Valor efetivamente cobrado por este item |
| `condicao_devolucao` | NVARCHAR(100) | NULL | Observações sobre o estado do item na devolução |

---

## Índices criados

| Índice | Tabela | Coluna(s) | Finalidade |
|---|---|---|---|
| `IX_ITEM_TITULO` | ITEM | titulo | Acelerar buscas por título |
| `IX_LOCACAO_STATUS` | LOCACAO | status | Acelerar filtros por status de locação |
| `IX_LOCACAO_DATA` | LOCACAO | data_locacao | Acelerar consultas por período |
| `IX_PESSOA_CPF` | PESSOA | cpf | Acelerar buscas por CPF |
