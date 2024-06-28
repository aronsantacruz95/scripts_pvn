clear all
set more off

glo inpt "C:\Melissa30\WorkBooks\"
glo otpt "D:\Usuarios\sanalisisopp6\Documents\Data\"

glo xfile "hoja_20240624_142655.xls"

import excel using "${inpt}\\${xfile}", clear cellra(B5) first

keep if inlist(C,"GC","GD","GG","GP")
ren (NroExpedExpediente C D E F) (EXP Fase Sec Corr CorrDesc)

gen ANIO="2024"

replace FteFin="1. RECURSOS ORDINARIOS" 						  if FteFin=="1"
replace FteFin="2. RECURSOS DIRECTAMENTE RECAUDADOS" 			  if FteFin=="2"
replace FteFin="3. RECURSOS POR OPERACIONES OFICIALES DE CREDITO" if FteFin=="3"
replace FteFin="4. DONACIONES Y TRANSFERENCIAS" 				  if FteFin=="4"
replace FteFin="5. RECURSOS DETERMINADOS" 						  if FteFin=="5"

replace PrdPry=subinstr(PrdPry,".","",.)

replace AAIO=subinstr(AAIO,".","",.)

ren (FteFin PrdPry AAIO EspD NroCertificación Comprometido Devengado) (FF CUI AAO Clasif CER CompM Dev)

destring CUI, replace

order ANIO FF CUI AAO Meta Clasif CER
destring Girado Pagado, replace

sort ANIO FF CUI AAO Meta Clasif CER EXP Sec Fase
order ANIO FF CUI AAO Meta Clasif CER EXP Fase Sec Corr CorrDesc
drop FechaDocB-Final

compress

local dhm=substr("${xfile}",8,11)
export excel using "${otpt}\\ejec_exp_`dhm'.xlsx", first(var) sheet(BD) replace