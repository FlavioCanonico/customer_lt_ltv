###librerie
library(survival)
library(randomForestSRC)
library(ggRandomForests)
library(ggplot2)
library(RJDBC)
library(DBI)
library(varhandle)
library(reshape)
library(plyr)
library(reshape2)
library(dplyr)

# viene richiamata la funzione custom per l'import dei dati da SQL server
# (non inserita per intero perché contenente i dati di accesso al database)
source("C:/Users/Flavio/Desktop/functions/importDatiFromSQL.R")

###Data Pre-processing
gc()
options(java.parameters ="-Xmx12192m")
PIB <- importDatiFromSql(sqlText = "select * from PIB where mesi_dalla_prima_attivazione <= 42")

# si definiscono le variabili categoriali come factor
PIB = PIB %>%
  mutate(TipoCliente = as.factor(TipoCliente)
               ,AreaNielsenCliente = as.factor(AreaNielsenCliente)
               ,primamodalita = as.factor(primamodalita)
               ,ultimamodalita = as.factor(ultimamodalita)
               ,tiposped = as.factor(tiposped))

#si definisce la variabile status, che sarà 1 se si verifica l'evento, cioé il churn
PIB <- PIB %>% mutate(status = ifelse(PIB$clienteattivo==0, 1, 0))

# per il ricavo marginale, viene fatta la media mensile sia per il ricavo sui
# contratti prodotto integrato che eventuali prodotto sciolto. Dato che si ha il ricavo solo per 13 mesi:
vett = PIB %>% mutate(vett = case_when(mesicliente >= 13 ~ 13,
                                       mesicliente == 0 ~ 1,
                                       TRUE ~ mesicliente)) %>%
  mutate(ricavomarginale_PI_mean = ricavomarginale_tot13mesi/vett,
         ricavomarginale_sciolto = ricavomarginale_sciolto/mesicliente)

# si sommano i ricavimarginali fatti sulle utenze Prodotto Integrato e Prodotto Sciolto
PIB <- PIB %>%
  mutate(ricavomarginale_mean = ifelse(is.na(ricavomarginale_PI_mean),0,ricavomarginale_PI_mean) +
        ifelse(is.na(ricavomarginale_sciolto_mean),0,ricavomarginale_sciolto_mean)) %>%
  # poiché il ricavo per quelli che hanno 0 non é realmente 0 ma é NA, si riassegna il valore NA
  mutate(ricavomarginale_mean = ifelse(ricavomarginale_mean == 0, NA,ricavomarginale_mean)) %>%
  # Si costruisce la variabile CanaliDigitali, data dalla somma degli accessi ai canali digitali
  mutate(CanaliDigitali = chat + selfcare + chatbot + telegram) %>%
  #Si costruisce la variabile che indica se un clt PI ha o ha avuto anche un contratto PS
  mutate(flag_sciolto = ifelse(PIB$Sciolto > 0,1,0))

# Si fa la media mesile di casi aperti per ogni tipo di caso
names_casi_mean <- c("Campagna_Autolettura"
                     ,"Campagna_Credito"
                     ,"Campagna_CrossSelling"
                     ,"Campagna_Promo_Offerte"
                     ,"Campagna_Recall"
                     ,"Campagna_Rimodulazione"
                     ,"Campagna_Spedizione"
                     ,"Campagna_Tecnico"
                     ,"info_Attivazione"
                     ,"info_Canali_digitali"
                     ,"info_ContoRelax"
                     ,"info_Contratto"
                     ,"info_Credito"
                     ,"info_Disattivazione"
                     ,"info_Fattura"
                     ,"info_Modulistica"
                     ,"info_Pagamento"
                     ,"info_Promo_Offerte"
                     ,"info_Recapito_consulente"
                     ,"info_Rimodulazione"
                     ,"info_Sconto_Rimborso"
                     ,"info_Spedizione"
                     ,"info_Tecnico"
                     ,"info_Voltura"
                     ,"Invio_Credito"
                     ,"invio_Contratto"
                     ,"invio_Fattura"
                     ,"invio_Modulistica"
                     ,"Reclamo_Attivazione"
                     ,"Reclamo_Credito"
                     ,"Reclamo_Fattura"
                     ,"Reclamo_Guasto"
                     ,"Reclamo_legale"
                     ,"Reclamo_Spedizione"
                     ,"Variazione_Agevolazione"
                     ,"Variazione_Anagrafica"
                     ,"Variazione_Autolettura"
                     ,"Variazione_Credito"
                     ,"Variazione_Fattura"
                     ,"Variazione_Pagamento"
                     ,"Variazione_Rimodulazione"
                     ,"Variazione_Sconto_Rimborso"
                     ,"Variazione_Tecnico")

PIB[,names_casi_mean] <- (PIB[,names_casi_mean] / PIB[,"mesicliente"])

#Prima di standardizzare viene fatta una copia del dataset non standardizzato
pib_unscaled <- PIB

names_da_std <- c(names_casi_mean
                  ,"n_utenze"
                  ,"FattMedia"
                  ,"etareferente"
                  ,"CanaliDigitali"
                  ,"mobile")

PIB[,names_da_std] <- scale(PIB[,names_da_std])
# apply(PIB, 2, function(x) any(is.na(x))) # per capire quali colonne contengono NAs


