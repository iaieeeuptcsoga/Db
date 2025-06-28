CREATE procedure sp_actCertCot_generados @fechaGen datetime
as 

set nocount on

begin transaction

IF EXISTS(SELECT * FROM certcot_generados  
			WHERE fechaGen = @fechaGen) 
BEGIN  
		UPDATE certcot_generados  
		SET cantGen =  cantGen + 1 
		WHERE fechaGen = @fechaGen  
	END  
ELSE 
	BEGIN 
		INSERT INTO certcot_generados (fechaGen,cantGen) 
		VALUES(@fechaGen,1) 
	END;

if @@error <> 0 
begin
	rollback transaction
	return -1
end 
else
begin
	commit transaction
	return 0
end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO