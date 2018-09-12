# ar_trx_retry_issue
A project to demonstrate an issue that appears when retrying transaction that failed due serialization error 

### Project setup

 - Rails version is 5.2.1
 - Ruby version is 2.5.1
 - Clone project 
 - Run `bundle` command 
 - `cp config/database.yml.sample config/database.yml`
 - Change database.yml to match your pg setup. 
 - `rake db:create && rake db:migrate`
 - your `postgresql.conf` should have `default_transaction_isolation = 'serializable'`
 
A version of postgresql used for tests is 10. OS is Ubuntu 18.04.
 

### Issue description

To reproduce an issue, an executable file is created `bin/ar_test`. Just run `./bin/ar_test` from bash console.
You will see next output:

```sql
WARNING:  there is no transaction in progress
BEGIN
SELECT  1 AS one FROM "serialization_tests" WHERE "serialization_tests"."value" = 1 LIMIT 1
INSERT INTO "serialization_tests" ("value") VALUES (1) RETURNING "id"
COMMIT
ROLLBACK
BEGIN
SELECT  1 AS one FROM "serialization_tests" WHERE "serialization_tests"."value" = 1 LIMIT 1
INSERT INTO "serialization_tests" ("value") VALUES (1) RETURNING "id"
COMMIT
```


Take a look at first transaction that was rolled back:

```sql
BEGIN
...
COMMIT
ROLLBACK
```

Do you see that redundant `COMMIT` statement? And, as a result, a warning from pg gem - 
`WARNING:  there is no transaction in progress`

That is it. By quickly inspecting the code, I concluded that it comes from the ActiveRecord(not from pg gem). It is 
there a statements are prepared and finally executed with `ActiveRecord::ConnectionAdapters::PostgreSQLAdapter#exec_query`.
 