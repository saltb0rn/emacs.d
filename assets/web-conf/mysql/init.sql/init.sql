-- # Create users here.

-- CREATE USER IF NOT EXISTS 'saltborn'@'%' IDENTIFIED BY 'saltborn';
-- CREATE USER IF NOT EXISTS 'saltborn'@'localhost' IDENTIFIED BY 'saltborn';

-- # Create databases and tables for databases here

-- CREATE DATABASE IF NOT EXISTS USERDB CHARACTER SET utf8mb4;

-- USE USERDB;

-- CREATE TABLE IF NOT EXISTS USER(
--        `USERNAME` VARCHAR(30) NOT NULL,
--        `EMAIL` VARCHAR(100) NOT NULL UNIQUE,
--        `PASSWORD` VARCHAR(100) NOT NULL,
--        PRIMARY KEY (`USERNAME`)) ENGINE=InnoDB;

-- # Grant permissions of manipulating database to new created users.

-- GRANT INDEX, CREATE, SELECT, INSERT, UPDATE, DELETE, ALTER ON USERDB.* TO 'saltborn'@'%';
-- GRANT INDEX, CREATE, SELECT, INSERT, UPDATE, DELETE, ALTER ON USERDB.* TO 'saltborn'@'localhost';

-- FLUSH PRIVILEGES;
