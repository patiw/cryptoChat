createuser cryptochat
createdb -O cryptochat cryptochat
psql -U cryptochat -d cryptochat -a -f skrypt.sql
