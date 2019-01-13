USE firma_medyczna
GO

-- usuwanie synonimow
/*
DROP SYNONYM przychodnia1;
DROP SYNONYM przychodnia2;
DROP SYNONYM lekarz1;
DROP SYNONYM lekarz2;
DROP SYNONYM pacjent1;
DROP SYNONYM pacjent2;
DROP SYNONYM badanie1;
DROP SYNONYM badanie2;
DROP SYNONYM wizyta1;
DROP SYNONYM wizyta2;
*/

-- tworzenie synonimow

CREATE SYNONYM przychodnia1 FOR Linked_firma_medyczna_1.firma_medyczna.dbo.przychodnia;
CREATE SYNONYM przychodnia2 FOR Linked_firma_medyczna_2.firma_medyczna.dbo.przychodnia;
CREATE SYNONYM lekarz1		FOR Linked_firma_medyczna_1.firma_medyczna.dbo.lekarz;
CREATE SYNONYM lekarz2		FOR Linked_firma_medyczna_2.firma_medyczna.dbo.lekarz;
CREATE SYNONYM pacjent1		FOR Linked_firma_medyczna_1.firma_medyczna.dbo.pacjent;
CREATE SYNONYM pacjent2		FOR Linked_firma_medyczna_2.firma_medyczna.dbo.pacjent;
CREATE SYNONYM badanie1		FOR Linked_firma_medyczna_1.firma_medyczna.dbo.badanie;
CREATE SYNONYM badanie2		FOR Linked_firma_medyczna_2.firma_medyczna.dbo.badanie;
CREATE SYNONYM wizyta1		FOR Linked_firma_medyczna_1.firma_medyczna.dbo.wizyta;
CREATE SYNONYM wizyta2		FOR Linked_firma_medyczna_2.firma_medyczna.dbo.wizyta;

/*****************
      WIDOKI
******************/
-- Przychodnia (fragmentacja pozioma)
IF EXISTS (SELECT * 
				FROM sys.views
				WHERE object_id = OBJECT_ID(N'przychodnie')
		)
	BEGIN
		DROP VIEW przychodnie
	END
GO

CREATE VIEW przychodnie
AS
	SELECT	p.id		AS N'id',
			p.nazwa		AS N'nazwa',
			p.miasto	AS N'miasto',
			p.ulica		AS N'ulica'
	FROM	przychodnia1 p
	UNION
	SELECT	p.id		AS N'id',
			p.nazwa		AS N'nazwa',
			p.miasto	AS N'miasto',
			p.ulica		AS N'ulica'
	FROM	przychodnia2 p
GO


-- Lekarz (fragmentaryzacja pionowa)
IF EXISTS (SELECT * 
				FROM sys.views
				WHERE object_id = OBJECT_ID(N'lekarze')
		)
	BEGIN
		DROP VIEW lekarze
	END
GO

CREATE VIEW lekarze
AS
	SELECT	l1.id				AS N'id',
			l1.imie				AS N'imie',
			l1.nazwisko			AS N'nazwisko',
			l1.tytul			AS N'tytul',
			l1.specjalizacja	AS N'specjalizacja',
			p.nazwa				AS N'nazwa_przychodni',
		    l2.wyplata			AS N'wyplata'
	FROM	lekarz1 l1
	JOIN	lekarz2 l2 ON (l2.id = l1.id)
	JOIN	przychodnie p ON (p.id = l2.id_przychodnia)
GO

-- Pacjent (fragmentacja pozioma)
IF EXISTS (SELECT * 
				FROM sys.views
				WHERE object_id = OBJECT_ID(N'pacjenci')
		)
	BEGIN
		DROP VIEW pacjenci
	END
GO


CREATE VIEW pacjenci
AS
	SELECT	p.id			AS N'id',
			p.imie			AS N'imie',
			p.nazwisko		AS N'nazwisko',
			p.pesel			AS N'pesel'
	FROM	pacjent1 p
	UNION
	SELECT	p.id			AS N'id',
			p.imie			AS N'imie',
			p.nazwisko		AS N'nazwisko',
			p.pesel			AS N'pesel'
	FROM	pacjent2 p
GO

-- Wizyty (fragmentacja pionowa)
IF EXISTS (SELECT * 
				FROM sys.views
				WHERE object_id = OBJECT_ID(N'wizyty')
		)
	BEGIN
		DROP VIEW wizyty
	END
GO

