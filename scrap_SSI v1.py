import time
import pandas as pd
import numpy as np
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from bs4 import BeautifulSoup
from datetime import datetime

# para contabilizar tiempo de demora
start = time.time() # inicia toma de tiempo

current_datetime = datetime.now().strftime("%d%m%Y_%H%M")

# ----------------- MODIFICABLE
#
# PARTES
#parte = '_dppi'
#parte = '_EMERGw'
parte = '_ssi2705'

# ruta de entrada
PATH_INPUT = 'D:/Usuarios/sanalisisopp6/Documents/Data/'
# ruta de salida
PATH_OUTPUT = 'D:/Usuarios/sanalisisopp6/Documents/Data/'
# nombre del archivo output
FILE_OUTPUT = 'infoSSI_{}{}.xlsx'.format(current_datetime,parte)
# nombre del archivo con CUIs
FILE_CUI = 'cuis{}.xlsx'.format(parte)
# tiempo que deja cargar cada página
timesleep=2
#
# ----------------- MODIFICABLE

service = Service(executable_path="D:/Usuarios/sanalisisopp6/Desktop/instalaPython/chromedriver.exe")
options = webdriver.ChromeOptions()
options.add_argument("--start-maximized")
driver = webdriver.Chrome(service=service, options=options)
#driver = webdriver.Chrome(chrome_options=options)
BBDD = pd.DataFrame()
BBDDca = pd.DataFrame()

#Ncui = "2154492"

## INICIA BUCLE

file_xlsx = PATH_INPUT + FILE_CUI # ruta y nombre de listado id_entidad
df_xlsx = pd.read_excel(file_xlsx) # lee el excel con el listado id_entidad
cuis = df_xlsx['CUIS'].tolist() # convierte la columna 'id_entidad' en una lista

