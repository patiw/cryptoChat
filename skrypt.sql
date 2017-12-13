CREATE TABLE chatUser(
   id SERIAL PRIMARY KEY      NOT NULL,
   serverID VARCHAR,
   login           VARCHAR NOT NULL,
   password         VARCHAR      NOT NULL
);

CREATE TABLE chatMessages(
	id SERIAL PRIMARY KEY NOT NULL,
	sender INT NOT NULL,
	receiver INT NOT NULL,
	date TIMESTAMP,
	text BYTEA
	);

CREATE TABLE chatContacts(
	id SERIAL PRIMARY KEY NOT NULL,
	name VARCHAR NOT NULL,
	serverID VARCHAR NOT NULL
	);

INSERT INTO chatUser(serverID, login, password) VALUES ('aaaaa', 'aaaa', 'aaaaa');
INSERT INTO chatMessages(sender,receiver,date,text) VALUES (1,1,'2017-11-11T10:10:10', 'abab');
INSERT INTO chatContacts(name, serverID) VALUES ('Janek', 'cokolwiek');