CREATE VIEW wizyty
AS
	SELECT	w1.id			AS N'id',
			w2.id_pacjent	AS N'id_pacjent',
			p.imie			AS N'imie_pacjenta',
			p.nazwisko		AS N'nazwisko_pacjeta',
			w2.id_lekarz	AS N'id_lekarz',
			l.imie			AS N'imie_lekarza',
			l.nazwisko		AS N'nazwisko_lekarza',
			w1.data			AS N'data',
			w1.godzina		AS N'godzina',
			w1.opis			AS N'opis'
	FROM	wizyta1 w1
	JOIN	wizyta2 w2 ON (w2.id = w1.id)
	JOIN	pacjenci p ON (p.id = w2.id_pacjent)
	JOIN	lekarze l ON (l.id = w2.id_lekarz)
GO

-- Badania (fragmentacja pionowa)
IF EXISTS (SELECT * 
				FROM sys.views
				WHERE object_id = OBJECT_ID(N'badania')
		)
	BEGIN
		DROP VIEW badania
	END
GO

CREATE VIEW badania
AS
	SELECT	b1.id			AS N'id',
			b2.id_pacjent	AS N'id_pacjent',
			p.imie			AS N'imie',
			p.nazwisko		AS N'nazwisko',
			p.pesel			AS N'pesel',
			b1.typ			AS N'typ',
			b1.wyniki		AS N'wyniki'
	FROM	badanie1 b1
	JOIN	badanie2 b2 ON (b2.id = b1.id)
	JOIN	pacjenci p ON (p.id = b2.id_pacjent)
GO

