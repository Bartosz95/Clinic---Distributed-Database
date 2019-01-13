IF EXISTS ( SELECT * 
				FROM master..sysdatabases 
				WHERE name = N'firma_medyczna'
		)
	BEGIN
		DROP DATABASE firma_medyczna
	END
GO
	
	-- Tworzenie bazy danych	
CREATE DATABASE firma_medyczna ON PRIMARY
(
	name = firma_medyczna,
	filename = N'/var/opt/mssql/data/firma_medyczna.mdf',
	size = 100MB,
	maxsize = 200MB,
	filegrowth = 10%

)
LOG ON
(
	name = firma_medyczna_log,
	filename = N'/var/opt/mssql/data/firma_medyczna_log.ldf',
	size = 30MB,
	maxsize = 50MB,
	filegrowth = 10%
)
GO

	-- usuwanie tabel 
	USE firma_medyczna
	GO

IF EXISTS( SELECT name 
				FROM sysobjects
				WHERE name = 'pr_usun_tabele'
					AND OBJECTPROPERTY(id, N'IsProcedure') = 1
	)
	BEGIN
		DROP PROCEDURE pr_usun_tabele
	END
GO

 -- procedura usuwania tabel
CREATE PROCEDURE [dbo].pr_usun_tabele
	( @tabela nvarchar(100) )
AS
	DECLARE @stmt nvarchar(1000)

	IF EXISTS
	(
		SELECT 1 
		FROM sysobjects o 
		WHERE (o.[name] = @tabela)
			AND (OBJECTPROPERTY(o.[ID],'IsUserTable') = 1)
	)
	BEGIN
		SET @stmt = 'DROP TABLE ' + @tabela
		EXECUTE sp_executeSQL @stmt = @stmt
	END
GO

EXEC pr_usun_tabele @tabela='przychodnia'
EXEC pr_usun_tabele @tabela='lekarz'
EXEC pr_usun_tabele @tabela='pacjent'
EXEC pr_usun_tabele @tabela='badanie'
EXEC pr_usun_tabele @tabela='wizyta'

 -- Tworzenie tabel

 -- przychodnia
 IF EXISTS(SELECT *
			FROM sysobjects O
			WHERE O.[name] = 'przychodnia'
				AND (OBJECTPROPERTY(O.[ID], ' IsUserTable') = 1)
		)
	BEGIN
		DROP TABLE przychodnia
	END
GO

CREATE TABLE przychodnia
(
	id	int	NOT NULL CONSTRAINT PK_przychodnia PRIMARY KEY, --identity(2,2) id parzyste
	nazwa	varchar(30) UNIQUE NOT NULL, -- text 2^30 – 1 bajtow lub varchar 1 – 8000 bajtów
	miasto	varchar(30) NOT NULL,
	ulica	varchar(30) UNIQUE NOT NULL
)
GO
/*--wykluczenie duplikowania rekordow
ALTER TABLE dbo.przychodnia 
ADD CONSTRAINT UQ_ADDRESS UNIQUE(nazwa, ulica)*/

INSERT INTO przychodnia (id, nazwa, miasto, ulica)	VALUES('2', 'BioDent', 'Wroclaw', 'Karmelkowa 1')
INSERT INTO przychodnia (id, nazwa, miasto, ulica)	VALUES('4', 'Arnika', 'Wroclaw', 'Kwiatowa 6a')
INSERT INTO przychodnia (id, nazwa, miasto, ulica)	VALUES('6', 'PROelmed', 'Wroclaw', 'Ciastkowa 11')


-- lekarz
 IF EXISTS(SELECT *
			FROM sysobjects O
			WHERE O.[name] = 'lekarz'
				AND (OBJECTPROPERTY(O.[ID], ' IsUserTable') = 1)
		)
	BEGIN
		DROP TABLE lekarz
	END
GO

CREATE TABLE lekarz
(
	id	int	NOT NULL CONSTRAINT PK_lekarz PRIMARY KEY, --identity(1,1)
	imie	varchar(30) NOT NULL,
	nazwisko	varchar(30) NOT NULL,
	wyplata	int,
	id_przychodnia int not null,
)
GO
/*
ALTER TABLE dbo.lekarz --powiazanie przychodni z lekarzem
ADD CONSTRAINT FK_lekarz FOREIGN KEY(id_przychodnia)
REFERENCES dbo.przychodnia(id)
ON DELETE NO ACTION
ON UPDATE CASCADE;

*/


