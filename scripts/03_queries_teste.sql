-- =====================================================================
-- Locadora de Filmes e Livros — Consultas de teste e validação
-- Compatível com Azure SQL Database / SQL Server (T-SQL)
-- Execute após os scripts 01 (DDL) e 02 (dados de exemplo)
-- =====================================================================

-- 1. Listar todos os clientes com seus dados pessoais
SELECT
    p.id_pessoa,
    p.nome,
    p.cpf,
    p.telefone,
    c.status,
    c.data_cadastro
FROM CLIENTE c
JOIN PESSOA p ON p.id_pessoa = c.id_pessoa;

-- 2. Listar todo o acervo (filmes e livros) com categoria
SELECT
    i.id_item,
    i.titulo,
    cat.nome AS categoria,
    i.tipo_item,
    i.valor_locacao,
    i.qtd_estoque
FROM ITEM i
JOIN CATEGORIA cat ON cat.id_categoria = i.id_categoria
ORDER BY i.tipo_item, i.titulo;

-- 3. Detalhes completos de todos os filmes do acervo
SELECT
    i.titulo,
    f.diretor,
    f.duracao_min,
    f.classificacao,
    cat.nome AS categoria,
    i.valor_locacao,
    i.qtd_estoque
FROM FILME f
JOIN ITEM i ON i.id_item = f.id_item
JOIN CATEGORIA cat ON cat.id_categoria = i.id_categoria;

-- 4. Detalhes completos de todos os livros do acervo
SELECT
    i.titulo,
    l.autor,
    l.isbn,
    l.num_paginas,
    cat.nome AS categoria,
    i.valor_locacao,
    i.qtd_estoque
FROM LIVRO l
JOIN ITEM i ON i.id_item = l.id_item
JOIN CATEGORIA cat ON cat.id_categoria = i.id_categoria;

-- 5. Locações em andamento ou atrasadas, com nome do cliente e funcionário
SELECT
    loc.id_locacao,
    pc.nome AS cliente,
    pf.nome AS funcionario,
    loc.data_locacao,
    loc.data_prevista_devolucao,
    loc.status
FROM LOCACAO loc
JOIN CLIENTE c ON c.id_pessoa = loc.id_cliente
JOIN PESSOA pc ON pc.id_pessoa = c.id_pessoa
JOIN FUNCIONARIO f ON f.id_pessoa = loc.id_funcionario
JOIN PESSOA pf ON pf.id_pessoa = f.id_pessoa
WHERE loc.status IN ('em_andamento', 'atrasada')
ORDER BY loc.data_prevista_devolucao;

-- 6. Itens alugados em cada locação, com valor total cobrado por locação
SELECT
    loc.id_locacao,
    pc.nome AS cliente,
    i.titulo,
    li.valor_cobrado,
    SUM(li.valor_cobrado) OVER (PARTITION BY loc.id_locacao) AS total_locacao
FROM LOCACAO_ITEM li
JOIN LOCACAO loc ON loc.id_locacao = li.id_locacao
JOIN ITEM i ON i.id_item = li.id_item
JOIN CLIENTE c ON c.id_pessoa = loc.id_cliente
JOIN PESSOA pc ON pc.id_pessoa = c.id_pessoa
ORDER BY loc.id_locacao;

-- 7. Locações atrasadas (data prevista já passou e não foi devolvido)
SELECT
    loc.id_locacao,
    pc.nome AS cliente,
    loc.data_prevista_devolucao,
    DATEDIFF(DAY, loc.data_prevista_devolucao, CAST(SYSUTCDATETIME() AS DATE)) AS dias_atraso
FROM LOCACAO loc
JOIN CLIENTE c ON c.id_pessoa = loc.id_cliente
JOIN PESSOA pc ON pc.id_pessoa = c.id_pessoa
WHERE loc.data_devolucao IS NULL
  AND loc.data_prevista_devolucao < CAST(SYSUTCDATETIME() AS DATE);

-- 8. Ranking de itens mais alugados (quantidade de locações por item)
SELECT
    i.titulo,
    i.tipo_item,
    COUNT(li.id_locacao) AS qtd_locacoes
FROM ITEM i
LEFT JOIN LOCACAO_ITEM li ON li.id_item = i.id_item
GROUP BY i.titulo, i.tipo_item
ORDER BY qtd_locacoes DESC;

-- 9. Faturamento total por funcionário (soma de valores cobrados nas locações que ele registrou)
SELECT
    pf.nome AS funcionario,
    COUNT(DISTINCT loc.id_locacao) AS qtd_locacoes_atendidas,
    SUM(li.valor_cobrado) AS faturamento_total
FROM FUNCIONARIO f
JOIN PESSOA pf ON pf.id_pessoa = f.id_pessoa
JOIN LOCACAO loc ON loc.id_funcionario = f.id_pessoa
JOIN LOCACAO_ITEM li ON li.id_locacao = loc.id_locacao
GROUP BY pf.nome
ORDER BY faturamento_total DESC;

-- 10. Itens disponíveis em estoque (qtd_estoque > 0), ordenados por categoria
SELECT
    cat.nome AS categoria,
    i.titulo,
    i.tipo_item,
    i.qtd_estoque
FROM ITEM i
JOIN CATEGORIA cat ON cat.id_categoria = i.id_categoria
WHERE i.qtd_estoque > 0
ORDER BY cat.nome, i.titulo;
