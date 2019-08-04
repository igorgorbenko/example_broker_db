# example_broker_db

1. Запустить скрипт по созданию схем и таблиц БД:
    /sql/schema/schema.sql
    
2. Запустить скрипт для генерации тестовых данных:
    /sql/dummy_data/test_data.sql

3. Запросы для тестовых выборок:
    - /sql/queries/query_1.sql - среднее время перехода пользователей между этапами воронки
    - /sql/queries/query_2.sql - клиенты по странам, у которых средний депозит >=1000
    - /sql/queries/query_3.sql - первые 3 депозита каждого клиента