INSERT INTO lekarz VALUES ('1', 'Beata','Bebolska','3000', '1')
INSERT INTO lekarz VALUES ('2', 'Bartosz','Bebolski','2500', '2')
INSERT INTO lekarz VALUES ('3', 'Marcin','Wyborski','3000', '3')
INSERT INTO lekarz VALUES ('4', 'Wojtek','Malinowski','4000', '4')
INSERT INTO lekarz VALUES ('5', 'Malwina','Witkowska','4500', '5')

-- Pacjent
 IF EXISTS(SELECT *
			FROM sysobjects O
			WHERE O.[name] = 'pacjent'
				AND (OBJECTPROPERTY(O.[ID], ' IsUserTable') = 1)
		)
	BEGIN
		DROP TABLE pacjent
	END
GO

CREATE TABLE pacjent
(
	id	int	NOT NULL	CONSTRAINT PK_pacjent PRIMARY KEY,
	imie	varchar(30) NOT NULL, 
	nazwisko	varchar(30) NOT NULL,
	pesel	bigint
)
GO

INSERT INTO pacjent VALUES ('2', 'Anna','Kowalska', '21645265566')
INSERT INTO pacjent VALUES ('4', 'Wojtek','Jelonkiewicz', '69898966688')
INSERT INTO pacjent VALUES ('6', 'Aneta','Adamczuk', '59985998526')
INSERT INTO pacjent VALUES ('8', 'Ada','Wisniewska', '99596998666')
INSERT INTO pacjent VALUES ('10', 'Roman','Bezo', '26852969698')

-- Wizyta
 IF EXISTS(SELECT *
			FROM sysobjects O
			WHERE O.[name] = 'wizyta'
				AND (OBJECTPROPERTY(O.[ID], ' IsUserTable') = 1)
		)
	BEGIN
		DROP TABLE wizyta
	END
GO

CREATE TABLE wizyta
(
	id	int	NOT NULL	CONSTRAINT PK_wizyta PRIMARY KEY,
	id_pacjent int NOT NULL,
	id_lekarz	int NOT NULL
)
GO

INSERT INTO wizyta VALUES ('1', '2', '1')
INSERT INTO wizyta VALUES ('2', '10', '5')
INSERT INTO wizyta VALUES ('3', '7', '3')
INSERT INTO wizyta VALUES ('4', '4', '2')
INSERT INTO wizyta VALUES ('5', '8', '1')
INSERT INTO wizyta VALUES ('6', '2', '3')
INSERT INTO wizyta VALUES ('7', '4', '4')
INSERT INTO wizyta VALUES ('8', '6', '3')
INSERT INTO wizyta VALUES ('9', '2', '3')
INSERT INTO wizyta VALUES ('10', '1', '5')
INSERT INTO wizyta VALUES ('11', '3', '6')
INSERT INTO wizyta VALUES ('12', '7', '2')
INSERT INTO wizyta VALUES ('13', '8', '4')

-- Badanie
 IF EXISTS(SELECT *
			FROM sysobjects O
			WHERE O.[name] = 'badanie'
				AND (OBJECTPROPERTY(O.[ID], ' IsUserTable') = 1)
		)
	BEGIN
		DROP TABLE badanie
	END
GO

CREATE TABLE badanie
(
	id	int	NOT NULL	CONSTRAINT PK_badanie PRIMARY KEY,
	id_pacjent	int
)
GO

INSERT INTO badanie VALUES ('1', '3')
INSERT INTO badanie VALUES ('2', '2')
INSERT INTO badanie VALUES ('3', '1')
INSERT INTO badanie VALUES ('4', '4')
INSERT INTO badanie VALUES ('5', '2')
INSERT INTO badanie VALUES ('6', '4')
INSERT INTO badanie VALUES ('7', '5')
INSERT INTO badanie VALUES ('8', '5')
INSERT INTO badanie VALUES ('9', '12')
INSERT INTO badanie VALUES ('10', '6')
INSERT INTO badanie VALUES ('11', '11')
INSERT INTO badanie VALUES ('12', '4')
INSERT INTO badanie VALUES ('13', '7')
INSERT INTO badanie VALUES ('14', '1')