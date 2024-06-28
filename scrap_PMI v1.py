import time
import pandas as pd
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from datetime import datetime

# para contabilizar tiempo de demora
start = time.time() # inicia toma de tiempo

current_datetime = datetime.now().strftime("%d%m%Y_%H%M")
print("Current date & time : ", current_datetime)

# ----------------- MODIFICABLE
#
# sufijo
sufijo = '_listaPedidos'
# ruta de entrada
PATH_INPUT = 'D:/Usuarios/sanalisisopp6/Documents/Data/'
# ruta de salida
PATH_OUTPUT = 'D:/Usuarios/sanalisisopp6/Documents/Data/'
# nombre del archivo output
FILE_OUTPUT = 'infoPMI_{}{}.xlsx'.format(current_datetime,sufijo)
# nombre del archivo con CUIs
FILE_CUI = 'cuis{}.xlsx'.format(sufijo)
# tiempo que deja cargar cada página
timesleep=1
#
# ----------------- MODIFICABLE

service = Service(executable_path="D:/Usuarios/sanalisisopp6/Desktop/instalaPython/chromedriver.exe")
options = webdriver.ChromeOptions()
options.add_argument("--start-maximized")
driver = webdriver.Chrome(service=service, options=options)
#driver = webdriver.Chrome(chrome_options=options)

BBDD = pd.DataFrame()

#Ncui = "2154492"

## INICIA BUCLE

file_xlsx = PATH_INPUT + FILE_CUI # ruta y nombre de listado id_entidad
df_xlsx = pd.read_excel(file_xlsx) # lee el excel con el listado id_entidad
cuis = df_xlsx['CUIS'].tolist() # convierte la columna 'id_entidad' en una lista

for Ncui in cuis:

    # PMI
    # ====
    
    print(Ncui)
    
    web = "https://ofi5.mef.gob.pe/invierte/pmi/consultapmi?cui="+str(Ncui)
    driver.get(web)
    time.sleep(timesleep)
    pageHTML = driver.page_source
    #soup = BeautifulSoup(pageHTML, 'lxml')

    tablaPMI = pd.read_html(pageHTML, attrs={"id": "tblResultado"})
    dfPMI = tablaPMI[0]
    del tablaPMI
    dfPMI.columns = ['prioridad', 'prelacion', 'sector', '_opmi', 'nivgob', 'cui', 'codidea', 'tipoinv', 'nombreinv', 'costoactpmi', 'devacum2022pmi', 'pim2023', 'pmi2023', 'pmi2024', 'pmi2025', 'pmi2026']
    
    if (dfPMI['prioridad'].iat[0]=='Cargando...'):
        driver.get(web)
        time.sleep(timesleep)
        time.sleep(timesleep)
        pageHTML = driver.page_source
        tablaPMI = pd.read_html(pageHTML, attrs={"id": "tblResultado"})
        dfPMI = tablaPMI[0]
        del tablaPMI
        dfPMI.columns = ['prioridad', 'prelacion', 'sector', '_opmi', 'nivgob', 'cui', 'codidea', 'tipoinv', 'nombreinv', 'costoactpmi', 'devacum2022pmi', 'pim2023', 'pmi2023', 'pmi2024', 'pmi2025', 'pmi2026']

    if (dfPMI['prioridad'].iat[0]=='Cargando...'):
        driver.get(web)
        time.sleep(timesleep)
        time.sleep(timesleep)
        time.sleep(timesleep)
        pageHTML = driver.page_source
        tablaPMI = pd.read_html(pageHTML, attrs={"id": "tblResultado"})
        dfPMI = tablaPMI[0]
        del tablaPMI
        dfPMI.columns = ['prioridad', 'prelacion', 'sector', '_opmi', 'nivgob', 'cui', 'codidea', 'tipoinv', 'nombreinv', 'costoactpmi', 'devacum2022pmi', 'pim2023', 'pmi2023', 'pmi2024', 'pmi2025', 'pmi2026']
    
    dfPMI = dfPMI[['prioridad','prelacion','_opmi','costoactpmi','devacum2022pmi','pim2023','pmi2023','pmi2024','pmi2025','pmi2026']]
    dfPMI['cui'] = Ncui
    
    BBDD = pd.concat([BBDD, dfPMI], axis=0, sort=False)
    del dfPMI
    
    ## TERMINA BUCLE

# BBDD = BBDD[['cui','prioridad','prelacion','_opmi','costoactpmi','devacum2022pmi','pim2023','pmi2023','pmi2024','pmi2025','pmi2026']]
BBDD = BBDD[['cui','_opmi','pmi2024','pmi2025','pmi2026','pmi2027']]
BBDD.to_excel('{}{}'.format(PATH_OUTPUT,FILE_OUTPUT),sheet_name='BD',index=False)

driver.close()

print("Ini: ", current_datetime)
print("Fin: ", datetime.now().strftime("%d%m%Y_%H%M"))

# para contabilizar tiempo de demora
end = time.time() # fin de toma de tiempo
nseconds = end-start # calcula tiempo (segundos)
nseconds=int(nseconds) # se pasa a enteros
print('Segundos transcurridos:',nseconds) # imprime segundos de demora