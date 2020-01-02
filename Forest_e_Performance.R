### RANDOM SURVIVAL FOREST

rsf_pib <- rfsrc(formula = Surv(mesicliente,status)~
                       n_utenze
                     + flag_sciolto
                     + TipoCliente
                     + FattMedia
                     +AreaNielsenCliente
                     +etareferente
                     + primamodalita
                     + ultimamodalita
                     +CanaliDigitali
                     +mobile
                     
                     +Campagna_Autolettura
                     +Campagna_Credito
                     +Campagna_CrossSelling
                     
                     +Campagna_Promo_Offerte
                     +Campagna_Recall
                     +Campagna_Rimodulazione
                     +Campagna_Spedizione
                     +Campagna_Tecnico
                     
                     +info_Attivazione
                     +info_Canali_digitali
                     +info_ContoRelax
                     +info_Contratto
                     +info_Credito
                     +info_Disattivazione
                     +info_Fattura
                     +info_Modulistica
                     +info_Pagamento
                     +info_Promo_Offerte
                     +info_Recapito_consulente
                     +info_Rimodulazione
                     +info_Sconto_Rimborso
                     +info_Spedizione
                     +info_Tecnico
                     +info_Voltura
                     
                     +Invio_Credito
                     +invio_Contratto
                     +invio_Fattura
                     +invio_Modulistica
                     
                     +Reclamo_Attivazione
                     +Reclamo_Credito
                     +Reclamo_Fattura
                     +Reclamo_Guasto
                     +Reclamo_legale
                     +Reclamo_Spedizione
                     
                     +Variazione_Agevolazione
                     +Variazione_Anagrafica
                     +Variazione_Autolettura
                     +Variazione_Credito
                     +Variazione_Fattura
                     +Variazione_Pagamento
                     +Variazione_Rimodulazione
                     +Variazione_Sconto_Rimborso
                     +Variazione_Tecnico
                     +tiposped
                     
                     ,data=PIB, ntree=1000,forest=T, rf.cores=15,
                     na.action = "na.impute", seed = 123
                     ,importance=TRUE)


### ANALISI ESPLORATIVA VAR Y

# barplot status
png(file = "C:/Users/Flavio/Desktop/plots/status_barplot.png", height = 350, width = 450);
PIB %>% mutate(status=factor(ifelse(status==0,"not churned", "churned"))) %>%
  ggplot(aes(x=factor(status))) +
  geom_bar(width=0.6) +
  geom_text(aes(y = ((..count..)/sum(..count..)),
                label = scales::percent((..count..)/sum(..count..))), 
                stat = "count", vjust = -15, size=7) +
  xlab("status") +
  ylab("conteggio") +
  theme(axis.title.x = element_text(size = 16),
        axis.text.x = element_text(size = 14),
        axis.text.y = element_text(size = 14),
        axis.title.y = element_text(size = 16))
dev.off()

# density mesicliente
png(file = "C:/Users/Flavio/Desktop/plots/mesicliente_density.png", height = 350, width = 450);
PIB %>% ggplot(aes(x=mesicliente)) +
  geom_histogram(aes(y=..density..),colour="black", fill="white") +
  geom_density(alpha=.2, size=1,linetype="solid") +
  xlim(0,42) +
  xlab("numero di mesi") +
  ylab("densità") + 
  theme(axis.title.x = element_text(size = 16),
        axis.text.x = element_text(size = 14),
        axis.text.y = element_text(size = 14),
        axis.title.y = element_text(size = 16))
dev.off()

# boxplot
png(file = "C:/Users/Flavio/Desktop/plots/mesicliente_boxplot.png", height = 350, width = 450);
PIB %>% ggplot(aes(x="",y=mesicliente)) +
  geom_boxplot(outlier.colour="black", outlier.shape=16, outlier.size=2, notch=FALSE) +
  coord_cartesian(ylim = c(0, 42)) +
  ylab("numero di mesi") +
  xlab("") +
  theme(axis.title.y = element_text(size = 16),
        axis.text.y = element_text(size = 14))
