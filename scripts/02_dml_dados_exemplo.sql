-- =====================================================================
-- Locadora de Filmes e Livros — Dados de exemplo (DML)
-- Compatível com Azure SQL Database / SQL Server (T-SQL)
-- Execute após o script 01_ddl_criacao_tabelas.sql
-- =====================================================================

-- =====================================================================
-- PESSOA (base para clientes e funcionários)
-- =====================================================================
INSERT INTO PESSOA (nome, cpf, telefone, endereco) VALUES
('Ana Beatriz Souza',     '11122233344', '(11) 91234-5678', 'Rua das Flores, 123 - São Paulo, SP'),
('Carlos Eduardo Lima',   '22233344455', '(11) 92345-6789', 'Av. Paulista, 1000 - São Paulo, SP'),
('Fernanda Costa Ribeiro','33344455566', '(21) 93456-7890', 'Rua Copacabana, 45 - Rio de Janeiro, RJ'),
('Marcos Vinicius Alves', '44455566677', '(31) 94567-8901', 'Av. Afonso Pena, 500 - Belo Horizonte, MG'),
-- Funcionários
('Juliana Pereira Mota',  '55566677788', '(11) 95678-9012', 'Rua Augusta, 200 - São Paulo, SP'),
('Roberto Carlos Nunes',  '66677788899', '(11) 96789-0123', 'Rua da Consolação, 80 - São Paulo, SP');

-- =====================================================================
-- CLIENTE (referencia os 4 primeiros registros de PESSOA)
-- =====================================================================
INSERT INTO CLIENTE (id_pessoa, status) VALUES
(1, 'ativo'),
(2, 'ativo'),
(3, 'ativo'),
(4, 'bloqueado');

-- =====================================================================
-- FUNCIONARIO (referencia os 2 últimos registros de PESSOA)
-- =====================================================================
INSERT INTO FUNCIONARIO (id_pessoa, cargo, salario) VALUES
(5, 'Atendente', 2200.00),
(6, 'Gerente de Loja', 4500.00);

-- =====================================================================
-- CATEGORIA
-- =====================================================================
INSERT INTO CATEGORIA (nome, tipo) VALUES
('Ficção Científica', 'ambos'),
('Drama',              'ambos'),
('Romance',            'ambos'),
('Ação',               'filme'),
('Biografia',          'livro'),
('Terror',             'ambos');

-- =====================================================================
-- ITEM (tabela base — registra dados comuns antes da especialização)
-- =====================================================================
INSERT INTO ITEM (titulo, id_categoria, valor_locacao, qtd_estoque, tipo_item) VALUES
('Interestelar',                 1, 9.90,  3, 'filme'),
('Clube da Luta',                2, 8.50,  2, 'filme'),
('Orgulho e Preconceito',        3, 7.00,  4, 'filme'),
('Duna',                         1, 12.50, 3, 'livro'),
('1984',                         2, 6.90,  5, 'livro'),
('A Culpa é das Estrelas',       3, 7.50,  2, 'livro');

-- =====================================================================
-- FILME (especialização — id_item 1, 2 e 3 são filmes)
-- =====================================================================
INSERT INTO FILME (id_item, diretor, duracao_min, classificacao) VALUES
(1, 'Christopher Nolan', 169, '12'),
(2, 'David Fincher',     139, '16'),
(3, 'Joe Wright',        129, 'Livre');

-- =====================================================================
-- LIVRO (especialização — id_item 4, 5 e 6 são livros)
-- =====================================================================
INSERT INTO LIVRO (id_item, autor, isbn, num_paginas) VALUES
(4, 'Frank Herbert',     '9788576572106', 688),
(5, 'George Orwell',     '9788535914849', 416),
(6, 'John Green',        '9788580573935', 288);

-- =====================================================================
-- LOCACAO (cabeçalhos de transações de locação)
-- =====================================================================
INSERT INTO LOCACAO (id_cliente, id_funcionario, data_locacao, data_prevista_devolucao, data_devolucao, status) VALUES
(1, 5, '2026-06-10', '2026-06-17', '2026-06-16', 'finalizada'),
(2, 5, '2026-06-15', '2026-06-22', NULL,          'em_andamento'),
(3, 6, '2026-06-01', '2026-06-08', NULL,          'atrasada');

-- =====================================================================
-- LOCACAO_ITEM (itens específicos dentro de cada locação)
-- =====================================================================
INSERT INTO LOCACAO_ITEM (id_locacao, id_item, valor_cobrado, condicao_devolucao) VALUES
(1, 1, 9.90, 'Bom estado'),
(1, 4, 12.50, 'Bom estado'),
(2, 2, 8.50,  NULL),
(2, 5, 6.90,  NULL),
(3, 3, 7.00,  NULL);
