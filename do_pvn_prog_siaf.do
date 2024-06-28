clear all
set more off

glo data "D:\Usuarios\sanalisisopp6\Documents\Data\"

glo fileSIAF "ReporteGasto_pvn_030624_0900.xls"	// <----- MODIFICA
glo fecha 					  "030624_0900"		// <----- MODIFICA

glo fileProgMarzoInv "PVN PROG II TRIMESTRE_2024_F_19 Actualizado al 21.03.24 (mail Gisela 270324).xlsx"
glo fileProgMarzoGCo "ESPECIFICAS DE GASTO GASTO CORRIENTE 01.03.24 ENVIO (mail Gisela 270324).XLSX"

* =======================================

// import excel using "${data}\CLASIFICADORES.xlsx", clear first
// save "${data}\tmp_00.dta", replace

import excel using "${data}\CLASIFICA_INVERSIONES.xlsx", clear first
save "${data}\tmp_01.dta", replace

import excel using "${data}\Programación 2024\\${fileProgMarzoInv}", clear sheet(F19_36036) first
drop if ENTIDAD==""
keep CODIGO_PROYECTO PROYECCION_DEVENGADO_MARZO PROYECCION_DEVENGADO_ABRIL PROYECCION_DEVENGADO_MAYO PROYECCION_DEVENGADO_JUNIO PROYECCION_DEVENGADO_JULIO PROYECCION_DEVENGADO_AGOSTO PROYECCION_DEVENGADO_SETIEMBRE PROYECCION_DEVENGADO_OCTUBRE PROYECCION_DEVENGADO_NOVIEMBRE PROYECCION_DEVENGADO_DICIEMBRE
ren CODIGO_PROYECTO CUI
ren PROYECCION_DEVENGADO_* progMEF_II_*
gen nro=1
save "${data}\tmp_02.dta", replace

import excel using "${data}\\${fileSIAF}", clear first sheet(SheetGasto)
keep sec_func departamento_meta
duplicates drop
save "${data}\meta_departamento.dta", replace

import excel using "${data}\Programación 2024\\${fileProgMarzoGCo}", clear sheet(Data) first
keep producto_proyecto activ_obra_accinv MetaPVN EspecificaPVN ENERO FEBRERO MARZO ABRIL MAYO JUNIO JULIO AGOSTO SETIEMBRE OCTUBRE NOVIEMBRE DICIEMBRE
replace producto_proyecto=substr(producto_proyecto,1,8)+substr(producto_proyecto,10,10000)
replace activ_obra_accinv=substr(activ_obra_accinv,1,8)+substr(activ_obra_accinv,10,10000)
gen RUBRO_INTERVENCION = "ATENCIÓN DE EMERGENCIAS" if strpos(activ_obra_accinv,"5001437")==1
replace RUBRO_INTERVENCION = "GASTOS POR FUNCIONAMIENTO DE PEAJES Y GESTIÓN" if inlist(substr(activ_obra_accinv,1,7),"5000276","5003240")
replace RUBRO_INTERVENCION = "MANTENIMIENTO RVN" if inlist(substr(activ_obra_accinv,1,7),"5001433","5001434","5001435","5001436")
gen sec_func=substr(MetaPVN,1,4)
destring sec_func, replace
gen clasif=substr(EspecificaPVN,1,15)
replace clasif=subinstr(clasif,".","",.)
replace clasif=subinstr(clasif," ","",.)
gen generica="1.PERSONAL Y OBLIGACIONES SOCIALES" if substr(clasif,1,2)=="21"
replace generica="2.PENSIONES Y OTRAS PRESTACIONES SOCIALES" if substr(clasif,1,2)=="22"
replace generica="3.BIENES Y SERVICIOS" if substr(clasif,1,2)=="23"
replace generica="4.DONACIONES Y TRANSFERENCIAS" if substr(clasif,1,2)=="24"
replace generica="5.OTROS GASTOS" if substr(clasif,1,2)=="25"
replace generica="6.ADQUISICION DE ACTIVOS NO FINANCIEROS" if substr(clasif,1,2)=="26"
gen categoria_gasto="5.GASTOS CORRIENTES" if inlist(substr(clasif,1,2),"21","22","23","24","25")
replace categoria_gasto="6.GASTOS DE CAPITAL" if substr(clasif,1,2)=="26"
destring clasif, replace
merge m:1 sec_func using "${data}\meta_departamento.dta", nogen keep(1 3)
// duplicates r sec_func clasif
egen double x=rowtotal(ENERO FEBRERO MARZO ABRIL MAYO JUNIO JULIO AGOSTO SETIEMBRE OCTUBRE NOVIEMBRE DICIEMBRE)
drop if x==0
collapse (sum) ENERO FEBRERO MARZO ABRIL MAYO JUNIO JULIO AGOSTO SETIEMBRE OCTUBRE NOVIEMBRE DICIEMBRE, by(producto_proyecto RUBRO_INTERVENCION generica categoria_gasto departamento_meta)
gen nro=1
save "${data}\tmp_progGCo.dta", replace

