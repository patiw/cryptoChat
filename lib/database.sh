#!/bin/sh
sudo -u postgres createuser $(whoami)
sudo -u postgres psql postgres -c "ALTER USER $(whoami) WITH CREATEDB"
sudo -u $(whoami) createdb cryptochat
psql -U $(whoami) -d cryptochat -a -f skrypt.sql

#change authentication in file pg_hba.conf to trust.
#etc/postgresql/9.5/main/pg_hba.conf
