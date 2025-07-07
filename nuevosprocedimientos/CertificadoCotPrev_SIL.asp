<%@ Language=VBScript %>
<%
'+-------------------------------------------------------------------------------------------------------------
'|						C E R T I F I C A D O   D E   C O T I Z A C I O N E S   S . I . L . 
'|Fecha: 13-04-2006
'|Autor:IPA
'|Desc:	Nvo Certificado de cotizaciones SIL. Este tiene la misma estructura del certificado normal utilizando 
'|		procedimiento almacenado para obtener la información de los trabajadores.
'+-------------------------------------------------------------------------------------------------------------

'===============================================
'Fecha ultima modificacion: 06-06-2011
'-----------------------------------------------

'Fecha Modificacion: 06-06-2011 por VOS
'Descripcion: Contabilizar los certificados emitidos
'comentario modificacion: VOS20110606
'==================================================


%>
<!-- #include file="../layaut/layautCert_SIL.asp"-->
<!-- #include file="../sql/sqlCert_SIL.asp"-->

<!-- #include file="../../data.inc" -->
<!-- #include file="../../../adovbs.inc"-->
<!-- #include file="../../../../Utilitarios/funciones_fechas.asp"-->
<!-- #include file="../../../../../SQLConnection.cls" -->
<%


Server.ScriptTimeout = 3600

dim A,B,C,n
Dim objDoc, objPage,ConnBd
Dim csqlx ,csqlx0,csqlx1,csqlx2,csqlx3,csqlx4 ,csqlx5,csqlx6
dim CondINP,CondAFP,CondISA,CondFON,CondCAJA,CondMUT

Dim rsx
Dim rsxBdSegCes
Dim rsxBdCCAF
Dim rsxBdSal

DIM nReg,xReg
dim xfecha,xfecha1
dim xdia,xmes ,xano
dim Ndias,Nombre,Pers_rut 
dim EmpRut,Per_Rut,Per_Desde,Per_Hasta
dim msError 
Dim proc
DIM DDesde,MDesde,ADesde,DHasta,MHasta,AHasta,Fmes

Dim cnvCta
Dim selOp 
Dim anio
Dim nMes 'VOS 11/04/2008 
'--------------------------------

'=== VOS Cert por Proc 20091007 ===
Dim anioHasta
Dim mesHasta
'=== Fin VOS Cert por Proc 20091007 ===


'=== VOS20110606 ===
Dim sFechaCreaPdf
Dim sqlStrCant

sFechaCreaPdf = Now()
sFechaCreaPdf = Year(sFechaCreaPdf) & Right("00" & Month(sFechaCreaPdf),2) & Right("00" & day(sFechaCreaPdf),2)
'=== Fin VOS20110606 ===




Set objDoc = Server.CreateObject("DPDF_Gen.Document")
Set ConnBd = Server.CreateObject("ADODB.Connection")
Set rsx=Server.CreateObject("ADODB.recordset")

ConnBd.CommandTimeout = 3600
ConnBd.ConnectionTimeout = 3600
ConnBd.CursorLocation = adUseClient
'ConnBd.Open Application("DSN")
ConnBd.Open SQLConnectionString


'===============================================
'Funcion para obtener el ultimo dia de un mes
'===============================================
Function UltimoDiaDeMes(iMonth, iYear)
	Dim sDate
	Dim MesSiguiente

	sDate = DateSerial(iYear, iMonth, "01")
	MesSiguiente = DateAdd("m", 1, SDate)
	UltimoDiaDeMes = Day(DateAdd("d", -1, MesSiguiente))

End Function



'=========================================================================================
'	Funcion que determina las fechas de inicio y termino de los periodos para los 
'	últimos 12 meses.
'=========================================================================================
sub ult12(byVal conBd,byVal rutPer,byRef perDesde, byRef perHasta)

	Dim sqlStr
	Dim rs
	Dim miDesde
	Dim miHasta
	
	
	set rs = Server.CreateObject("Adodb.Recordset")
	
	sqlStr = "EXECUTE sp_determinaPeriodo " & rutPer
	
	rs.Open sqlStr,conBd
	
	Dim i
	Dim totReg
	if rs.eof or rs.bof then
		miDesde = ""
		miHasta = ""
	else
		rs.MoveFirst
		miDesde = trim(rs("rec_periodo"))
		do while not rs.EOF 
			miHasta = trim(rs("rec_periodo"))
			rs.MoveNext 
		loop
		perDesde = year(cDate(miDesde)) & "-" & month(cDate(miDesde)) & "-" & day(cDate(miDesde))
		perHasta = year(cDate(miHasta)) & "-" & month(cDate(miHasta)) & "-" & day(cDate(miHasta))
	end if

	rs.close
	set rs = nothing