import excel using "${data}\\${fileSIAF}", clear first sheet(SheetGasto)
drop if mto_pia==0 & mto_pim==0
gen RUBRO_INTERVENCION = "ATENCIÓN DE EMERGENCIAS" if strpos(activ_obra_accinv,"5001437")==1
replace RUBRO_INTERVENCION = "GASTOS POR FUNCIONAMIENTO DE PEAJES Y GESTIÓN" if inlist(substr(activ_obra_accinv,1,7),"5000276","5003240")
replace RUBRO_INTERVENCION = "MANTENIMIENTO RVN" if inlist(substr(activ_obra_accinv,1,7),"5001433","5001434","5001435","5001436")
// foreach x of varlist generica subgenerica subgenerica_det especifica especifica_det {
// 	gen _`x'=substr(`x',1,2)
// 	destring _`x', replace
// 	tostring _`x', replace
// }
// gen clasif="2"+_generica+_subgenerica+_subgenerica_det+_especifica+_especifica_det
// destring clasif, replace
replace departamento_meta="" if tipo_prod_proy=="3.PRODUCTO"
collapse (sum) mto_pia-mto_devenga_12, by(tipo_prod_proy producto_proyecto RUBRO_INTERVENCION departamento_meta categoria_gasto generica)
bys producto_proyecto RUBRO_INTERVENCION generica categoria_gasto: gen nro=_n
merge 1:1 producto_proyecto RUBRO_INTERVENCION generica categoria_gasto departamento_meta nro using "${data}\tmp_progGCo.dta"

// br if _m==2
gen CUI = substr(producto_proyecto,1,7)
destring CUI, replace
*duplicates r CUI if tipo_prod_proy=="2.PROYECTO"
duplicates tag CUI if tipo_prod_proy=="2.PROYECTO", gen(dup01)
*br if dup01>0 & dup01<.
gen departamento_meta_v2 = "99.MULTIDEPARTAMENTAL" if dup01>0 & dup01<. & substr(producto_proyecto,1,1)=="2"
replace departamento_meta_v2 = departamento_meta if departamento_meta_v2 == ""
replace departamento_meta_v2 = "-" if substr(producto_proyecto,1,1)=="3"
collapse (sum) mto_pia-mto_devenga_12 ENERO-DICIEMBRE, by(tipo_prod_proy CUI producto_proyecto RUBRO_INTERVENCION departamento_meta_v2 categoria_gasto generica)

ren (ENERO-DICIEMBRE) (progMEF_II_ENERO progMEF_II_FEBRERO progMEF_II_MARZO progMEF_II_ABRIL progMEF_II_MAYO progMEF_II_JUNIO progMEF_II_JULIO progMEF_II_AGOSTO progMEF_II_SETIEMBRE progMEF_II_OCTUBRE progMEF_II_NOVIEMBRE progMEF_II_DICIEMBRE)

bys CUI (generica): gen nro = _N - _n + 1
merge 1:1 CUI nro using "${data}\tmp_02.dta", update replace nogen
merge m:1 CUI using "${data}\tmp_01.dta", update nogen keep(master match match_update match_conflict)
drop nro

replace tipo_prod_proy="2.PROYECTO" if tipo_prod_proy=="" & inrange(CUI,2000000,2999999)
replace tipo_prod_proy="3.PRODUCTO" if tipo_prod_proy=="" & inrange(CUI,3000000,3999999)
replace categoria_gasto="6.GASTOS DE CAPITAL" if categoria_gasto=="" & inrange(CUI,2000000,2999999)
replace generica="6.ADQUISICION DE ACTIVOS NO FINANCIEROS" if generica=="" & inrange(CUI,2000000,2999999)

