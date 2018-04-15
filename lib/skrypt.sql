CREATE TABLE chatuser(
   id       SERIAL    PRIMARY KEY NOT NULL,
   serverID VARCHAR,
   login    VARCHAR   NOT NULL,
   password VARCHAR   NOT NULL
);

CREATE TABLE chatmessages(
	id        SERIAL    PRIMARY KEY NOT NULL,
	sender    VARCHAR   NOT NULL,
	receiver  VARCHAR   NOT NULL,
	date      TIMESTAMP,
	text      TEXT
);

CREATE TABLE chatcontacts(
	id        SERIAL    PRIMARY KEY NOT NULL,
	name      VARCHAR   NOT NULL,
	serverID  VARCHAR   NOT NULL,
  key       VARCHAR
);

CREATE TABLE convKeys(
  id                SERIAL    PRIMARY KEY NOT NULL,
  conversation_id   INT       NOT NULL,
  key_one           VARCHAR   NOT NULL,
  key_two           VARCHAR   NOT NULL
);

CREATE TABLE conversations(
	id     SERIAL    PRIMARY KEY NOT NULL,
	user1  VARCHAR   NOT NULL,
	user2  VARCHAR   NOT NULL
);