end sub
'=========================================================================================


EmpRut =CStr(trim(Session("RutEmp")))


'EmpRut =81826800

'=========================================================================================
'	Sección nueva que determina el tipo de certificado a imprimir
'=========================================================================================
if not isNull(Request.QueryString("rutTra")) and Request.QueryString("rutTra") <> ""  then
	'originales
	Per_Rut= trim(Request.QueryString("rutTra"))
	cnvCta= trim(Request.QueryString("cnvCta"))
	selOp = cInt(trim(Request.QueryString("selOp")))
	anio = trim(Request.QueryString("anio"))
	nMes = trim(Request.QueryString("mes"))  'VOS 04/11/2008

	'=== VOS Cert por Proc 20091007 ===
	anioHasta = trim(Request.QueryString("anioHasta"))
	mesHasta = trim(Request.QueryString("mesHasta"))
	'=== Fin VOS Cert por Proc 20091007 ===


else
	Per_Rut= trim(Request.Form("rutTra"))
	cnvCta= trim(Request.Form("cnvCta"))
	selOp = cInt(trim(Request.Form("selOp")))
	anio = trim(Request.Form("anio"))
	nMes = trim(Request.Form("mes")) 'VOS 04/11/2008

	'=== VOS Cert por Proc 20091007 ===
	anioHasta = trim(Request.Form("anioHasta"))
	mesHasta = trim(Request.Form("mesHasta"))
	'=== Fin VOS Cert por Proc 20091007 ===

end if

'EmpRut = Request.Form("EmpRut")
'per_rut = Request.Form("per_rut")

select case selOp
	case 1 'Busca un año especifico
		Per_Desde = anio & "-01-31"		
		Per_Hasta = anio & "-12-31"

	case 2 'Determina los ultimos 12 meses

		if err.number <> 0 then

			set objDoc = nothing
			set ConnBd = nothing
			set rsx = nothing
			set rsx = nothing

			msgError = "Error al conectar. <br>"
			msgError = msgError & "Descripción : " & Err.Description 
			Err.Clear 
			Response.Redirect "error.asp?msgError=" & msgError
			Response.End 
		end if
		
		call ult12(ConnBd,Per_Rut, Per_Desde, Per_Hasta)
		
	'=== VOS 11/04/2008 ====
	case 4 'Busca un año y mes especifico
		Per_Desde = anio & "-" & nMes & "-" & UltimoDiaDeMes(nMes,anio)	
		Per_Hasta = anio & "-" & nMes & "-" & UltimoDiaDeMes(nMes,anio)
	'=== Fin VOS 11/04/2008 ====
	
	'=== VOS Cert por Proc 20091007 ===
	case 5 'Busca un año y mes especifico
		Per_Desde = anio & "-" & nMes & "-" & UltimoDiaDeMes(nMes,anio)	
		Per_Hasta = anioHasta & "-" & mesHasta & "-" & UltimoDiaDeMes(mesHasta,anioHasta)
	'=== VOS Cert por Proc 20091007 ===
	
		
end select
'=========================================================================================


AddPages objDoc, objPage
n=133

dim nRegx,NumPag,xNumPag,nPag,nEncabezado,RegHasta 

nRegx=0
xNumPag=1
nPag =0
nEncabezado =0

SQL_TRA_DET ConnBd,rsx,per_desde,per_hasta,EmpRut,cnvCta,Per_Rut

'Verifica si recupera datos
if rsx.EOF or rsx.BOF then

	rsx.Close 
	ConnBd.Close 
	
	set rsx = nothing
	set ConnBd = nothing
	
	Response.Write "<br><br>"
	Response.Write "<link rel=""stylesheet"" href=""../../../include/Stl_misCot.css"" type=""text/css"">"
	Response.Write "<div align=""center""><b>La persona no esta asociada a la empresa. </b></div>"
	Response.Write "<br><br>"
	Response.Write "<div align=""center""><a href=""javascript:window.close()"">Cerrar</a></div>"
	Response.End 
	

end if

nregx = rsx.RecordCount 
 
numPag = numPer(ConnBd,anio,EmpRut,cnvCta,Per_Desde,Per_Hasta,Per_rut,nregx)

regPer = 0
npag = 0
rsx.MoveFirst 
periodoAnt = trim(rsx("rec_periodo"))