replace departamento_meta_v2="14.LAMBAYEQUE"	if CUI==2041965 & departamento_meta_v2==""
replace departamento_meta_v2="20.PIURA" 		if CUI==2043363 & departamento_meta_v2==""
replace departamento_meta_v2="15.LIMA" 			if CUI==2062374 & departamento_meta_v2==""
replace departamento_meta_v2="09.HUANCAVELICA" 	if CUI==2089761 & departamento_meta_v2==""
replace departamento_meta_v2="09.HUANCAVELICA" 	if CUI==2159402 & departamento_meta_v2==""
replace departamento_meta_v2="05.AYACUCHO" 		if CUI==2252619 & departamento_meta_v2==""
replace departamento_meta_v2="99.MULTIDEPARTAMENTAL" if CUI==2313265 & departamento_meta_v2==""
replace departamento_meta_v2="21.PUNO" 			if CUI==2341241 & departamento_meta_v2==""
replace departamento_meta_v2="17.MADRE DE DIOS" if CUI==2392242 & departamento_meta_v2==""
replace departamento_meta_v2="09.HUANCAVELICA" 	if CUI==2451550 & departamento_meta_v2==""
replace departamento_meta_v2="18.MOQUEGUA" 		if CUI==2494314 & departamento_meta_v2==""
replace departamento_meta_v2="02.ANCASH" 		if CUI==2504305 & departamento_meta_v2==""
replace departamento_meta_v2="06.CAJAMARCA" 	if CUI==2520925 & departamento_meta_v2==""
replace departamento_meta_v2="02.ANCASH" 		if CUI==2524785 & departamento_meta_v2==""
replace departamento_meta_v2="13.LA LIBERTAD" 	if CUI==2543519 & departamento_meta_v2==""
replace departamento_meta_v2="11.ICA" 			if CUI==2566903 & departamento_meta_v2==""
replace departamento_meta_v2="04.AREQUIPA" 		if CUI==2601621 & departamento_meta_v2==""
replace departamento_meta_v2="08.CUSCO" 		if CUI==2619648 & departamento_meta_v2==""
replace departamento_meta_v2="02.ANCASH" 		if CUI==2632762 & departamento_meta_v2==""

