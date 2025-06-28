CREATE PROCEDURE sp_determinaPeriodo @rut as char(9) 
AS

declare @fecIni datetime
declare @fecTer datetime

set @fecIni = (select top 1 rec_periodo from trabajador
		where tra_rut = @rut
		order by rec_periodo desc)

set @fecTer = Dateadd(mm, -11, @fecini)

SELECT rec_periodo FROM trabajador 
WHERE rec_periodo BETWEEN   @fecTer  AND @fecIni
AND tra_rut = @rut
GROUP BY rec_periodo
ORDER BY rec_periodo ASC 


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO