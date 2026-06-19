set -ex

./run_sql.sh ../src/model/db/schema.sql
./run_sql.sh init_settings.sql
./run_sql.sh add_mock_cancilleria.sql