'Bucle que realiza la construcción del documento
DO WHILE  NOT  rsx.EOF 
 
 
    if nEncabezado =0 then 
		Encabezado rsx
	end if
	
    nEncabezado = 1
      
	flag = false
	 
    if npag < RegHasta then
     
		'+-----------------------------------------------------------------------
		'| Cambios realizados el 16-12-2003
		'| Debido a que deja de existir las isapres Vida Plena y Cigna Salud
		'| aplicado solo al periodo 11-2003
		'+-----------------------------------------------------------------------
		If YEAR(rsx("rec_periodo")) = "2003" and MONTH(rsx("rec_periodo")) = "11" then	
			if len(rsx("TRA_REG_SAL")) = 0 THEN 		
				flag = false
			else
				IF cLng(rsx("TRA_REG_SAL")) = 20 OR cLng(rsx("TRA_REG_SAL")) = 5 THEN
					'indica que cotiza en Vida Plena o en Cigna
					flag = true
				else
					flag = false
				END IF
			end if			
		else
			flag = false
		end if 
		'-------------------------------------------------------------------------
		    
    
    	if periodoAnt <> trim(rsx("rec_periodo")) then
			objPage.Addrectangle -20,n,571,10,"FFFFFF","000000",,,3
			n = n + 10
			npag = npag + 1
		end if
								
		objPage.Addrectangle -20,n,120,10,"FFFFFF","000000",,,3
		objPage.Addrectangle 100,n,43,10,"FFFFFF","000000",,,3

		objPage.Addrectangle 143,n,45,10,"FFFFFF","000000",,,3
		objPage.Addrectangle 188,n,45,10,"FFFFFF","000000",,,3
								 
		objPage.Addrectangle 233,n,30,10,"FFFFFF","000000",,,3
		objPage.Addrectangle 263,n,50,10,"FFFFFF","000000",,,3
		objPage.Addrectangle 313,n,50,10,"FFFFFF","000000",,,3
		objPage.Addrectangle 363,n,45,10,"FFFFFF","000000",,,3
		objPage.Addrectangle 408,n,45,10,"FFFFFF","000000",,,3
						
		objPage.Addrectangle 453,n,98,10,"FFFFFF","000000",,,3

		
		'Hubica los datos del trabajador------------------------------
		if flag then 'si cotiza en Cigna o Vida Plena
			objPage.addtextarea  mid(nombreEntidad(trim(rsx("salud")),2),1,26)  ,-17, n, 504, 12,1,7,8,"000000"
		else
			'===  VOS 02/05/2008 SANTA MARIA ===
			'objPage.addtextarea  mid(trim(rsx("ENT_NOMbre")),1,26)  ,-17, n, 504, 12,1,7,8,"000000"
		
			If (Trim(rsx("ENT_RUT")) = "98000000" _
				and (YEAR(rsx("rec_periodo")) < 2008 or (YEAR(rsx("rec_periodo")) = 2008 and MONTH(rsx("rec_periodo")) <= 3))) then 
					
					If Trim(rsx("ENT_NOMBRE")) <> "SEG. CES." Then
						objPage.addtextarea  "SANTA MARIA"  ,-17, n, 504, 12,1,7,8,"000000"
					else
						objPage.addtextarea  mid(trim(rsx("ENT_NOMbre")),1,26)  ,-17, n, 504, 12,1,7,8,"000000"
					end if
			
			else
				objPage.addtextarea  mid(trim(rsx("ENT_NOMbre")),1,26)  ,-17, n, 504, 12,1,7,8,"000000"
			end if
		
			'===  Fin VOS 02/05/2008 SANTA MARIA ===
		end if 
												            
		objPage.addtextarea  MES(MONTH(rsx("rec_periodo")),YEAR(rsx("rec_periodo"))) ,103, n, 350, 12,,7,8,"000000"

		objPage.addtextarea  formatFecha(trim(rsx("FEC_INISUB"))) ,145, n, 45, 12,1,7,8,"000000"
		objPage.addtextarea  formatFecha(trim(rsx("FEC_TERSUB"))) ,191, n, 45, 12,1,7,8,"000000"

		objPage.addtextarea  replace(formatNumber(rsx("DIAS_TRAB"),0),",",".") ,232, n, 30, 12,2,7,8,"000000"
							 
		objPage.addtextarea  REPLACE(FormatCurrency(rsx("REM_IMPO"),0),",",".")  ,263, n, 50, 12,2,7,8,"000000"
					    
		objPage.addtextarea  REPLACE(FormatCurrency(rsx("monto_cotizado"),0),",","."),313, n, 50, 12,2,7,8,"000000"
		objPage.addtextarea  formatFecha(rsx("FEC_PAGo")),365, n, 45, 12,,7,8,"000000"
	
		if len(rsx("folio_planilla")) > 0 then 
			objPage.addtextarea  rsx("folio_planilla"),408, n, 45, 12,2,7,8,"000000"
		end if
		objPage.addtextarea  mid(rsx("RAZ_SOC"),1,24),455, n, 97, 12,1,7,8,"000000"

		n=n+10
				
		npag = npag + 1
		    
	ELSE
	  
		objPage.addtextarea "_____________________________",-20, 680, 604, 12,,,10,"000000"
		objPage.addtextarea "_____________________________",-18, 680, 604, 12,,,10,"000000"
		objPage.addtextarea "Certificado jurídicamente válido para cumplir con la exigencia contenida en el Artículo  31 del D.F.L. Nº 2, de 1967, Ley Orgánica de la Dirección del Trabajo (ORD. Nº 2460 del 27 Junio de 2003)" ,-20, 690, 604, 12,,,5,"000000"
			
		objPage.addtextarea "Página: " & xNumPag & " de " &  numpag ,473, -25, 604, 12,,,7,"000000"
			    
	    AddPages objDoc, objPage
	    nx=0

		objPage.Addrectangle -20,nX,120,20,"FFFFFF","000000",,,3
		objPage.addtextarea "Institución de Previsión",-3,nX+5, 504, 12,,7,7,"000000"
			   
		objPage.Addrectangle 100,nX,43,20,"FFFFFF","000000",,,3
		objPage.addtextarea "Mes y año",103,nX+1, 350, 12,,7,7,"000000"
		objPage.addtextarea "Periodo",103,nX+10, 350, 12,,7,7,"000000"
				
		 'Fecha de inicio de SubSidio   
		objPage.Addrectangle 143,nX,45,20,"FFFFFF","000000",,,3
		objPage.addtextarea "Fecha",145,nX+1, 504, 12,,7,7,"000000"
		objPage.addtextarea "Ini. Sub.",145,nX+10, 504, 12,,7,7,"000000"
		 'Fecha de termino Subsidio
		objPage.Addrectangle 188,nX,45,20,"FFFFFF","000000",,,3
		objPage.addtextarea "Fecha ",195,nX+1, 504, 12,,7,7,"000000"
		objPage.addtextarea "Ter. Sub.",195,nX+10, 504, 12,,7,7,"000000"

		objPage.Addrectangle 233,nx,30,20,"FFFFFF","000000",,,3
		objPage.addtextarea "Días de",235,nX+1, 504, 12,,7,7,"000000"
		objPage.addtextarea "licencia",235,nX+10, 504, 12,,7,7,"000000"
			   
		objPage.Addrectangle 263,nX,50,20,"FFFFFF","000000",,,3
		objPage.addtextarea "Remuneración",265,nX+1, 504, 12,,7,7,"000000"
		objPage.addtextarea "Imponible",265,nX+10, 504, 12,,7,7,"000000"
			  
		objPage.Addrectangle 313,nX,50,20,"FFFFFF","000000",,,3
		objPage.addtextarea "Monto",315,nX+1, 504, 12,,7,7,"000000"
		objPage.addtextarea "Cotizado",315,nX+10, 504, 12,,7,7,"000000"
			   
		objPage.Addrectangle 363,nX,45,20,"FFFFFF","000000",,,3
		objPage.addtextarea "Fecha",365,nX+1, 504, 12,,7,7,"000000"
		objPage.addtextarea "de pago",365,nX+10, 504, 12,,7,7,"000000"

		objPage.Addrectangle 408,nX,45,20,"FFFFFF","000000",,,3
		objPage.addtextarea "Nº folio",410,nX+1, 504, 12,,7,7,"000000"
		objPage.addtextarea "planilla",410,nX+10, 504, 12,,7,7,"000000"

		objPage.Addrectangle 453,nX,98,20,"FFFFFF","000000",,,3 
		objPage.addtextarea "Entidad pagadora de Subsidio",455,nX+5, 504, 12,,7,7,"000000"

	    xNumPag= xNumPag +1
	    N = 20 
		nPag =0	 


		'+-----------------------------------------------------------------------
		'| Cambios realizados el 16-12-2003
		'| Debido a que deja de existir las isapres Vida Plena y Cigna Salud
		'| aplicado solo al periodo 11-2003
		'+-----------------------------------------------------------------------
		If year(rsx("rec_periodo")) = "2003" and month(rsx("rec_periodo")) = "11" then			
			IF Len(rsx("salud")) > 0 THEN
				'indica que cotiza en Vida Plena o en Cigna
				flag = true
			else
				flag = false
			END IF
		else
			flag = false
		end if 
		'-------------------------------------------------------------------------
			
		objPage.Addrectangle -20,n,120,10,"FFFFFF","000000",,,3
		objPage.Addrectangle 100,n,43,10,"FFFFFF","000000",,,3

		objPage.Addrectangle 143,n,45,10,"FFFFFF","000000",,,3
		objPage.Addrectangle 188,n,45,10,"FFFFFF","000000",,,3
								 
		objPage.Addrectangle 233,n,30,10,"FFFFFF","000000",,,3
		objPage.Addrectangle 263,n,50,10,"FFFFFF","000000",,,3
		objPage.Addrectangle 313,n,50,10,"FFFFFF","000000",,,3
		objPage.Addrectangle 363,n,45,10,"FFFFFF","000000",,,3
		objPage.Addrectangle 408,n,45,10,"FFFFFF","000000",,,3
						
		objPage.Addrectangle 453,n,98,10,"FFFFFF","000000",,,3


		'Hubica los datos del trabajador------------------------------
		if flag then 'si cotiza en Cigna o Vida Plena
			objPage.addtextarea  mid(nombreEntidad(trim(rsx("salud")),2),1,26)  ,-17, n, 504, 12,1,7,8,"000000"
		else
			'===  VOS 02/05/2008 SANTA MARIA ===
			'objPage.addtextarea  mid(trim(rsx("ENT_NOMbre")),1,26)  ,-17, n, 504, 12,1,7,8,"000000"
		
			If (Trim(rsx("ENT_RUT")) = "98000000" _
				and (YEAR(rsx("rec_periodo")) < 2008 or (YEAR(rsx("rec_periodo")) = 2008 and MONTH(rsx("rec_periodo")) <= 3))) then 
				If Trim(rsx("ENT_NOMBRE")) <> "SEG. CES." Then
					objPage.addtextarea  "SANTA MARIA"  ,-17, n, 504, 12,1,7,8,"000000"
				else
					objPage.addtextarea  mid(trim(rsx("ENT_NOMbre")),1,26)  ,-17, n, 504, 12,1,7,8,"000000"
				end if
			
			else
				objPage.addtextarea  mid(trim(rsx("ENT_NOMbre")),1,26)  ,-17, n, 504, 12,1,7,8,"000000"
			end if
		
			'===  Fin VOS 02/05/2008 SANTA MARIA ===
		end if 
												            
		objPage.addtextarea  MES(MONTH(rsx("rec_periodo")),YEAR(rsx("rec_periodo"))) ,103, n, 350, 12,,7,8,"000000"

		objPage.addtextarea  formatFecha(trim(rsx("FEC_INISUB"))) ,145, n, 45, 12,1,7,8,"000000"
		objPage.addtextarea  formatFecha(trim(rsx("FEC_TERSUB"))) ,191, n, 45, 12,1,7,8,"000000"

		objPage.addtextarea  replace(formatNumber(rsx("DIAS_TRAB"),0),",",".") ,232, n, 30, 12,2,7,8,"000000"
							 
		objPage.addtextarea  REPLACE(FormatCurrency(rsx("REM_IMPO"),0),",",".")  ,263, n, 50, 12,2,7,8,"000000"
					    
		objPage.addtextarea  REPLACE(FormatCurrency(rsx("monto_cotizado"),0),",","."),313, n, 50, 12,2,7,8,"000000"
		objPage.addtextarea  formatFecha(rsx("FEC_PAGo")),365, n, 45, 12,,7,8,"000000"
	
		if len(rsx("folio_planilla")) > 0 then 
			objPage.addtextarea  rsx("folio_planilla"),408, n, 45, 12,2,7,8,"000000"
		end if
		objPage.addtextarea  mid(rsx("RAZ_SOC"),1,24),455, n, 97, 12,1,7,8,"000000"

		n=n+10
				
		npag = npag + 1
		    
	END IF

	periodoAnt = trim(rsx("rec_periodo"))

	RSx.MOVENEXT

LOOP

pie n

objPage.addtextarea "Página: " & xNumPag & " de " &  numpag ,473, -25, 604, 12,,,7,"000000"
			
objDoc.DrawToASP
Set objDoc = Nothing
Set objPage = Nothing
rsx.Close 


'=== VOS20110606 ===
sqlStrCant = "EXEC sp_actCertCot_generados '" & sFechaCreaPdf & "'" 
ConnBd.Execute sqlStrCant
'=== Fin VOS20110606 ===


ConnBd.Close 
'// Fin del programa... 

if Err.number <> 0 then
	Response.Write "Existe un problema al generar el certificado."
	Response.End 
end if



%>