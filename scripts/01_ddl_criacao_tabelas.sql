-- =====================================================================
-- Locadora de Filmes e Livros — Script DDL (Data Definition Language)
-- Compatível com Azure SQL Database / SQL Server (T-SQL)
-- =====================================================================
-- Ordem de criação respeita as dependências de chave estrangeira:
-- PESSOA -> CLIENTE / FUNCIONARIO -> CATEGORIA -> ITEM -> FILME / LIVRO
-- -> LOCACAO -> LOCACAO_ITEM
-- =====================================================================

-- Caso esteja recriando o banco do zero, descomente as linhas abaixo
-- DROP TABLE IF EXISTS LOCACAO_ITEM;
-- DROP TABLE IF EXISTS LOCACAO;
-- DROP TABLE IF EXISTS LIVRO;
-- DROP TABLE IF EXISTS FILME;
-- DROP TABLE IF EXISTS ITEM;
-- DROP TABLE IF EXISTS CATEGORIA;
-- DROP TABLE IF EXISTS FUNCIONARIO;
-- DROP TABLE IF EXISTS CLIENTE;
-- DROP TABLE IF EXISTS PESSOA;

-- =====================================================================
-- 1. PESSOA — tabela base para evitar duplicação de dados pessoais
--    entre Cliente e Funcionario (especialização/generalização)
-- =====================================================================
CREATE TABLE PESSOA (
    id_pessoa     INT IDENTITY(1,1) PRIMARY KEY,
    nome          NVARCHAR(120) NOT NULL,
    cpf           CHAR(11) NOT NULL UNIQUE,
    telefone      NVARCHAR(20)  NULL,
    endereco      NVARCHAR(200) NULL,
    data_criacao  DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME()
);

-- =====================================================================
-- 2. CLIENTE — especialização de PESSOA (relação 1:1)
-- =====================================================================
CREATE TABLE CLIENTE (
    id_pessoa       INT PRIMARY KEY,
    data_cadastro   DATE NOT NULL DEFAULT CAST(SYSUTCDATETIME() AS DATE),
    status          NVARCHAR(20) NOT NULL DEFAULT 'ativo'
                      CONSTRAINT CK_CLIENTE_STATUS CHECK (status IN ('ativo', 'inativo', 'bloqueado')),
    CONSTRAINT FK_CLIENTE_PESSOA FOREIGN KEY (id_pessoa)
        REFERENCES PESSOA(id_pessoa) ON DELETE CASCADE
);

-- =====================================================================
-- 3. FUNCIONARIO — especialização de PESSOA (relação 1:1)
-- =====================================================================
CREATE TABLE FUNCIONARIO (
    id_pessoa     INT PRIMARY KEY,
    cargo         NVARCHAR(60) NOT NULL,
    salario       DECIMAL(10,2) NOT NULL CHECK (salario >= 0),
    CONSTRAINT FK_FUNCIONARIO_PESSOA FOREIGN KEY (id_pessoa)
        REFERENCES PESSOA(id_pessoa) ON DELETE CASCADE
);

-- =====================================================================
-- 4. CATEGORIA — classificação de itens (Drama, Ficção, Romance, etc.)
-- =====================================================================
CREATE TABLE CATEGORIA (
    id_categoria  INT IDENTITY(1,1) PRIMARY KEY,
    nome          NVARCHAR(60) NOT NULL UNIQUE,
    tipo          NVARCHAR(20) NOT NULL
                    CONSTRAINT CK_CATEGORIA_TIPO CHECK (tipo IN ('filme', 'livro', 'ambos'))
);

-- =====================================================================
-- 5. ITEM — tabela base para FILME e LIVRO (generalização)
--    Guarda os dados comuns a qualquer item locável do acervo.
-- =====================================================================
CREATE TABLE ITEM (
    id_item        INT IDENTITY(1,1) PRIMARY KEY,
    titulo         NVARCHAR(150) NOT NULL,
    id_categoria   INT NOT NULL,
    valor_locacao  DECIMAL(8,2) NOT NULL CHECK (valor_locacao >= 0),
    qtd_estoque    INT NOT NULL DEFAULT 1 CHECK (qtd_estoque >= 0),
    tipo_item      NVARCHAR(10) NOT NULL
                     CONSTRAINT CK_ITEM_TIPO CHECK (tipo_item IN ('filme', 'livro')),
    CONSTRAINT FK_ITEM_CATEGORIA FOREIGN KEY (id_categoria)
        REFERENCES CATEGORIA(id_categoria)
);