dev.off()

summary(PIB$mesicliente)

### GRAFICO RIDUZIONE ERROR RATE
plot(rsf_pib)

### MISURE AGGIUNTIVE ACCURACY

# heatmap sui soli clt churned (threshold 0.5): mesi cliente vs mesi stimati
esempio = as.matrix(rsf_pib$survival.oob)

sur1  = array(NA,dim = nrow(esempio))
for(i in 1:nrow(esempio)){
  
  sa=esempio[i,]
  sur1[i] =   ifelse(is.na(which(sa<=0.5)[1]),42,which(sa<=0.5)[1])
  
}

tavola <- table(estim = sur1[which(PIB$clienteattivo == 0)],
              mesicliente = PIB[which(PIB$clienteattivo == 0),]$mesicliente)

tavola = melt(tavola)

p <- ggplot(tavola, aes(mesicliente, estim)) + geom_tile(aes(fill = value),
                                                         colour = "white") + scale_fill_gradient(low = "white", high = "blue", na.value = "white")

png(file = "C:/Users/Flavio/Desktop/plots/heatmap_pib_churned0.5.png", height = 350, width = 450); p; dev.off()

# per i clt ancora non churned: misura di plausibilita
length(which(sur1[which(PIB$clienteattivo == 1)] < PIB[which(PIB$clienteattivo == 1),]$mesicliente)) / 
  length(sur1[which(PIB$clienteattivo == 1)]) * 100


###  VIMP
modello_ridotto_pib$importance
select_pib <- var.select(modello_ridotto_pib)
select_pib$varselect$vimp

# vimp plot
VimpPlot_pib <- plot(gg_vimp(modello_ridotto_pib))
png(file = "C:/Users/Flavio/Desktop/plots/vimp_pib.png", height = 500, width = 500); 
VimpPlot_pib;
dev.off()

# Rank plot
rankplot_pib<-plot(gg_minimal_vimp(modello_ridotto_pib))
png(file = "C:/Users/Flavio/Desktop/plots/rankplot_pib.png", height = 500, width = 600);
rankplot_pib;
dev.off()

vimp_pib <- rankplot_pib[[1]] %>% arrange(vimp) %>% select(-col)

# grafico sola minimal depth
 gg_md2 <- gg_minimal_depth(modello_pic, lbls = st.labs)
 plot(gg_md2)


### LIFETIME

# somma delle prob di survival
estim_lft<-apply(rsf_pib$survival.oob, 1, sum)
PIB$estim_lft<- estim_lft

### RICAVO MARGINALE

# Density
png(file = "C:/Users/Flavio/Desktop/plots/ricavomarginale_density.png", height = 350, width = 450);
PIB  %>%
  ggplot(aes(x=ricavomarginale_mean)) +
  geom_histogram(aes(y=..density..),colour="black", fill="white") +
  geom_density(size=1,linetype="solid") +
  xlim(-100,1500) +
  xlab("margine medio in euro") +
  ylab("densità") + 
  theme(axis.title.x = element_text(size = 16),
        axis.text.x = element_text(size = 14),
        axis.text.y = element_text(size = 14),
        axis.title.y = element_text(size = 16))
dev.off()

# boxplot
png(file = "C:/Users/Flavio/Desktop/plots/ricavomarginale_boxplot.png", height = 350, width = 450);
PIB %>% ggplot(aes(x="",y=ricavomarginale_mean)) +
  geom_boxplot(outlier.colour="black", outlier.shape=16, outlier.size=2, notch=FALSE) +
  coord_cartesian(ylim = c(-200, 1500)) + 
  ylab("margine medio in euro") +
  xlab("") +
  theme(axis.title.y = element_text(size = 16),
        axis.text.y = element_text(size = 14))
dev.off()

summary(PIB$ricavomarginale_mean)


### LIFETIME VALUE