/*************************
    PROCEDURY DODAWANIA
**************************/
-- Dodawanie przychodni
IF EXISTS( SELECT name FROM sysobjects WHERE name = 'dodaj_przychodnie' AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
	BEGIN
		DROP PROCEDURE dodaj_przychodnie
	END
GO

CREATE PROCEDURE dodaj_przychodnie(	
	@nazwa	varchar(30),
	@miasto	varchar(30),
	@ulica	varchar(30)
	) AS
	SET NOCOUNT ON
	BEGIN
		DECLARE @id	int

		SELECT	@id = max(p.id) + 1 FROM	przychodnie p
			IF( @id IS NULL ) SET @id = 1;

		IF NOT EXISTS ( SELECT * FROM	przychodnie p WHERE	p.nazwa = @nazwa
														AND	p.miasto = @miasto
														AND	p.ulica = @ulica )
			BEGIN
				IF (@miasto = 'Nysa')
					BEGIN
						INSERT INTO przychodnia1 VALUES(@id, @nazwa, @miasto, @ulica)
					END
				ELSE INSERT INTO przychodnia2 VALUES(@id, @nazwa, @miasto, @ulica)
			END
		ELSE PRINT N'Juz przychodnia ' + @nazwa + N' w ' + @miasto + '.'
	END
GO
/*
EXEC dodaj_przychodnie
	@nazwa = N'Dziecieca3',
	@miasto = N'Nysa',
	@ulica = N'Brzozowa'
GO
*/



-- Dodawanie lekarza
IF EXISTS ( SELECT name FROM sysobjects WHERE name = 'addDoctor' AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
	BEGIN
		DROP PROCEDURE addDoctor
	END
GO

CREATE PROCEDURE addDoctor (	
	@imie			varchar(30),
	@nazwisko		varchar(30),
	@tytul			varchar(30),
	@specjalizacja	varchar(30),
	@id_przychodnia	int,
	@wyplata		int)
	AS
	BEGIN
		DECLARE @id int
		IF NOT EXISTS(SELECT * FROM	lekarze l WHERE	l.imie = @imie
												AND	l.nazwisko = @nazwisko )
			BEGIN
				SELECT	@id = max(l.id)+1 FROM lekarze l
				IF( @id IS NULL ) SET @id = 1;
				
				IF EXISTS(SELECT * FROM	przychodnie p WHERE	p.id = @id_przychodnia)
					BEGIN
						INSERT INTO lekarz1 (id, imie, nazwisko, tytul, specjalizacja)
							VALUES(@id, @imie, @nazwisko, @tytul, @specjalizacja)

						INSERT INTO lekarz2 (id, imie, nazwisko, wyplata, id_przychodnia)
							VALUES(@id, @imie, @nazwisko, @wyplata, @id_przychodnia)
					END
				ELSE PRINT N'Clinic with id=' + @id_przychodnia + N'not exist.'
			END
		ELSE PRINT N'Already exist doctor ' + @imie + N' ' + @nazwisko + N'.'
	END
GO
/*
EXEC addDoctor
	@imie			= N'Mariusz',
	@nazwisko		= N'Goslda',
	@tytul			= N'Rezysdent',
	@specjalizacja	= N'Neurolog',
	@id_przychodnia	= N'1',
	@wyplata		= N'1500'
GO
select * from lekarze
*/

-- Dodawanie pacjenta
IF EXISTS( SELECT name 
	FROM sysobjects
	WHERE name = 'dodaj_pacjenta'
		AND OBJECTPROPERTY(id, N'IsProcedure') = 1
	)
	BEGIN
		DROP PROCEDURE dodaj_pacjenta
	END
GO

CREATE PROCEDURE dodaj_pacjenta
	(	
	@imie		varchar(30), 
	@nazwisko	varchar(30),
	@pesel		bigint
	)
	AS
	BEGIN
		DECLARE @id	int

		SELECT	@id = max(p.id) + 1 FROM	pacjenci p
			IF( @id IS NULL ) SET @id = 1;

		IF NOT EXISTS ( SELECT * FROM pacjenci	p WHERE p.imie = @imie
											AND p.nazwisko = @nazwisko
											AND p.pesel = @pesel )
			BEGIN
				IF( (@id% 2) = 0)
				BEGIN
					INSERT INTO pacjent2 VALUES(@id, @imie, @nazwisko, @pesel)
				END
				ELSE INSERT INTO pacjent1 VALUES(@id, @imie, @nazwisko, @pesel)
			END
		ELSE PRINT N'Istnieje juz pacjent ' + @imie + N' ' + @nazwisko + '.'
	END
GO
/*
select * from pacjenci
EXEC dodaj_pacjenta
	@imie = N'Wojciech1',
	@nazwisko = N'Maszur',
	@pesel = N'59751687411'
GO
*/

-- Dodawanie wizyt
IF EXISTS( SELECT name FROM sysobjects WHERE name = 'dodaj_wizyte' AND OBJECTPROPERTY(id, N'IsProcedure') = 1 )
	BEGIN
		DROP PROCEDURE dodaj_wizyte
	END
GO

CREATE PROCEDURE dodaj_wizyte (
	@imie_lekarza		varchar(30),
	@nazwisko_lekarza	varchar(30),
	@imie_pacjenta		varchar(30),
	@nazwisko_pacjenta	varchar(30),
	@data				date,
	@godzina			time(0), 
	@opis				text )
	AS
	BEGIN
		DECLARE @id	int
		DECLARE	@id_pacjent int
		DECLARE @id_lekarz	int

		SELECT	@id = max(w.id) + 1 FROM	wizyty w
			IF( @id IS NULL ) SET @id = 1;

		IF EXISTS ( SELECT * FROM	lekarze l WHERE	l.imie = @imie_lekarza
												AND	l.nazwisko = @nazwisko_lekarza )
			BEGIN
				SELECT @id_lekarz=l.id FROM	lekarze l WHERE	l.imie = @imie_lekarza
														AND	l.nazwisko = @nazwisko_lekarza
				
				IF EXISTS ( SELECT * FROM	pacjenci p WHERE p.imie = @imie_pacjenta
														 AND p.nazwisko = @nazwisko_pacjenta )
					BEGIN
						SELECT @id_pacjent=p.id FROM pacjenci p WHERE p.imie = @imie_pacjenta
																  AND p.nazwisko = @nazwisko_pacjenta
							IF NOT EXISTS ( SELECT * FROM wizyty w WHERE w.id_lekarz = @id_lekarz
																	 AND w.data = @data
																	 AND w.godzina = @godzina )
								BEGIN
									INSERT INTO wizyta1 VALUES (@id, @data, @godzina, @opis)
									INSERT INTO wizyta2 VALUES (@id, @id_pacjent, @id_lekarz)
								END
							ELSE PRINT N'Lekarz '  + @imie_lekarza + N' ' + @nazwisko_lekarza + ' ma wtedy inna wizyte.'
					END
				ELSE PRINT N'Nie znaleziono pacjeta ' + @imie_pacjenta + N' ' + @nazwisko_pacjenta + '.'
			END
		ELSE PRINT N'Nie znaleziono lekarza ' + @imie_lekarza + N' ' + @nazwisko_lekarza + '.'
	END
GO
/*
EXEC dodaj_wizyte
	@imie_lekarza		= N'Beata',
	@nazwisko_lekarza	= N'Bebolska',
	@imie_pacjenta		= N'Jan',
	@nazwisko_pacjenta	= N'Nowak',
	@data				= N'2018-11-16',
	@godzina			= N'7:00', 
	@opis				= N''
GO
*/

-- Dodawanie badania
IF EXISTS( SELECT name 
	FROM sysobjects
	WHERE name = 'dodaj_badanie'
		AND OBJECTPROPERTY(id, N'IsProcedure') = 1
	)
	BEGIN
		DROP PROCEDURE dodaj_badanie
	END
GO

--select * from badania
CREATE PROCEDURE dodaj_badanie
	(	
	@imie		varchar(30), 
	@nazwisko	varchar(30),
	@wyniki		text, 
	@typ		varchar(30)
	)
	AS
	BEGIN
		DECLARE @id	int
		DECLARE @id_pacjent	int

		SELECT	@id = max(b.id) + 1 FROM badania b
			IF( @id IS NULL ) SET @id = 1;

		IF NOT EXISTS ( SELECT * FROM	badania b WHERE	b.imie = @imie
													AND	b.nazwisko = @nazwisko
													AND	b.typ = @typ )
			BEGIN
				IF EXISTS ( SELECT * FROM pacjenci p WHERE	p.imie = @imie
														AND	p.nazwisko = @nazwisko)
					BEGIN
						SELECT @id_pacjent=p.id FROM pacjenci p WHERE p.imie = @imie
														  AND p.nazwisko = @nazwisko
						INSERT INTO badanie1 VALUES (@id, @wyniki, @typ)
						INSERT INTO badanie2 VALUES (@id, @id_pacjent)

					END
				ELSE PRINT N'Pacjent' + @imie + N' ' + @nazwisko + ' nie istnieje w bazie. Wpierw dodaj pacjeta.' 
			END
		ELSE PRINT N'Pacjent ' + @imie + N' ' + @nazwisko + ' mial juz badanie' + @typ + '.'
	END
GO
/*
EXEC dodaj_badanie
	@imie		= N'Wojciech',
	@nazwisko	= N'Mazur',
	@wyniki		= N'Zlananie drugiejj kosci srodstopia', 
	@typ		= N'Rentgen'
GO
*/

/*************************
    PROCEDURY USUWANIA
**************************/
-- Usuwanie przychodni wraz z edycja danych u lekarzy
IF EXISTS( SELECT name FROM sysobjects WHERE name = 'usun_przychodnie' AND OBJECTPROPERTY(id, N'IsProcedure') = 1 )
	BEGIN
		DROP PROCEDURE usun_przychodnie
	END
GO

CREATE PROCEDURE usun_przychodnie (	
	@nazwa	varchar(30),
	@miasto	varchar(30),
	@ulica	varchar(30) )
	AS
	BEGIN
		DECLARE @id	int
		IF EXISTS ( SELECT * FROM przychodnie p WHERE p.nazwa = @nazwa AND	p.miasto = @miasto AND	p.ulica = @ulica )
			BEGIN
				SELECT @id=p.id
					FROM	przychodnie p
					WHERE	p.nazwa = @nazwa
					AND		p.miasto = @miasto
					AND		p.ulica = @ulica
				IF NOT EXISTS(SELECT * FROM lekarz2 WHERE id_przychodnia=@id)
				BEGIN
					IF EXISTS (SELECT * FROM przychodnia1 WHERE id=@id)
						BEGIN
							DELETE FROM przychodnia1 WHERE id=@id
						END
					ELSE IF EXISTS (SELECT * FROM przychodnia2 WHERE id=@id)
						BEGIN
							DELETE FROM przychodnia2 WHERE id=@id
						END
				END
				ELSE PRINT N'Nie mozna usunac przychodni ' + @nazwa + N' poniewaz sa w niej zarejestrowanie lekarze.'
			END
		ELSE PRINT N'Przychodnia ' + @nazwa + N' w ' + @miasto + ' nie istnieje.'
	END
GO
/*
EXEC usun_przychodnie
	@nazwa = N'Arnika',
	@miasto = N'Nysa',
	@ulica = N'Bagienna 14'
GO
*/

-- Usuwanie lekarza wraz z wizytami
IF EXISTS( SELECT name 
	FROM sysobjects
	WHERE name = 'usun_lekarza'
		AND OBJECTPROPERTY(id, N'IsProcedure') = 1
	)
	BEGIN
		DROP PROCEDURE usun_lekarza
	END
GO


CREATE PROCEDURE usun_lekarza (	
	@imie		varchar(30), 
	@nazwisko	varchar(30) )
	AS
	BEGIN
		DECLARE @id			int
		DECLARE @id_wizyta	int

		IF EXISTS ( SELECT * FROM lekarze l WHERE l.imie = @imie
											 AND  l.nazwisko = @nazwisko )
			BEGIN
				SELECT @id=l.id
					FROM	lekarze l
					WHERE	l.imie = @imie
					AND		l.nazwisko = @nazwisko
				
				IF EXISTS
					(
						SELECT * 
						FROM	wizyty w
						WHERE	w.id_lekarz = @id
					)

				BEGIN
					SELECT @id_wizyta = w.id
						FROM	wizyty w
						WHERE	w.id_lekarz = @id
					DELETE FROM wizyta1 WHERE id = @id_wizyta
					DELETE FROM wizyta2 WHERE id = @id_wizyta
				END

				DELETE FROM lekarz1 WHERE id=@id
				DELETE FROM lekarz2 WHERE id=@id
				
			END
		ELSE PRINT N'Lekarz ' + @imie + N' ' + @nazwisko + ' nie istnieje.'
	END
GO


/*
EXEC usun_lekarza
	@imie			= N'Beata',
	@nazwisko		= N'Bebolska'
GO
*/

-- Usuwanie pacjenta wraz z wizytami i badaniami
IF EXISTS( SELECT name 
	FROM sysobjects
	WHERE name = 'usun_pacjenta'
		AND OBJECTPROPERTY(id, N'IsProcedure') = 1
	)
	BEGIN
		DROP PROCEDURE usun_pacjenta
	END
GO

CREATE PROCEDURE usun_pacjenta
	(	
	@imie		varchar(30), 
	@nazwisko	varchar(30),
	@pesel		bigint
	)
	AS
	BEGIN
		DECLARE @id			int
		DECLARE @id_wizyta	int
		DECLARE @id_badanie	int

		IF EXISTS
			(
				SELECT *
					FROM	pacjenci p
					WHERE	p.imie = @imie
					AND		p.nazwisko = @nazwisko
					AND		p.pesel = @pesel
			)
			BEGIN
				SELECT @id=p.id
					FROM	pacjenci p
					WHERE	p.imie = @imie
					AND		p.nazwisko = @nazwisko
					AND		p.pesel = @pesel
				
				IF EXISTS
					(
						SELECT * 
						FROM	wizyty w
						WHERE	w.id_pacjent = @id
					)

				BEGIN
					SELECT @id_wizyta = w.id
						FROM	wizyty w
						WHERE	w.id_pacjent = @id
					DELETE FROM wizyta1 WHERE id = @id_wizyta
					DELETE FROM wizyta2 WHERE id = @id_wizyta
				END

				IF EXISTS
					(
						SELECT * 
						FROM	badania b
						WHERE	b.id_pacjent = @id
					)

				BEGIN
					SELECT @id_badanie = b.id
						FROM	badania b
						WHERE	b.id_pacjent = @id
					DELETE FROM badanie1 WHERE id = @id_badanie
					DELETE FROM badanie2 WHERE id = @id_badanie
				END

				DELETE FROM pacjent1 WHERE id=@id
				DELETE FROM pacjent2 WHERE id=@id
				
			END
		ELSE PRINT N'Pacjent ' + @imie + N' ' + @nazwisko + N' z peselem: '+ @pesel+ ' nie istnieje.'
	END
GO
/*
EXEC usun_pacjenta
	@imie = N'Wojtek',
	@nazwisko = N'Jelonkiewicz',
	@pesel = N'69898966688'
GO
*/

-- usuwanie wizyt
IF EXISTS( SELECT name 
	FROM sysobjects
	WHERE name = 'usun_wizyte'
		AND OBJECTPROPERTY(id, N'IsProcedure') = 1
	)
	BEGIN
		DROP PROCEDURE usun_wizyte
	END
GO

CREATE PROCEDURE usun_wizyte
	(
	@imie_lekarza		varchar(30),
	@nazwisko_lekarza	varchar(30),
	@imie_pacjenta		varchar(30),
	@nazwisko_pacjenta	varchar(30),
	@data				date,
	@godzina			time(0)
	)
	AS
	BEGIN
		DECLARE @id	int
		DECLARE	@id_pacjent int
		DECLARE @id_lekarz	int

		SELECT	@id = max(w.id) + 1 FROM	wizyty w
			IF( @id IS NULL ) SET @id = 1;

		IF EXISTS
			(
				SELECT *
					FROM	lekarze l
					WHERE	l.imie = @imie_lekarza
					AND		l.nazwisko = @nazwisko_lekarza
			)
			BEGIN
				SELECT @id_lekarz=l.id
					FROM	lekarze l
					WHERE	l.imie = @imie_lekarza
					AND		l.nazwisko = @nazwisko_lekarza
				IF EXISTS
					(
						SELECT *
							FROM	pacjenci p
							WHERE	p.imie = @imie_pacjenta
							AND		p.nazwisko = @nazwisko_pacjenta
					)
					BEGIN
						SELECT @id_pacjent=p.id
							FROM	pacjenci p
							WHERE	p.imie = @imie_pacjenta
							AND		p.nazwisko = @nazwisko_pacjenta
							IF EXISTS
								(
								SELECT *
								FROM	wizyty w
								WHERE	w.id_lekarz = @id_lekarz
								AND		w.id_pacjent = @id_pacjent
								AND		w.data = @data
								AND		w.godzina = @godzina
								)
								BEGIN
									SELECT @id = w.id
										FROM	wizyty w
										WHERE	w.id_lekarz = @id_lekarz
										AND		w.id_pacjent = @id_pacjent
										AND		w.data = @data
										AND		w.godzina = @godzina
									DELETE FROM wizyta1 WHERE id = @id
									DELETE FROM wizyta2 WHERE id = @id		
								END
							ELSE PRINT N'Lekarz '  + @imie_lekarza + N' ' + @nazwisko_lekarza + ' i ' + @imie_pacjenta + N' ' + @nazwisko_pacjenta + ' nie sa umowieni na wizyte w tym czasie.'
					END
				ELSE PRINT N'Nie znaleziono pacjeta ' + @imie_pacjenta + N' ' + @nazwisko_pacjenta + '.'
			END
		ELSE PRINT N'Nie znaleziono lekarza ' + @imie_lekarza + N' ' + @nazwisko_lekarza + '.'
	END
GO
/*
EXEC usun_wizyte
	@imie_lekarza		= N'Beata',
	@nazwisko_lekarza	= N'Bebolska',
	@imie_pacjenta		= N'Jan',
	@nazwisko_pacjenta	= N'Nowak',
	@data				= N'2018-11-16',
	@godzina			= N'7:00'
GO
*/

-- Usuwanie badania
IF EXISTS( SELECT name 
	FROM sysobjects
	WHERE name = 'usun_badanie'
		AND OBJECTPROPERTY(id, N'IsProcedure') = 1
	)
	BEGIN
		DROP PROCEDURE usun_badanie
	END
GO

CREATE PROCEDURE usun_badanie
	(	
	@imie		varchar(30), 
	@nazwisko	varchar(30),
	@pesel		bigint,
	@typ		varchar(30)
	)
	AS
	BEGIN
		DECLARE @id	int
		DECLARE @id_pacjent	int

		IF EXISTS
			(
				SELECT *
					FROM	badania b
					WHERE	b.imie = @imie
					AND		b.nazwisko = @nazwisko
					AND		b.pesel = @pesel
					AND		b.typ = @typ
			)
			BEGIN
				SELECT @id = b.id
					FROM	badania b
					WHERE	b.imie = @imie
					AND		b.nazwisko = @nazwisko
					AND		b.pesel = @pesel
					AND		b.typ = @typ

				DELETE FROM badanie1 WHERE id=@id
				DELETE FROM badanie2 WHERE id=@id
			END
		ELSE PRINT N'Pacjent ' + @imie + N' ' + @nazwisko + ' nie ma takiego badania' + @typ + '.'
	END
GO
/*
EXEC usun_badanie
	@imie		= N'Wojciech',
	@nazwisko	= N'Mazur',
	@pesel		= N'59751568741',
	@typ		= N'Rentgen'
GO
*/

/*************************
    PROCEDURY EDYCJI
**************************/
IF EXISTS( SELECT name 
	FROM sysobjects
	WHERE name = 'zmien_przychodnie'
		AND OBJECTPROPERTY(id, N'IsProcedure') = 1
	)
	BEGIN
		DROP PROCEDURE zmien_przychodnie
	END
GO

-- Zmiana przychodni dla lekarza
CREATE PROCEDURE zmien_przychodnie
	(	
	@imie				varchar(30), 
	@nazwisko			varchar(30),
	@nowa_przychodnia	varchar(30)
	)
	AS
	BEGIN
		DECLARE @id	int
		DECLARE @id_przychodni int

		IF EXISTS (SELECT * 
					FROM	lekarze 
					WHERE	imie=@imie
					AND		nazwisko=@nazwisko)
			BEGIN
				SELECT @id=l.id
					FROM	lekarze l
					WHERE	l.imie=@imie
					AND		l.nazwisko=@nazwisko
					
					IF EXISTS (SELECT * 
						FROM	przychodnie 
						WHERE	nazwa=@nowa_przychodnia)
						BEGIN
							SELECT @id_przychodni=p.id
							FROM	przychodnie p
							WHERE	nazwa=@nowa_przychodnia

							UPDATE lekarz2 SET id_przychodnia=@id_przychodni WHERE id=@id
						END
					ELSE PRINT N'Przychodnia ' + @nowa_przychodnia + N' nie istnieje.'
			END
		ELSE PRINT N'Lekarz ' + @imie + N' ' + @nazwisko + ' nie istnieje'
	END
GO

/*
EXEC zmien_przychodnie
	@imie		= N'Beata',
	@nazwisko	= N'Bebolska',
	@nowa_przychodnia = N'MONAR'
GO
*/

/***********************************
    DODATKOWE PROCEDURY USUWANINA
************************************/
/*
select * from lekarze
CREATE PROCEDURE deleteClinic(@id int) AS
	BEGIN
		SELECT * FROM przychodnie p WHERE p.id=@id
		IF NOT EXISTS(SELECT * FROM lekarze l WHERE l.nazwa_przychodni=p.)
			BEGIN
				IF EXISTS(SELECT * FROM przychodnia WHERE id=@id)
				BEGIN
					IF EXISTS (SELECT * FROM przychodnia1 WHERE id=@id)
							BEGIN
								DELETE FROM przychodnia1 WHERE id=@id
							END
					IF EXISTS (SELECT * FROM przychodnia2 WHERE id=@id)
							BEGIN
								DELETE FROM przychodnia2 WHERE id=@id
							END
					ELSE PRINT N'Clinic not exist.'
				END
			END
		ELSE PRINT N'Some doctor is connected in this clinic.'
	END
GO*/
/*
CREATE PROCEDURE deleteDoctor(@id int) AS
	BEGIN
		IF EXISTS(SELECT * FROM lekarze l WHERE l.id = @id)
		BEGIN
			IF EXISTS(SELECT * FROM	wizyty w WHERE w.id_lekarz = @id)
			BEGIN
				IF EXIST(SELECT @id_wizyta = w.id FROM wizyty w WHERE w.id_lekarz = @id)
				BEGIN
					DELETE FROM wizyta1 WHERE id = @id_wizyta
					DELETE FROM wizyta2 WHERE id = @id_wizyta
				END

				DELETE FROM lekarz1 WHERE id=@id
				DELETE FROM lekarz2 WHERE id=@id
				
			END
		ELSE PRINT N'Lekarz nie istnieje.'
	END
GO

CREATE PROCEDURE deletePatient(@id int) AS
	BEGIN
		IF EXISTS(SELECT * FROM pacjenci p WHERE p.id = @id)
			BEGIN	
				IF EXISTS(SELECT * FROM	wizyty w WHERE w.id_pacjent = @id)
				BEGIN
					DELETE FROM wizyta1 WHERE id = @id_wizyta
					DELETE FROM wizyta2 WHERE id = @id_wizyta
				END

				IF EXISTS(SELECT * FROM	badania b WHERE b.id_pacjent = @id)
				BEGIN
					SELECT @id_badanie = b.id
						FROM	badania b
						WHERE	b.id_pacjent = @id
					DELETE FROM badanie1 WHERE id = @id_badanie
					DELETE FROM badanie2 WHERE id = @id_badanie
				END

				DELETE FROM pacjent1 WHERE id=@id
				DELETE FROM pacjent2 WHERE id=@id
				
			END
		ELSE PRINT N'Pacjent ' + @imie + N' ' + @nazwisko + N' z peselem: '+ @pesel+ ' nie istnieje.'
	END
GO

-- usuwanie wizyt
IF EXISTS( SELECT name 
	FROM sysobjects
	WHERE name = 'usun_wizyte'
		AND OBJECTPROPERTY(id, N'IsProcedure') = 1
	)
	BEGIN
		DROP PROCEDURE usun_wizyte
	END
GO

CREATE PROCEDURE usun_wizyte
	(
	@imie_lekarza		varchar(30),
	@nazwisko_lekarza	varchar(30),
	@imie_pacjenta		varchar(30),
	@nazwisko_pacjenta	varchar(30),
	@data				date,
	@godzina			time(0)
	)
	AS
	BEGIN
		DECLARE @id	int
		DECLARE	@id_pacjent int
		DECLARE @id_lekarz	int

		SELECT	@id = max(w.id) + 1 FROM	wizyty w
			IF( @id IS NULL ) SET @id = 1;

		IF EXISTS
			(
				SELECT *
					FROM	lekarze l
					WHERE	l.imie = @imie_lekarza
					AND		l.nazwisko = @nazwisko_lekarza
			)
			BEGIN
				SELECT @id_lekarz=l.id
					FROM	lekarze l
					WHERE	l.imie = @imie_lekarza
					AND		l.nazwisko = @nazwisko_lekarza
				IF EXISTS
					(
						SELECT *
							FROM	pacjenci p
							WHERE	p.imie = @imie_pacjenta
							AND		p.nazwisko = @nazwisko_pacjenta
					)
					BEGIN
						SELECT @id_pacjent=p.id
							FROM	pacjenci p
							WHERE	p.imie = @imie_pacjenta
							AND		p.nazwisko = @nazwisko_pacjenta
							IF EXISTS
								(
								SELECT *
								FROM	wizyty w
								WHERE	w.id_lekarz = @id_lekarz
								AND		w.id_pacjent = @id_pacjent
								AND		w.data = @data
								AND		w.godzina = @godzina
								)
								BEGIN
									SELECT @id = w.id
										FROM	wizyty w
										WHERE	w.id_lekarz = @id_lekarz
										AND		w.id_pacjent = @id_pacjent
										AND		w.data = @data
										AND		w.godzina = @godzina
									DELETE FROM wizyta1 WHERE id = @id
									DELETE FROM wizyta2 WHERE id = @id		
								END
							ELSE PRINT N'Lekarz '  + @imie_lekarza + N' ' + @nazwisko_lekarza + ' i ' + @imie_pacjenta + N' ' + @nazwisko_pacjenta + ' nie sa umowieni na wizyte w tym czasie.'
					END
				ELSE PRINT N'Nie znaleziono pacjeta ' + @imie_pacjenta + N' ' + @nazwisko_pacjenta + '.'
			END
		ELSE PRINT N'Nie znaleziono lekarza ' + @imie_lekarza + N' ' + @nazwisko_lekarza + '.'
	END
GO

-- Usuwanie badania
IF EXISTS( SELECT name 
	FROM sysobjects
	WHERE name = 'usun_badanie'
		AND OBJECTPROPERTY(id, N'IsProcedure') = 1
	)
	BEGIN
		DROP PROCEDURE usun_badanie
	END
GO

CREATE PROCEDURE usun_badanie
	(	
	@imie		varchar(30), 
	@nazwisko	varchar(30),
	@pesel		bigint,
	@typ		varchar(30)
	)
	AS
	BEGIN
		DECLARE @id	int
		DECLARE @id_pacjent	int

		IF EXISTS
			(
				SELECT *
					FROM	badania b
					WHERE	b.imie = @imie
					AND		b.nazwisko = @nazwisko
					AND		b.pesel = @pesel
					AND		b.typ = @typ
			)
			BEGIN
				SELECT @id = b.id
					FROM	badania b
					WHERE	b.imie = @imie
					AND		b.nazwisko = @nazwisko
					AND		b.pesel = @pesel
					AND		b.typ = @typ

				DELETE FROM badanie1 WHERE id=@id
				DELETE FROM badanie2 WHERE id=@id
			END
		ELSE PRINT N'Pacjent ' + @imie + N' ' + @nazwisko + ' nie ma takiego badania' + @typ + '.'
	END
GO
*/