for Ncui in cuis:
    
    print(Ncui)

    # SSI
    # ====
    
    _infoSSI = np.array([[0]])
    infoSSI = pd.DataFrame(_infoSSI)
    
    web1 = "https://ofi5.mef.gob.pe/ssi/Ssi/Index?codigo="
    web2 = "&tipo=2"
    web = web1+str(Ncui)+web2
    
    driver.get(web)
    time.sleep(timesleep)
    
    pageHTML = driver.page_source
    soup = BeautifulSoup(pageHTML, 'lxml')
    
    nominv = ''
    nominv = soup.find(id="td_nominv").get_text()
    i = 0
    if (nominv==''):
        while (nominv=='') and (i < 20):
            driver.get(web)
            time.sleep(i)
            pageHTML = driver.page_source
            soup = BeautifulSoup(pageHTML, 'lxml')
            nominv = ''
            nominv = soup.find(id="td_nominv").get_text()
            i += 1
    infoSSI['nominv'] = nominv
    
    codsnip = ''
    codsnip = soup.find(id="td_snip").get_text()
    infoSSI['codsnip'] = codsnip
    
    # nominv = ''
    # nominv = soup.find(id="td_nominv").get_text()
    # infoSSI['nominv'] = nominv
    
    opmi = ''
    opmi = soup.find(id="td_opmi").get_text()
    infoSSI['opmi'] = opmi
    
    fecharegistro = ''
    fecharegistro = soup.find(id="td_fecreg").get_text()
    infoSSI['fecharegistro'] = fecharegistro
    
    estadoinv = ''
    estadoinv = soup.find(id="td_estcu").get_text()
    infoSSI['estadoinv'] = estadoinv
    
    uf = ''
    uf = soup.find(id="td_uf").get_text()
    infoSSI['uf'] = uf
    
    uei = ''
    uei = soup.find(id="td_uei").get_text()
    infoSSI['uei'] = uei
    
    situacionviab = ''
    situacionviab = soup.find(id="td_situinv").get_text()
    infoSSI['situacionviab'] = situacionviab
    
    fechaviab = ''
    fechaviab = soup.find(id="td_fecviab").get_text()
    infoSSI['fechaviab'] = fechaviab
    
    decretoemerg = ''
    decretoemerg = soup.find(id="td_emergds").get_text()
    infoSSI['decretoemerg'] = decretoemerg
    
    montoviable = ''
    montoviable = soup.find(id="td_mtoviab").get_text()
    montoviable = montoviable.replace(',','')
    infoSSI['montoviable'] = montoviable
    
    cadfun = ''
    cadfun = soup.find(id="td_cadfun").get_text()
    infoSSI['cadfun'] = cadfun
    
    beneficiarios = ''
    beneficiarios = soup.find(id="td_benif").get_text()
    beneficiarios = beneficiarios.replace(',','')
    infoSSI['beneficiarios'] = beneficiarios
    
    et = ''
    et = soup.find(id="td_indet").get_text()
    et = et.strip()
    infoSSI['et'] = et
    
    registroseg = ''
    registroseg = soup.find(id="td_indseg").get_text()
    registroseg = registroseg.strip()
    infoSSI['registroseg'] = registroseg
    
    feciniejec = ''
    feciniejec = soup.find(id="fec_iniejec").get_text()
    infoSSI['feciniejec'] = feciniejec
    
    fecfinejec = ''
    fecfinejec = soup.find(id="fec_finejec").get_text()
    infoSSI['fecfinejec'] = fecfinejec
    
    cia = ''
    cia = soup.find(id="val_cta").get_text()
    cia = cia.replace(',','')
    infoSSI['cia'] = cia
    
    concurr = ''
    concurr = soup.find(id="td_concurr").get_text()
    concurr = concurr.replace(',','')
    infoSSI['concurr'] = concurr
    
    laudo = ''
    laudo = soup.find(id="td_laudo").get_text()
    laudo = laudo.replace(',','')
    infoSSI['laudo'] = laudo
    
    cfianza = ''
    cfianza = soup.find(id="td_carfza").get_text()
    cfianza = cfianza.replace(',','')
    infoSSI['cfianza'] = cfianza
    
    montototal = ''
    montototal = soup.find(id="td_mtototal").get_text()
    montototal = montototal.replace(',','')
    infoSSI['montototal'] = montototal
    
    infoSSI['cui'] = Ncui
    
    PMI = ''
    PMI = soup.find(id="td_indpmi").get_text()
    infoSSI['PMI'] = PMI
    
    nominv = ''
    nominv = soup.find(id="td_nominv").get_text()
    infoSSI['nominv'] = nominv
    
    registrocierre = ''
    registrocierre = soup.find(id="td_f9").get_text()
    registrocierre = registrocierre.strip()
    infoSSI['registrocierre'] = registrocierre
    
    devacum24 = ''
    devacum24 = soup.find(id="val_efin").get_text()
    devacum24 = devacum24.replace(',','')
    infoSSI['devacum24'] = devacum24
    
    dev24 = ''
    dev24 = soup.find(id="val_avan").get_text()
    dev24 = dev24.replace(',','')
    infoSSI['dev24'] = dev24
    
    pim24 = ''
    pim24 = soup.find(id="val_pim").get_text()
    pim24 = pim24.replace(',','')
    infoSSI['pim24'] = pim24
    
    situ = ''
    situ = soup.find(id="td_situinv").get_text()
    situ = situ.replace(',','')
    infoSSI['situ'] = situ
    
    tipoinv = ''
    tipoinv = soup.find(id="td_tipinv").get_text()
    infoSSI['tipoinv'] = tipoinv
    
    infoSSI.index = [Ncui]
    
    BBDD = pd.concat([BBDD, infoSSI], axis=0, sort=False)
    #BBDD = BBDD.append(infoF12BSSI)
    del infoSSI
    
BBDD = BBDD[['cui','nominv','opmi','uf','uei','cadfun','tipoinv','feciniejec','fecfinejec','situ','beneficiarios','et','registrocierre','montototal','devacum24','dev24','pim24']]
BBDD[['montototal','devacum24','dev24','pim24','beneficiarios']] = BBDD[['montototal','devacum24','dev24','pim24','beneficiarios']].apply(pd.to_numeric)
BBDD.to_excel('{}{}'.format(PATH_OUTPUT,FILE_OUTPUT),sheet_name='BD',index=False)

driver.close()

print("Ini: ", current_datetime)
print("Fin: ", datetime.now().strftime("%d%m%Y_%H%M"))

# para contabilizar tiempo de demora
end = time.time() # fin de toma de tiempo
nseconds = end-start # calcula tiempo (segundos)
nseconds=int(nseconds) # se pasa a enteros
print('Segundos transcurridos:',nseconds) # imprime segundos de demora