# calcolo
PIB <- PIB %>% mutate(lft_value = estim_lft * ricavomarginale_mean)
summary(PIB$lft_value)

# Dataset con solo i clienti ancora attivi
attivi_pib <- PIB %>% filter(clienteattivo == 1)
summary(attivi_pib$lft_value)

# density
mediana<- median(attivi_pib$lft_value, na.rm = T)
media<- mean(attivi_pib$lft_value, na.rm = T)

png(file ="C:/Users/Flavio/Desktop/plots/lft_value_pib_density.png", height = 350, width = 400 )
attivi_pib %>% ggplot(aes(x=lft_value)) + 
  geom_density() + coord_cartesian(xlim = c(-1500,30000)) +
  geom_vline(xintercept= c(mediana, media),
             linetype=c("dashed","solid"), size=2) +
  theme(plot.title = element_text(lineheight=.8, face="bold")) +
  geom_text(size = 6, aes(x = 21000,y=1e-04,label="- - -Mediana = 4942euro")) +
  geom_text(size = 6, aes(x = 21000,y=1.2e-04,label="- Media = 9381euro")) +
  theme(legend.position="none" )  +
  xlab("Lifetime Value") +
  ylab("densità") +
  theme(axis.title.x = element_text(size = 16),
        axis.text.x = element_text(size = 14),
        axis.text.y = element_text(size = 14),
        axis.title.y = element_text(size = 16))
dev.off()

# boxplot
png(file = "C:/Users/Flavio/Desktop/plots/lft_value_boxplot.png", height = 350, width = 450);
attivi_pib %>% ggplot(aes(x="",y=lft_value)) +
  geom_boxplot(outlier.colour="black", outlier.shape=16, outlier.size=2, notch=FALSE) +
  coord_cartesian(ylim = c(-2000,3e+04)) + 
  ylab("Lifetime Value in euro") +
  xlab("") +
  theme(axis.title.y = element_text(size = 16),
        axis.text.y = element_text(size = 14))
dev.off()


### HEATMAP LIFETIME VS VARIABILI INDIPENDENTI

# Probabilità di sopravvivenza per cliente
d <- apply(rsf_pib$survival.oob,1,sum,na.rm=T)
bs <- cbind.data.frame(rsf_pib$xvar,d)
nomi <- names(bs)
ne <- nomi[-which(nomi %in% c("TipoCliente","AreaNielsenCliente","primamodalita","tiposped","ultimamodalita"))]

# Codifica disgiuntiva completa dei factor
TipoCliente <- to.dummy(bs$TipoCliente, "TipoCliente")
AreaNielsenCliente <- to.dummy(bs$AreaNielsenCliente, "AreaNielsenCliente")
primamodalita <- to.dummy(bs$primamodalita, "primamodalita")
ultimamodalita <- to.dummy(bs$ultimamodalita, "ultimamodalita")
tiposped <- to.dummy(bs$tiposped, "tiposped")

b3 <- cbind.data.frame(bs[,ne],TipoCliente,AreaNielsenCliente,primamodalita,tiposped,ultimamodalita)

b3 <- b3[, c("d","Variazione_Credito"	,"Campagna_CrossSelling"	,"Campagna_Rimodulazione"	,colnames(TipoCliente),
            "info_Disattivazione"	,"Campagna_Credito"	,"info_Fattura"	,"Variazione_Anagrafica"	,"invio_Modulistica"	,
            "CanaliDigitali"	,"info_Credito"	,"n_utenze"	,colnames(ultimamodalita)	,"Invio_Credito"	,"mobile"	,
            "invio_Fattura"	,"Reclamo_Guasto"	,"Variazione_Sconto_Rimborso"	,"Campagna_Tecnico"	,"info_Modulistica",
            "info_Contratto"	,"info_Attivazione"	,"Campagna_Promo_Offerte"	,"info_Pagamento"	,"Reclamo_Fattura"	,
            "info_Voltura"	,"Variazione_Pagamento"	,colnames(primamodalita)	,"info_Canali_digitali"	,"info_ContoRelax"
            ,"Campagna_Autolettura"	,"Variazione_Autolettura"	,"Variazione_Tecnico"	,"Variazione_Rimodulazione"	,"FattMedia"
            ,"invio_Contratto"	,"flag_sciolto"	,"Reclamo_legale"	,"info_Spedizione"	,"Reclamo_Credito"	,"info_Tecnico"	
            ,"Campagna_Recall"	,colnames(tiposped)	,"Variazione_Fattura"	,"info_Sconto_Rimborso"	,"Reclamo_Attivazione"
            ,"info_Recapito_consulente"	,"info_Rimodulazione"	,"Variazione_Agevolazione"	,"etareferente"	
            ,colnames(AreaNielsenCliente)	,"info_Promo_Offerte"	,"Campagna_Spedizione"	,"Reclamo_Spedizione")]