replace producto_proyecto="2041965.MEJORAMIENTO DE LA CARRETERA OYOTUN - LAS DELICIAS (KM. 0 + 000 - KM. 4+ 042 ) Y REUBICACION DE PUENTE LAS DELICIAS, DISTRITO DE OYOTUN" if CUI==2041965 & producto_proyecto==""
replace producto_proyecto="2043363.MEJORAMIENTO Y REHABILITACION DE LA CARRETERA SULLANA - EL ALAMOR DEL EJE VIAL N° 2 DE INTERCONEXION VIAL PERU - ECUADOR" if CUI==2043363 & producto_proyecto==""
replace producto_proyecto="2062374.REHABILITACION Y MEJORAMIENTO DE LA CARRETERA CAÑETE - LUNAHUANA" if CUI==2062374 & producto_proyecto==""
replace producto_proyecto="2089761.REHABILITACION Y MEJORAMIENTO DE LA CARRETERA IMPERIAL-MAYOCC-AYACUCHO TRAMO MAYOCC-HUANTA" if CUI==2089761 & producto_proyecto==""
replace producto_proyecto="2159402.REHABILITACION Y MEJORAMIENTO DE LA CARRETERA IMPERIAL PAMPAS" if CUI==2159402 & producto_proyecto==""
replace producto_proyecto="2252619.MEJORAMIENTO DE LA CARRETERA EMP. PE - 28B (SAN FRANCISCO) - SANTA ROSA - PALMAPAMPA - SAN ANTONIO - CHIQUINTIRCA 5 DISTRITOS DE LA PROVINCIA DE LA MAR - DEPARTAMENTO DE AYACUCHO" if CUI==2252619 & producto_proyecto==""
replace producto_proyecto="2313265.MEJORAMIENTO DE LA CARRETERA CUBANTIA - ANAPATI - YOYATO - VALLE ESMERALDA - PICHARI - EMP. PE-28B (KIMBIRI) LA PROVINCIA DE LA CONVENCION DEL DEPARTAMENTO DE CUSCO Y LA PROVINCIA DE SATIPO DEL DEPARTAMENTO DE JUNIN" if CUI==2313265 & producto_proyecto==""
replace producto_proyecto="2341241.MEJORAMIENTO DE LAS CARRETERAS DE PRO REGIÓN PUNO, POR NIVELES DE SERVICIO" if CUI==2341241 & producto_proyecto==""
replace producto_proyecto="2392242.MEJORAMIENTO DEL SERVICIO DE TRANSITABILIDAD VIAL INTERURBANA EN CARRETERA EMP. PE - 30C SAN LORENZO - ALTO PERU DE CENTRO POBLADO SAN LORENZO DISTRITO DE TAHUAMANU DE LA PROVINCIA DE TAHUAMANU DEL DEPARTAMENTO DE MADRE DE DIOS" if CUI==2392242 & producto_proyecto==""
replace producto_proyecto="2451550.MEJORAMIENTO DE LA CARRETERA IZCUCHACA - HUANTA, TRAMO: IZCUCHACA - MAYOCC DISTRITO DE IZCUCHACA - PROVINCIA DE HUANCAVELICA - DEPARTAMENTO DE HUANCAVELICA" if CUI==2451550 & producto_proyecto==""
replace producto_proyecto="2494314.CREACION DE LA VÍA DE EVITAMIENTO CHEN CHEN - MAMA ROSA EN LOS DISTRITOS DE MOQUEGUA Y SAMEGUA DE LA PROVINCIA DE MARISCAL NIETO - DEPARTAMENTO DE MOQUEGUA" if CUI==2494314 & producto_proyecto==""
replace producto_proyecto="2504305.MEJORAMIENTO DE LA CARRETERA HUALLANCA - DV. ANTAMINA (INCLUYE VIA DE EVITAMIENTO) DISTRITO DE HUALLANCA - PROVINCIA DE BOLOGNESI - DEPARTAMENTO DE ANCASH" if CUI==2504305 & producto_proyecto==""
replace producto_proyecto="2520925.MEJORAMIENTO DE LA CARRETERA DV. CELENDÍN - ABRA GELIG - PUENTE CHACANTO (DV. BALSAS) EN LOS DISTRITOS DE CELENDIN, JOSE GALVEZ Y UTCO DE LA PROVINCIA DE CELENDIN - DEPARTAMENTO DE CAJAMARCA" if CUI==2520925 & producto_proyecto==""
replace producto_proyecto="2524785.MEJORAMIENTO DE LA CARRETERA SANTA - HUALLANCA EN LOS DISTRITOS DE SANTA, CHIMBOTE Y MACATE DE LA PROVINCIA DE SANTA - DEPARTAMENTO DE ANCASH" if CUI==2524785 & producto_proyecto==""
replace producto_proyecto="2543519.MEJORAMIENTO DE LA CARRETERA EMP. ACCESO NUEVO PUENTE PALLAR - PUENTE CHAGUAL EN LOS DISTRITOS DE CHUGAY Y COCHORCO DE LA PROVINCIA DE SANCHEZ CARRION - DEPARTAMENTO DE LA LIBERTAD" if CUI==2543519 & producto_proyecto==""
replace producto_proyecto="2566903.MEJORAMIENTO DEL ACCESO AL AEROPUERTO DE PISCO EN LOS DISTRITOS DE SAN ANDRES Y PISCO DE LA PROVINCIA DE PISCO - DEPARTAMENTO DE ICA" if CUI==2566903 & producto_proyecto==""
replace producto_proyecto="2601621.MEJORAMIENTO DEL SERVICIO DE TRANSITABILIDAD VIAL INTERURBANA EN LA CARRETERA EMP. PE-1S-VENTILLATA-DV. BUENOS AIRES-EMP. PE-1SD DISTRITO DE COCACHACRA DE LA PROVINCIA DE ISLAY DEL DEPARTAMENTO DE AREQUIPA" if CUI==2601621 & producto_proyecto==""
replace producto_proyecto="2619648.CREACION DEL SERVICIO DE TRANSITABILIDAD VIAL INTERURBANA EN VIA DE EVITAMIENTO DE CUSCO DISTRITO DE SANTIAGO DE LA PROVINCIA DE CUSCO DEL DEPARTAMENTO DE CUSCO" if CUI==2619648 & producto_proyecto==""
replace producto_proyecto="2632762.CONSTRUCCION DE PUENTE; EN EL(LA) RUTA NACIONAL PE-3N DISTRITO DE AQUIA, PROVINCIA BOLOGNESI, DEPARTAMENTO ANCASH" if CUI==2632762 & producto_proyecto==""

replace RUBRO_INTERVENCION="CARRETERAS" if CUI==2234987 & RUBRO_INTERVENCION==""
replace RUBRO_INTERVENCION="PUENTES" if CUI==2459360 & RUBRO_INTERVENCION==""
replace RUBRO_INTERVENCION="PUENTES" if CUI==2469852 & RUBRO_INTERVENCION==""

replace RUBRO_INTERVENCION="CARRETERAS" if CUI==2002604 & RUBRO_INTERVENCION==""
replace RUBRO_INTERVENCION="PUENTES" if CUI==2109832 & RUBRO_INTERVENCION==""

gen CP=""
replace CP="CARTERA PRIORIZADA" if inlist(CUI,2057906,2078363,2088774,2177209,2234355,2234987,2253121,2282760,2290818,2328807,2389634,2392435, /* 2436163, */ 2459360,2469852,2473163,2473375,2623129)
replace CP="CARTERA PVN" if CP=="" & tipo_prod_proy=="2.PROYECTO"
replace CP="ACTIVIDADES" if CP=="" & tipo_prod_proy=="3.PRODUCTO"

