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
	filename = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\firma_medyczna.mdf',
	size = 100MB,
	maxsize = 200MB,
	filegrowth = 10%

)
LOG ON
(
	name = firma_medyczna_log,
	filename = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\firma_medyczna_log.ldf',
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
	id	int	NOT NULL CONSTRAINT PK_przychodnia PRIMARY KEY, -- identity(1,2) id nieparzyste
	nazwa	varchar(30) NOT NULL, -- text 2^30 – 1 bajtow lub varchar 1 – 8000 bajtów
	miasto	varchar(30) NOT NULL,
	ulica	varchar(30) NOT NULL
)
GO

INSERT INTO przychodnia (id, nazwa, miasto, ulica)	VALUES('1', 'Arnika', 'Nysa', 'Bagienna 14')
INSERT INTO przychodnia (id, nazwa, miasto, ulica)	VALUES('3', 'MONAR', 'Nysa', 'Kwasniewskiego 40')
INSERT INTO przychodnia (id, nazwa, miasto, ulica)	VALUES('5', 'Pediatryczna', 'Nysa', 'Mila 2c')

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
	tytul	varchar(30),
	specjalizacja	varchar(30),
)
GO

INSERT INTO lekarz VALUES ('1','Beata','Bebolska','Profesor','Proktolog')
INSERT INTO lekarz VALUES ('2','Bartosz','Bebolski','Doktor','Kardiolog')
INSERT INTO lekarz VALUES ('3','Marcin','Wyborski','Fizjoterapelta','')
INSERT INTO lekarz VALUES ('4','Wojtek','Malinowski','Doktor','Neurolog')
INSERT INTO lekarz VALUES ('5','Malwina','Witkowska','Doktor','Urolog')


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

INSERT INTO pacjent VALUES ('1', 'Jan','Nowak', '1658752155')
INSERT INTO pacjent VALUES ('3', 'Michal','Jablonek', '59268845889')
INSERT INTO pacjent VALUES ('5', 'Krystian','Karczynski', '26889955899')
INSERT INTO pacjent VALUES ('7', 'Piotr','Mchalowski', '29856963899')
INSERT INTO pacjent VALUES ('9', 'Tomek','Kruszfil', '69259869985')
INSERT INTO pacjent VALUES ('11', 'Radek','Banasik', '63989599985')

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
	id	int	NOT NULL CONSTRAINT PK_wizyta PRIMARY KEY,
	data date NOT NULL,
	godzina time(0) NOT NULL, 
	opis text
)
GO

INSERT INTO wizyta VALUES ('1', '2018-11-13','9:00','')
INSERT INTO wizyta VALUES ('2', '2018-11-13','11:00','')
INSERT INTO wizyta VALUES ('3', '2018-11-13','13:30','')
INSERT INTO wizyta VALUES ('4', '2018-11-14','10:20','')
INSERT INTO wizyta VALUES ('5', '2018-11-14','12:30','')
INSERT INTO wizyta VALUES ('6', '2018-12-16','13:00','')
INSERT INTO wizyta VALUES ('7', '2018-12-16','13:30','')
INSERT INTO wizyta VALUES ('8', '2018-12-17','10:00','')
INSERT INTO wizyta VALUES ('9', '2018-12-17','12:30','')
INSERT INTO wizyta VALUES ('10', '2018-12-17','14:15','')
INSERT INTO wizyta VALUES ('11', '2018-12-18','8:00','')
INSERT INTO wizyta VALUES ('12', '2019-1-1','9:30','')
INSERT INTO wizyta VALUES ('13', '2019-1-1','10:00','')

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
	wyniki text, 
	typ	varchar(30)
)
GO

INSERT INTO badanie VALUES ('1', 'negatywny','HIV')
INSERT INTO badanie VALUES ('2', 'Prawidlowe','USG')
INSERT INTO badanie VALUES ('3', 'zmiany przerzutowe w watrobie','Tomografia komputerowa')
INSERT INTO badanie VALUES ('4', 'Zmian nie wykryto','Rezonans magnetyczny')
INSERT INTO badanie VALUES ('5', 'Erytrocyty w moczu','Badanie ogolne moczu')
INSERT INTO badanie VALUES ('6', 'Maloplytkowosc','Morfologia')
INSERT INTO badanie VALUES ('7', 'Polipy','Endoskopia')
INSERT INTO badanie VALUES ('8', 'Zmiany o charakterze wrzodziejacym','Gastroskopia')
INSERT INTO badanie VALUES ('9', 'kwasica metaboliczna','Gazometria')
INSERT INTO badanie VALUES ('10', 'czestoskurcz nadkomorowy','EKG')
INSERT INTO badanie VALUES ('11', 'tezyczka','EMG')
INSERT INTO badanie VALUES ('12', 'guz','Kolonoskopia')
INSERT INTO badanie VALUES ('13', 'podwyzszony','Poziom TSH')
INSERT INTO badanie VALUES ('14', 'w normie','Glikemia')