b4 <- melt(b3,id.vars="d")
b4$d  <- round(b4$d,0) 

# Costruzione classi di mesi
b4$d <- cut(b4$d,9,labels = c("01.0-5","02.5-9","03.9-14","04.14-18","05.18-22","06.23-27","07.27-31","08.31-36","09.36-42"))

b5 <- b4 %>%
  group_by(d,variable) %>%
  dplyr::summarise(value=mean(value,na.rm=T))

b5 <- ddply(b5, .(variable), transform, rescale = scale(value))
base_size <- 9

b5$Mesi <- as.factor(b5$d)

b5 <- ddply(b5, .(variable), transform, rescale = scale(value)) 

p <- ggplot(b5, aes(Mesi,variable)) + geom_tile(aes(fill = rescale), colour = "white") + scale_fill_gradient2(low="blue",mid="white",high="red",midpoint =0)
q <- p + theme_grey(base_size = base_size) + labs(y = "") + scale_x_discrete(expand = c(0, 0)) + theme( axis.text.x = element_text(size = base_size , angle = 330, hjust = 0, colour = "grey50"))

png(file = "C:/Users/Flavio/Desktop/plots/heatmap_classimesiVsVar_pib.png",
    height = 570, width = 550, pointsize = 18, bg = "transparent", res = 95); q; dev.off()

### SEGMENTAZIONE DEL PARCO E ANALISI DEL LIFETIME VALUE
PIB %>%  mutate(cluster = case_when(lft_value <= 5000 ~ "iron",
                                    lft_value > 5000 & lft_value <= 10000 ~ "bronze",
                                    lft_value > 10000 & lft_value <= 20000  ~ "silver",
                                    lft_value > 20000 & lft_value <= 30000  ~ "gold",
                                    lft_value > 30000 ~ "platinum".
                                    TRUE ~ NA))

# Clienti oggetto di interesse (ancora attivi), sovrascritto per aggiunta della variabile cluster
attivi_pib <- PIB %>% filter(clienteattivo == 1)

# Percentuale clt in ogni cluster
table(attivi_pib$cluster)/nrow(attivi_pib)

# Percentuale lft_value per gruppo sul totale
sum(attivi_pib$lft_value[which(attivi_pib$cluster == "iron")])/ sum(attivi_pib$lft_value)
sum(attivi_pib$lft_value[which(attivi_pib$cluster == "bronze")])/ sum(attivi_pib$lft_value)
sum(attivi_pib$lft_value[which(attivi_pib$cluster == "silver")])/ sum(attivi_pib$lft_value)
sum(attivi_pib$lft_value[which(attivi_pib$cluster == "gold")])/ sum(attivi_pib$lft_value)
sum(attivi_pib$lft_value[which(attivi_pib$cluster == "platinum")])/ sum(attivi_pib$lft_value)


# Heatmap cluster vs variabili indipendenti

