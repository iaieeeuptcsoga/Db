<%
'+-------------------------------------------------------------------------------------------------------
'|					S Q L  D E  D E T A L L E  D E  
'|	Fecha : 04-11-2005
'|	Descripción : 
'+-------------------------------------------------------------------------------------------------------
Function SQL_TRA_DET(ConnBd, byRef rsx,fec_ini,fec_ter,emp_rut,convenio,rut_tra) 

	dim sql 
	DIM CRIT_SUC

	CRIT_SUC =" SELECT DET_CTA_USU.COD_SUC FROM DET_CTA_USU DET_CTA_USU " & _
						" WHERE (DET_CTA_USU.CON_RUT=" & emp_rut & ")" & _
						" AND (DET_CTA_USU.CON_CORREL=" & convenio & ") " & _
						" AND (DET_CTA_USU.USR_RUT=" &  Session("RutRep") & ")"
			
	IF Session("USU_COD_PER")<>"SI" THEN  CRIT_SUC=""
	
	
	
	sql = "EXEC sp_certCot_SIL '" & fec_ini & "','" & fec_ter & "'," & emp_rut & "," &	convenio & "," & rut_tra

'Response.Write sql
'Response.End 
	rsx.CursorLocation = adUseClient
	rsx.Open sql,ConnBd, adOpenKeyset,adLockOptimistic   

	if err.number <> 0 then
 		msgTxt = "Error al ejecutar consulta."
		fx_SQL_PEN_DET = msgTxt
		exit function
	end if

 	if rsx.EOF or rsx.BOF then
 		msgTxt = "No se encuentra información de la persona solicitada."
		fx_SQL_PEN_DET = msgTxt
		exit function
	end if
	
end function 'fx_SQL_PEN_DET 
 
'SQL_TRA_DET con,RsxDetTrab,"2003-01-31","2003-12-31",81826800,1,13287666
%>