-- =====================================================================
-- 6. FILME — especialização de ITEM (relação 1:1)
-- =====================================================================
CREATE TABLE FILME (
    id_item         INT PRIMARY KEY,
    diretor         NVARCHAR(120) NOT NULL,
    duracao_min     INT NOT NULL CHECK (duracao_min > 0),
    classificacao   NVARCHAR(10) NULL, -- ex: 'Livre', '12', '16', '18'
    CONSTRAINT FK_FILME_ITEM FOREIGN KEY (id_item)
        REFERENCES ITEM(id_item) ON DELETE CASCADE
);

-- =====================================================================
-- 7. LIVRO — especialização de ITEM (relação 1:1)
-- =====================================================================
CREATE TABLE LIVRO (
    id_item       INT PRIMARY KEY,
    autor         NVARCHAR(120) NOT NULL,
    isbn          CHAR(13) NULL UNIQUE,
    num_paginas   INT NOT NULL CHECK (num_paginas > 0),
    CONSTRAINT FK_LIVRO_ITEM FOREIGN KEY (id_item)
        REFERENCES ITEM(id_item) ON DELETE CASCADE
);

-- =====================================================================
-- 8. LOCACAO — cabeçalho de uma transação de locação
--    Um cliente pode alugar vários itens em uma única locação.
-- =====================================================================
CREATE TABLE LOCACAO (
    id_locacao                INT IDENTITY(1,1) PRIMARY KEY,
    id_cliente                INT NOT NULL,
    id_funcionario             INT NOT NULL,
    data_locacao               DATE NOT NULL DEFAULT CAST(SYSUTCDATETIME() AS DATE),
    data_prevista_devolucao    DATE NOT NULL,
    data_devolucao             DATE NULL,
    status                     NVARCHAR(20) NOT NULL DEFAULT 'em_andamento'
                                 CONSTRAINT CK_LOCACAO_STATUS CHECK (status IN ('em_andamento', 'finalizada', 'atrasada', 'cancelada')),
    CONSTRAINT FK_LOCACAO_CLIENTE FOREIGN KEY (id_cliente)
        REFERENCES CLIENTE(id_pessoa),
    CONSTRAINT FK_LOCACAO_FUNCIONARIO FOREIGN KEY (id_funcionario)
        REFERENCES FUNCIONARIO(id_pessoa),
    CONSTRAINT CK_LOCACAO_DATAS CHECK (data_prevista_devolucao >= data_locacao)
);

-- =====================================================================
-- 9. LOCACAO_ITEM — tabela associativa (N:N) entre LOCACAO e ITEM
--    Cada linha representa um item específico dentro de uma locação.
-- =====================================================================
CREATE TABLE LOCACAO_ITEM (
    id_locacao            INT NOT NULL,
    id_item               INT NOT NULL,
    valor_cobrado         DECIMAL(8,2) NOT NULL CHECK (valor_cobrado >= 0),
    condicao_devolucao    NVARCHAR(100) NULL,
    CONSTRAINT PK_LOCACAO_ITEM PRIMARY KEY (id_locacao, id_item),
    CONSTRAINT FK_LOCACAOITEM_LOCACAO FOREIGN KEY (id_locacao)
        REFERENCES LOCACAO(id_locacao) ON DELETE CASCADE,
    CONSTRAINT FK_LOCACAOITEM_ITEM FOREIGN KEY (id_item)
        REFERENCES ITEM(id_item)
);

-- =====================================================================
-- Índices adicionais para otimizar consultas comuns
-- =====================================================================
CREATE INDEX IX_ITEM_TITULO ON ITEM(titulo);
CREATE INDEX IX_LOCACAO_STATUS ON LOCACAO(status);
CREATE INDEX IX_LOCACAO_DATA ON LOCACAO(data_locacao);
CREATE INDEX IX_PESSOA_CPF ON PESSOA(cpf);