# riutilizzo dei dati non standardizzati, poiché si sta usando solo il sottoinsieme attivi
# mentre la standardizzazione era stata fatta su sutto il dataset, per cui è necessario standardizzare
# solo per il sottoinsieme di clienti attivi
a <- pib_unscaled %>% select(cliente, names_da_std)
b <- attivi_pib3 %>% select(-names_da_std)
attivi_pib_unscaled <- b %>% inner_join(a, by="cliente")


iii <- names(modello_pib$xvar)
bs <- attivi_pib_unscaled

ne <- iii[-which(names(modello_pib$xvar) %in% c("TipoCliente","AreaNielsenCliente","primamodalita","tiposped","ultimamodalita"))]

ne <- c(ne,"cluster")
TipoCliente <- to.dummy(bs$TipoCliente, "TipoCliente")
AreaNielsenCliente <- to.dummy(bs$AreaNielsenCliente, "AreaNielsenCliente")
primamodalita <- to.dummy(bs$primamodalita, "primamodalita")
ultimamodalita <- to.dummy(bs$ultimamodalita, "ultimamodalita")
tiposped <- to.dummy(bs$tiposped, "tiposped")


b3 <- cbind.data.frame(bs[,ne],TipoCliente,AreaNielsenCliente,primamodalita,tiposped,ultimamodalita)


b3 <- b3[, c("cluster","Variazione_Credito"	,"Campagna_CrossSelling"	,"Campagna_Rimodulazione"	,colnames(TipoCliente),
            "info_Disattivazione"	,"Campagna_Credito"	,"info_Fattura"	,"Variazione_Anagrafica"	,"invio_Modulistica"	,
            "CanaliDigitali"	,"info_Credito"	,"n_utenze"	,colnames(ultimamodalita)	,"Invio_Credito"	,"mobile"	,
            "invio_Fattura"	,"Reclamo_Guasto"	,"Variazione_Sconto_Rimborso"	,"Campagna_Tecnico"	,"info_Modulistica",
            "info_Contratto"	,"info_Attivazione"	,"Campagna_Promo_Offerte"	,"info_Pagamento"	,"Reclamo_Fattura"	,
            "info_Voltura"	,"Variazione_Pagamento"	,colnames(primamodalita)	,"info_Canali_digitali"	,"info_ContoRelax"
            ,"Campagna_Autolettura"	,"Variazione_Autolettura"	,"Variazione_Tecnico"	,"Variazione_Rimodulazione"	,"FattMedia"
            ,"invio_Contratto"	,"flag_sciolto"	,"Reclamo_legale"	,"info_Spedizione"	,"Reclamo_Credito"	,"info_Tecnico"	
            ,"Campagna_Recall"	,colnames(tiposped)	,"Variazione_Fattura"	,"info_Sconto_Rimborso"	,"Reclamo_Attivazione"
            ,"info_Recapito_consulente"	,"info_Rimodulazione"	,"Variazione_Agevolazione"	,"etareferente"	
            ,colnames(AreaNielsenCliente)	,"info_Promo_Offerte"	,"Campagna_Spedizione"	,"Reclamo_Spedizione")]

b4 <- melt(b3,id.vars="cluster")

b5 <- b4 %>%
  group_by(cluster,variable) %>% 
  dplyr::summarise(value=mean(value,na.rm=T))

b5 <- ddply(b5, .(variable), transform, rescale = scale(value))
base_size <- 9


b5$cluster <- factor(b5$cluster,levels =c("iron","bronze","silver","gold","platinum"))
p <- ggplot(b5, aes(cluster,variable)) + geom_tile(aes(fill = rescale), colour = "white") + scale_fill_gradient2(low="blue",mid="white",high="red",midpoint =0)
q <- p + theme_grey(base_size = base_size) + labs(y = "") + scale_x_discrete(expand = c(0, 0)) + theme(axis.text.x = element_text(size = base_size , angle = 330, hjust = 0, colour = "grey50"))

png(file = "C:/Users/Flavio/Desktop/plots/heatmap_clustVsVar_pib.png",
    height = 570, width = 550, pointsize = 18, bg = "transparent", res = 95 ); q; dev.off()
