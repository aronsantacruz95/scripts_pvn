clear all
set more off

glo xfile "hoja_20240627_110809.xls"

glo inpt "C:\Melissa30\WorkBooks\"
glo otpt "D:\Usuarios\sanalisisopp6\Documents\Data\"

import excel using "${inpt}\\${xfile}", clear

gen ANIO=B if substr(B,1,2)=="20"
gen FF=B+". "+C if inlist(B,"1","2","3","4","5")
gen CUI=subinstr(C,".","",.) if inlist(substr(C,1,1),"2","3")
gen AAO=subinstr(D,".","",.) if inlist(substr(D,1,1),"4","5","6")
gen Meta=E if length(E)==4
gen Clasif=F if substr(F,1,1)=="2"
gen CER=G if substr(G,1,4)=="CER-"
replace CER="CER-XXXXX" if CER=="" & I!="" & J!="" & substr(F,1,1)=="2"
gen Glosa=H if substr(CER,1,4)=="CER-"

gen PIA=I if substr(CER,1,4)=="CER-"
gen PIM=J if substr(CER,1,4)=="CER-"
gen Cert =K if substr(CER,1,4)=="CER-" & CER!="CER-XXXXX"
gen CompA=L if substr(CER,1,4)=="CER-" & CER!="CER-XXXXX"
gen CompM=M if substr(CER,1,4)=="CER-" & CER!="CER-XXXXX"
gen Dev=N if substr(CER,1,4)=="CER-" & CER!="CER-XXXXX"

keep ANIO FF CUI AAO Meta Clasif CER Glosa PIA PIM Cert CompA CompM Dev

foreach x of varlist ANIO FF CUI AAO Meta Clasif {
	replace `x'=`x'[_n-1] if `x'==""
}
drop if CER==""

destring PIA PIM Cert Comp* Dev, replace
recode PIA PIM Cert Comp* Dev (.=0)

destring CUI, replace

* Corrección de ccp negativo
replace Cert=Cert+22000 if Cert<0 & Meta=="0308" & Clasif=="2.3.2.9.1.1" & CER=="CER-00120"

* Última limpieza
drop if PIA==0 & PIM==0 & Cert==0 & CompA==0 & CompM==0

gen double CertNoCompA=Cert-CompA
order CertNoCompA, after(CompA)
gen double CertNoCompM=Cert-CompM
order CertNoCompM, after(CompM)

local dhm=substr("${xfile}",8,11)

// local xfile_=substr("${xfile}",1,20)
// save "${otpt}\\tmp\tmp_`xfile_'.dta", replace

di "`dhm'"
copy "${otpt}\\ejec_cert_PLANTILLA.xlsx" "${otpt}\\ejec_cert_`dhm'.xlsx", replace public
export excel using "${otpt}\\ejec_cert_`dhm'.xlsx", first(var) sheet(BD, modify) cell(A2) keepcellfmt

putexcel set "${otpt}\\ejec_cert_`dhm'.xlsx", sheet(BD) modify
putexcel I1 = "=SUBTOTALES(9;)"
putexcel J1 = " "
putexcel K1 = " "
putexcel L1 = " "
putexcel M1 = " "
putexcel N1 = " "
putexcel O1 = " "
putexcel P1 = " "