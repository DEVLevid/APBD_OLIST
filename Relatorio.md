# Database Olist 

### A conexão com o banco e todos os comandos foram feitos utilizando o MySQL Workbench.

### Estrutura do banco

![olist_structure](https://github.com/user-attachments/assets/ddb4089f-119e-4c8c-bcf5-e35480f7d11b)


### 1. Restaurar o banco de dados:
O banco de dados foi restaurado utilizando os comandos abaixo e rodando o arquivo fornecido.
``` sql
CREATE DATABASE olist;
USE olist;
```
E rodei o script olist.sql.

### 2. Criar um usuário para o pessoal de Business Intelligence:
Utilizei os comandos: 
- `CREATE USER` -> para criar o usuario
- `GRANT SELECT ON` -> para dar permissão de consulta
- `REVOKE INSERT, UPDATE, DELETE` -> para remover as permissões
- `REVOKE CREATE, ALTER, DROP` -> para remover as permissões
- `FLUSH PRIVILEGES` -> para atualizar as permissões

### 3. Chaves e Restrições:

#### Remoção de duplicatas: 
As tabelas estavam com várias duplicatas, então foi necessário removê-las antes de criar as PK e FK, para cada tabela (customer, geo_location, seller, product, olist.order, order_item, order_review), adicionei uma coluna temporária id do tipo SERIAL para identificar as linhas duplicadas. Em seguida, utilizei consultas com a função ROW_NUMBER() para identificar e remover as duplicatas, mantendo apenas uma ocorrência de cada registro único.

#### Atualização de dados: 
Fiz atualizações nas colunas de cidade e estado para garantir a consistência dos dados, convertendo as cidades para minúsculas e os estados para maiúsculas.

#### Criação das chaves primárias: 
Após a remoção das duplicatas, criei as chaves primárias para cada tabela:
- `customer`: pk_customer na coluna customer_id.
- `geo_location`: pk_geo_location nas colunas geolocation_zip_code_prefix, geolocation_city, e geolocation_state.
- `seller`: pk_seller na coluna seller_id.
- `product`: pk_product na coluna product_id.
- `olist.order`: pk_order na coluna order_id.
- `order_item`: pk_order_item nas colunas order_id e product_id.
- `order_review`: pk_order_review nas colunas review_id e order_id.

#### Criação das chaves estrangeiras: 
Adicionei chaves estrangeiras para garantir a integridade referencial entre as tabelas:
- `customer`: fk_customer_geo_location referenciando geo_location nas colunas customer_zip_code_prefix, customer_city, e customer_state.
- `seller`: fk_seller_geo_location referenciando geo_location nas colunas seller_zip_code_prefix, seller_city, e seller_state.
- `order_item`: fk_order_item_seller referenciando seller na coluna seller_id.
- `olist.order`: fk_order_customer referenciando customer na coluna customer_id.
- `order_item`: fk_order_item_order referenciando olist.order na coluna order_id.
- `order_item`: fk_order_item_product referenciando product na coluna product_id.
- `order_payment`: fk_order_payment_order referenciando olist.order na coluna order_id.
- `order_review`: fk_order_review_order referenciando olist.order na coluna order_id.

#### Inserção de dados faltantes: 
Criei views (vw_customer_without_geo_location e vw_seller_without_geo_location) para identificar registros de customer e seller que não possuíam correspondência em geo_location. Esses registros foram inseridos na tabela geo_location para garantir a integridade referencial.
#### Remoção de colunas temporárias: 
Após a remoção das duplicatas e a criação das chaves, as colunas temporárias `id` foram removidas das tabelas.

### 4. Consultas:
- [Consulta 4.1](https://github.com/viitoriamoreirac/atvd_APBD_olist/blob/main/04_queries.sql#L1)
- [Consulta 4.2](https://github.com/viitoriamoreirac/atvd_APBD_olist/blob/main/04_queries.sql#L10)
- [Consulta 4.3](https://github.com/viitoriamoreirac/atvd_APBD_olist/blob/main/04_queries.sql#L20)
- [Consulta 4.4](https://github.com/viitoriamoreirac/atvd_APBD_olist/blob/main/04_queries.sql#L29)
- [Consulta 4.5](https://github.com/viitoriamoreirac/atvd_APBD_olist/blob/main/04_queries.sql#L37)
- [Consulta 4.6](https://github.com/viitoriamoreirac/atvd_APBD_olist/blob/main/04_queries.sql#L46)
- [Consulta 4.7](https://github.com/viitoriamoreirac/atvd_APBD_olist/blob/main/04_queries.sql#L53)
- [Consulta 4.8](https://github.com/viitoriamoreirac/atvd_APBD_olist/blob/main/04_queries.sql#L62)

### 5. Otimização das consultas

#### Uso de indexes
Foram criados e melhor aproveitados índices em tabelas como order, order_payment e order_item, reduzindo o número de leituras desnecessárias e melhorando a performance das junções.
#### Reescrita das consultas
Algumas consultas foram reescritas para eliminar JOINs que não agregavam informações relevantes, reduzindo o número de linhas processadas e melhorando o tempo de resposta
#### Melhor aproveitamento de filtros
Os filtros de data e outras condições foram ajustados para serem aplicados o mais cedo possível na execução da consulta, reduzindo o número de registros processados nas junções subsequentes.
#### Uso de funções
Funções como TIMESTAMPDIFF() foram utilizadas para cálculos de tempo de entrega e atrasos, otimizando a obtenção dos resultados sem necessidade de cálculos adicionais.

#### Resultados
O resultado de `Explain Analyze` *antes* das melhorias pode ser conferido [aqui](/query_results/01_result_EXPLAIN_ANALYZE_before_changes.txt) <br>
O resultado de `Explain Analyze` *depois* das melhorias pode ser conferido [aqui](/query_results/02_result_EXPLAIN_ANALYZE_after_changes.txt)

- 4.1 Total de vendas por vendedor: O tempo de execução diminuiu de 1922ms para 1461ms, indicando melhora no desempenho, que pode ser explicada pelo remoção de um JOIN desnecessário, aproveitamente melhor os índices acessando order_payment diretamente, diminuindo a quantidade de linhas processadas.

- 4.2 Top 10 clientes que mais compraram por período: O tempo de execução diminuiu de 386ms para 305ms, indicando uma melhora significativa, devido ao filtro de data ter sido alterado, além de melhor tempo no JOIN, sugerindo bom aproveitamento dos índices.

- 4.3 Média das avaliações por vendedor: O tempo de execução diminuiu de 3989ms para 1541ms, devido a diminuição de JOINS e bom aproveitament dos índices, reduzindo leituras desnecessárias.
- 4.4 Pedidos entre duas datas: O tempo caiu de 2740ms para 989ms, indicando melhoria, após remoção de SUM() e GROUP BY, tornando a consulta mais eficiente.
- 4.5 Produtos mais vendidos no período (Top 5): O tempo de execução diminuiu de 939ms para 244ms, devido ao bom aproveitamento do índiceidx_order_data, além de ter sido mais rápida na junção com order_item, o que pode estar relacionado aos filtros aplicados antes da junção.
- 4.6 Pedidos com mais atrasos por período (Top 10): O tempo de execução diminuiu de 538ms para 91.9ms, tendo uma melhora significativa de desempenho, que pode ser explicada pelo uso da função TIMESTAMPDIFF().
- 4.7 Clientes com maior valor em compras (Top 10): O tempo de execução diminuiu de 4695ms para 2190ms, pois a nova consulta evita um join desnecessário, entregando o mesmo resultado porém com melhor desempenho.
- 4.8 Tempo médio de entrega por estado: O tempo de execução caiu de 1419ms para 578ms, tendo uma melhora significativa, que pode ser explicada pela diminuição no tempo de agregação, devido ao uso de TIMESTAMPDIFF().

### 6. Auditoria do BD
Para garantir auditoria, rastreabilidade e integridade das informações é interessante criar uma tabela de auditoria para cada tabela existente no banco, onde serão registradas todas as mudanças efetuadas de forma automática, através de triggers que vão capturar as mudanças.

Como pode ser conferido [nesse exemplo](/06_auditoria_db.sql) onde foi criada a tabela order_audit para registrar mudanças e definidos triggers para capturar atualizações (UPDATE) e exclusões (DELETE).
- `trigger_audit_order`: Registra mudanças no status do pedido quando atualizado.
- `trigger_audit_orders_delete`: Registra pedidos excluídos, armazenando o status antigo.

### Backup

#### Redundância
É importante manter mais de um tipo de backup, completo, incremental, diferencial e replicações, para garantir que caso haja necessidade, exista mais de uma maneira de recuperação, além de permitir que a mais eficiente seja usada para determinada situação. É importante também avaliar a periodicidade de cada um.

#### Segurança
O armazenamento dos backups pode ser feito localmente, na nuvem, ou de forma híbrida, ficando a critério do administrador, avaliando as necessidades atuais.

#### Validação de backups
Realização de testes para verificar se backups não estão corrompidos e automatização de backups antigos, mantendo apenas um certo período, ex.: últimos 7 dias, dessa forma otimizando espaço.

#### Monitoramento de backups
Notificações de sucesso/falha de backup recebida via e-mail ou outro meio de comunicação.