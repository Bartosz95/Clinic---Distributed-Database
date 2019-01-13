-- dodawanie zezwolenia na odwrotne polaczenie
EXEC sp_addlinkedserver
	@server = 'Linked_firma_medyczna_1',
	@srvproduct = '',
	@provider = 'SQLNCLI',
	@datasrc = '192.168.43.5',
	@catalog = 'firma_medyczna'
GO

EXEC sp_addlinkedserver
	@server = 'Linked_firma_medyczna_2',
	@srvproduct = '',
	@provider = 'SQLNCLI',
	@datasrc = '192.168.43.6',
	@catalog = 'firma_medyczna'
GO

EXEC sp_serveroption -- zgodnosc ustawien jezykowych
	@server = N'Linked_firma_medyczna_2',
	@optname = N'collation compatible',
	@optvalue = N'false'
GO

EXEC sp_serveroption -- zapytania rozproszone
	@server = N'Linked_firma_medyczna_2',
	@optname = N'data access',
	@optvalue = N'true'
GO

EXEC sp_serveroption -- zdalen wywolywanie procedur z serwera polaczonego
	@server = N'Linked_firma_medyczna_2',
	@optname = N'rpc',
	@optvalue = N'true'
GO

EXEC sp_serveroption --przekazywanie zdalne wywolywania procedur do poloczonego servera
	@server = N'Linked_firma_medyczna_2',
	@optname = N'rpc out',
	@optvalue = N'true'
GO

EXEC sp_serveroption --czas wygasnieczia poloczenia z serverem
	@server = N'Linked_firma_medyczna_2',
	@optname = N'connect timeout',
	@optvalue = N'0'
GO

EXEC sp_serveroption -- umozniwia wskazanie ustawien jezykowych dla zapytan (uzycie wymaga wylaczenia collation compatible)
	@server = N'Linked_firma_medyczna_2',
	@optname = N'collation name',
	@optvalue = null
GO

EXEC sp_serveroption --czas wygasniecia zapytan kierowanych do servera zdalnego
	@server = N'Linked_firma_medyczna_2',
	@optname = N'query timeout',
	@optvalue = N'0'
GO

EXEC sp_serveroption --ustawienia jezykowe dla kolumn znakowych
	@server = N'Linked_firma_medyczna_2',
	@optname = N'use remote collation',
	@optvalue = N'true'
GO

EXEC sp_addlinkedsrvlogin
	@rmtsrvname = 'Linked_firma_medyczna_2',
	@locallogin = NULL, -- identyfikator konta lokalnego do komunikacji z zdalnym serverem
	@useself = N'true'
GO


