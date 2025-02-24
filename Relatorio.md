# Relatório do Banco de Dados Olist

### Conexão e Execução de Comandos

O banco de dados foi acessado e manipulado utilizando o MySQL Workbench, onde todas as operações foram realizadas por meio de comandos SQL.

### Restauração do Banco de Dados

Para restaurar o banco de dados, foi necessário executar os comandos abaixo, seguidos pela execução do arquivo SQL fornecido:
``` sql
CREATE DATABASE olist;
USE olist;
```
Em seguida, o script `olist.sql` foi rodado para a reconstituição das tabelas e dados.

### Criação de Usuário para Business Intelligence

Foi criado um novo usuário com permissões restritas para a equipe de Business Intelligence utilizando os comandos:
- `CREATE USER` 
- `GRANT SELECT ON` 
- `REVOKE INSERT, UPDATE, DELETE` 
- `REVOKE CREATE, ALTER, DROP` 
- `FLUSH PRIVILEGES`

### Otimização de Consultas

#### Reescrita das Consultas
Algumas consultas foram reescritas para eliminar junções (JOINs) desnecessárias. Isso contribuiu para reduzir o número de registros processados, acelerando a execução das consultas.

#### Cosultas
Abaixo estão os detalhes das melhorias nas consultas:

- 4.1 **Total de Vendas por Vendedor**
- 4.2 **Top 10 Clientes que Mais Compraram por Período**
- 4.3 **Média das Avaliações por Vendedor**
- 4.4 **Pedidos Entre Duas Datas**
- 4.5 **Produtos Mais Vendidos no Período (Top 5)**
- 4.6 **Pedidos com Mais Atrasos por Período (Top 10)**
- 4.7 **Clientes com Maior Valor em Compras (Top 10)**
- 4.8 **Tempo Médio de Entrega por Estado**

### Auditoria do Banco de Dados

Para garantir a auditoria, rastreabilidade e integridade das informações no banco de dados, foi criada uma tabela de auditoria, onde todas as alterações feitas nas tabelas são registradas automaticamente por meio de triggers.

- A tabela `order_audit` foi criada para registrar as modificações nos pedidos.
- A trigger `trigger_audit_order` captura mudanças no status dos pedidos.
- A trigger `trigger_audit_orders_delete` registra a exclusão de pedidos, armazenando o status anterior.

### Criação de Chaves e Restrições

#### Eliminação de Registros Duplicados
Durante a análise das tabelas, foi observado que algumas contavam com registros duplicados. Para resolver esse problema, foi criada uma coluna temporária `id` do tipo SERIAL, a qual foi utilizada para identificar as duplicatas.

#### Definição das Chaves Primárias
Após a remoção das duplicatas, as seguintes chaves primárias foram configuradas:
- `customer`: `pk_customer` na coluna `customer_id`.
- `geo_location`: `pk_geo_location` nas colunas `geolocation_zip_code_prefix`, `geolocation_city`, e `geolocation_state`.
- `seller`: `pk_seller` na coluna `seller_id`.
- `product`: `pk_product` na coluna `product_id`.
- `olist.order`: `pk_order` na coluna `order_id`.
- `order_item`: `pk_order_item` nas colunas `order_id` e `product_id`.
- `order_review`: `pk_order_review` nas colunas `review_id` e `order_id`.

#### Criação de Chaves Estrangeiras
As chaves estrangeiras foram criadas para assegurar a integridade referencial entre as tabelas:
- `customer`: `fk_customer_geo_location`, referenciando a tabela `geo_location` nas colunas `customer_zip_code_prefix`, `customer_city`, e `customer_state`.
- `seller`: `fk_seller_geo_location`, referenciando a tabela `geo_location` nas colunas `seller_zip_code_prefix`, `seller_city`, e `seller_state`.
- `order_item`: `fk_order_item_seller`, referenciando a tabela `seller` na coluna `seller_id`.
- `olist.order`: `fk_order_customer`, referenciando a tabela `customer` na coluna `customer_id`.
- `order_item`: `fk_order_item_order`, referenciando a tabela `olist.order` na coluna `order_id`.
- `order_item`: `fk_order_item_product`, referenciando a tabela `product` na coluna `product_id`.
- `order_payment`: `fk_order_payment_order`, referenciando a tabela `olist.order` na coluna `order_id`.
- `order_review`: `fk_order_review_order`, referenciando a tabela `olist.order` na coluna `order_id`.

#### Inserção de Dados Faltantes
Para garantir a integridade referencial, foram criadas duas views: `vw_customer_without_geo_location` e `vw_seller_without_geo_location`, com o objetivo de identificar registros de `customer` e `seller` sem correspondência na tabela `geo_location`. Após a identificação, esses dados foram inseridos corretamente na tabela `geo_location`.

#### Remoção das Colunas Temporárias
Após a eliminação das duplicatas e a criação das chaves, a coluna temporária `id` foi removida de todas as tabelas.

#### Validação de Backups

É crucial realizar testes regulares nos backups para garantir que não estejam corrompidos. Além disso, a automação da remoção de backups antigos, mantendo apenas os mais recentes (por exemplo, dos últimos 7 dias), ajuda a otimizar o uso do espaço de armazenamento.

#### Monitoramento de Backups

O monitoramento contínuo dos backups deve ser feito, com notificações sobre o sucesso ou falha das operações enviadas por e-mail ou outros canais de comunicação.