gen RUBRO_INTERVENCION_V2=RUBRO_INTERVENCION
replace RUBRO_INTERVENCION_V2=producto_proyecto if CP=="CARTERA PRIORIZADA"

// ABREVIANDO NOMBRES PARA LA CP
replace RUBRO_INTERVENCION_V2="2057906.CARRETERA LIMA-CANTA-LA VIUDA-UNISH" 							if CUI==2057906
replace RUBRO_INTERVENCION_V2="2078363.CARRETERA CHUQUICARA-PTE QUIROZ-TAUCA-CABANA-HUANDOVAL-PALLASCA" if CUI==2078363
replace RUBRO_INTERVENCION_V2="2088774.CARRETERA HUAURA-SAYAN-CHURIN" 									if CUI==2088774
replace RUBRO_INTERVENCION_V2="2177209.CARRETERA HUANUCO-CONOCOCHA, SEC: HCO-LA UNION-HUALLANCA PE-3N" 	if CUI==2177209
replace RUBRO_INTERVENCION_V2="2234355.CARRETERA OYON-AMBO" 											if CUI==2234355
replace RUBRO_INTERVENCION_V2="2234987.REHABILITACION Y MEJORAMIENTO DE LA CARRETERA HUALLANCA - CARAZ" if CUI==2234987
replace RUBRO_INTERVENCION_V2="2253121.CARRETERA CUSCO-CHINCHEROS-URUBAMBA" 							if CUI==2253121
replace RUBRO_INTERVENCION_V2="2282760.CARRETERA S. MARIA-S. TERESA-PTE HIDRO. MACHU PICCHU" if CUI==2282760
replace RUBRO_INTERVENCION_V2="2290818.CARRETERA CHECCA-MAZOCRUZ" 										if CUI==2290818
replace RUBRO_INTERVENCION_V2="2328807.PTE SANTA ROSA" 													if CUI==2328807
replace RUBRO_INTERVENCION_V2="2389634.PTE CARRASQUILLO" 												if CUI==2389634
replace RUBRO_INTERVENCION_V2="2392435.PTE TRAMO TAMBO GRANDE-CHULUCANAS-MORROPON" 						if CUI==2392435
replace RUBRO_INTERVENCION_V2="2459360.PTE TRAMO: CHICLAYO-CHONGOYAPE-PTE CUMBIL" 						if CUI==2459360
replace RUBRO_INTERVENCION_V2="2469852.PTE SAUSACOCHA-PALLAR-CALEMAR" 									if CUI==2469852
replace RUBRO_INTERVENCION_V2="2473163.CARRETERA BOCA DEL RIO" 											if CUI==2473163
replace RUBRO_INTERVENCION_V2="2473375.VIA EXPRESA SANTA ROSA" 											if CUI==2473375
replace RUBRO_INTERVENCION_V2="2623129.NUEVA CARRETERA CENTRAL" 										if CUI==2623129

replace ET = "-" if tipo_prod_proy=="3.PRODUCTO"

foreach x of varlist tipo_prod_proy producto_proyecto categoria_gasto generica RUBRO_INTERVENCION departamento_meta_v2 {
	fre `x'
	return list
	assert `r(N_missing)'==0
}

// fre ET
// return list
// assert `r(N_missing)'==0

egen double tmp_=rowtotal(progMEF_II_*)
drop if mto_pia==0 & mto_pim==0 & tmp_==0
drop tmp_

recode mto_pia-progMEF_II_DICIEMBRE (.=0)
order tipo_prod_proy CUI producto_proyecto ET categoria_gasto generica departamento_meta_v2 RUBRO_INTERVENCION RUBRO_INTERVENCION_V2 CP
drop mto_at_comp*
egen double t_mto_devenga = rowtotal(mto_devenga_*)
order t_mto_devenga, after(mto_devenga_12)

copy "${data}\PROG_TRIM_MEF_SIAF_OL_000000_0000 (ABRIL).xlsx" "${data}\PROG_TRIM_MEF_SIAF_OL_${fecha}.xlsx", replace public

export excel using "${data}\PROG_TRIM_MEF_SIAF_OL_${fecha}.xlsx", first(var) sheet(BD, modify) cell(A1)

cap erase "${data}\tmp_00.dta"
cap erase "${data}\tmp_01.dta"
cap erase "${data}\tmp_02.dta"
cap erase "${data}\tmp_progGCo.dta"
cap erase "${data}\meta_departamento.dta"