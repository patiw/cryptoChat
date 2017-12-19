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
	text TEXT
	);

CREATE TABLE chatContacts(
	id SERIAL PRIMARY KEY NOT NULL,
	name VARCHAR NOT NULL,
	serverID VARCHAR NOT NULL
	);
