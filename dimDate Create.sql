IF NOT EXISTS(SELECT NULL FROM sys.tables t WHERE t.name = 'dimDate')
BEGIN
	CREATE TABLE dbo.dimDate(
		dimDate DATE NOT NULL
			CONSTRAINT PK_dbo_dimDate PRIMARY KEY CLUSTERED(dimDate)
	);

	;WITH Dates(dt)
	AS
	(
		SELECT CAST('1/1/1900' AS DATE)
		UNION ALL
		SELECT DATEADD(DAY, 1, dt)
		FROM Dates d
		WHERE d.dt<'12/31/2099'
	)
	INSERT INTO dbo.dimDate(dimDate)
	SELECT d.dt
	FROM Dates d
	OPTION(MAXRECURSION 0);
END

--YYYYMMDD
IF NOT EXISTS(SELECT NULL FROM sys.columns c WHERE c.name = 'YYYYMMDD' AND c.object_id = OBJECT_ID('dbo.dimDate'))
BEGIN
	ALTER TABLE dbo.dimDate
	ADD [YYYYMMDD] CHAR(8)

	UPDATE dd
	SET 
		[YYYYMMDD] = CONCAT(
						CAST(DATEPART(YEAR,dimDate) AS varCHAR(4))
						,RIGHT('0' + CAST(DATEPART(MONTH, dimDate) AS varCHAR(4)), 2)
						,RIGHT('0' + CAST(DATEPART(DAY, dimDate) AS varCHAR(4)), 2)

					)
	FROM dbo.dimDate dd
END