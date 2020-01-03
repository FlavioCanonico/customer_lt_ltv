# Customer Lifetime e Lifetime Value
Estimate customer lifetime and lifetime value using Random Survival Forest Algorithm

Il progetto mira a stimare il fenomeno dell'abbandono dei clienti (customer churn) in una società che opera nel settore energetico e delle telecomunicazioni. L'evento del churn è definito come il momento in cui il cliente rescinde il contratto e disattiva le proprie utenze. Il progetto è ad oggi implementato nei sistemi aziendali in produzione in diverse forme, che verranno discusse brevemente più avanti. Inoltre la parte più tecnica è stata oggetto di un lavoro di tesi magistrale. Per approfondimenti dettagliati sull'implementazione dell'algoritmo e i risultati ottenuto si veda il lavoro di tesi allegato in formato pdf al presente repository.

Gli **obiettivi** sono:
- Stima della probabilità di abbandono per mese in un range temporale di 42 mesi
- Stima del tempo prima dell'abbandono (lifetime o LT)
- Studio delle caratteristiche del parco clienti per comprendere le cause dell'abbandono
- Stima del valore economico potenziale del cliente per l'azienda (lifetime value o LTV)
- Clustering del parco clienti sulla base del LTV adottare delle specifiche strategie nell’ambito della customer care e del marketing aziendale, con lo scopo di aumentare la fidelity (riducendo quindi il churn rate) e massimizzare il lifetime value per l’intero parco clienti.

Per perseguire questi obiettivi sono stati utilizzati gli strumenti dell'***analisi statistica della sopravvivenza***, in particolare il fulcro dell'analisi è basato sull'applicazione della recente metodologia [Random Survival Forest (RSF)](https://arxiv.org/pdf/0811.1645.pdf), che è in sostanza un estenzione della metodologia Random Forest all'analisi della sopravvivenza.

# Dataset

È stata operata una suddivisione del parco clienti in 3 diversi dataset in base alla tipologia contrattuale e sono stati addestrati 3 algoritimi RSF differenti. In questo repository si farà riferimento all'analisi effettuata sui clienti Business. Il dataframe è composto da circa 40mila osservazioni e 256 variabili. Di questi circa il 50% hanno sperimentato il churn, gli altri seguendo la terminologia dell'analisi della sopravvivenza sono detti ***censurati a destra***. Volendo suddividere in macro categorie le variabili incluse si possono distinguere:

- Variabili socio-anagrafiche legate al referente del contratto: quali l’età, l’area di residenza, il genere e così via.
- Variabili legate alle caratteristiche contrattuali del cliente: quali numero e tipo di utenze da quando è diventato cliente dell'azienda;
-numero e tipo di utenze attive al momento dell’analisi; se nella loro storia hanno cambiato tipologia contrattuale ; tutta una serie di
variabili sulle specifiche tecniche dell’utenza, ad esempio il tipo di linea, la potenza impiegata e così via.
- Variabili legate a fatturazione e pagamenti: quali fattura media, modalità di spedizione della fattura, modalità di pagamento, numero  di mesi in cui ci sono stati ritardi nei pagamenti, numero di blocchi temporanei delle utenze per morosità e così via.
- Numero di casi aperti sull’anagrafica del cliente che riguardano la richiesta o ricezione di Informazioni: possono essere informazioni di carattere tecnico, sui contratti, a proposito di offerte dedicate e così via.
- Numero di casi aperti sull’anagrafica del cliente che riguardano operazioni di Variazione: possono riguardare variazioni dell’offerta, dell’anagrafica, delle caratteristiche tecniche del servizio e così via.
- Numero di casi aperti sull’anagrafica del cliente che riguardano la ricezione di una Campagna: si tratta delle volte in cui il cliente rientra in una campagna specifica e viene contattato. Le campagne possono avere a che fare con tentativi di retention, la necessità di rimodulare la taglia dell’offerta, azioni di cross-selling per far sottoscrivere abbonamenti a prodotti aggiuntivi, comunicazione di nuovi servizi e così via.
- Numero di casi aperti sull’anagrafica del cliente che riguardano l’apertura di un Reclamo: si può trattare di reclami per guasti tecnici, per incongruenze di fatturazione, ritardi di attivazione e così via.
- Numero di casi aperti sull’anagrafica del cliente che riguardano un invio di documentazione: si tratta di quei contatti con il cliente quando avviene una richiesta esplicita per l’invio del contratto, della fattura, di modulistica e così via. Può anche riguardare l’invio di documentazione inerente al credito.
- Infine le variabili di risposta sono due, una indica se l'osservazione ha sperimentato l'evento terminale (churn), mentre l'altra indica il numero di mesi trascorsi dalla stipula del contratto.
Per ragioni di rispetto della privacy non è possibile caricare i dati su questo repository.

Una parte del pre-processing dei dati è stata fatta direttamente in Microsoft SQL, mentre la gran parte dell'analisi è stata portata avanti in RStudio. Il codice semplificato e commentato è consultabile e scaricabile nei file allegati al presente repository Github.

La RSF finale include 54 variabili indipendenti e per la sua costruzione sono stati addestrati 1000 alberi di sopravvivenza. Si è optato per l'imputazione dei dati mancanti utilizzando la procedura implementata nel package [```RandomForestSRC```](https://cran.r-project.org/web/packages/randomForestSRC/randomForestSRC.pdf).
L'error rate ottenuto è dell'11.5%, un risultato più che si allontana abbondantemente dal 50%, situazione che identifica il caso in cui le previsioni sono fatte in modo casuale. Di seguito sono riassunte le principali caratteristiche della RSF addestrata:

| | Valore|
|------------------------|-------|
|Numerosità campionaria	| 36694|
|Numero di eventi terminali | 18661|
|Imputazione dei dati mancanti | si|
|Numero di alberi | 1000|
|Numerosità dei nodi terminali | 15|
|Numero medio di nodi terminali | 2.949.659|
|Numero di variabili testate a ogni split | 8|
|Numero totale di variabili | 54|
|Regola di split | logrank|
|Error Rate | 11,51%|

Dalla RSF sono state ottenute così le stuime di probabilità per ognuno dei 42 mesi considerati. Una volta ottenute le probabilità di sopravvivenza stimate per ogni tempo *t* considerato per ognuno dei clienti, si vuole quindi definire una stima del tempo in mesi prima che si verifichi il churn. Una misura che stima il tempo di sopravvivenza in mesi, tenendo presente che il range necessariamente varierà da 0 a 42 mesi, è dato dalla somma delle probabilità di sopravvivenza nei singoli mesi. In questo modo si può quindi definire una misura del **Lifetime (LT)** stimato per ogni cliente.
Si è proceduto poi alla costruzione dei una heatmap, per studiare le relazioni tra le variabili indipendenti e il Lifetime stimato. nello specifico si sono raggruppati i clienti per classi di mesi di sopravvivenza stimati e si è costruita così l'asse delle ascisse. Sull'asse delle ordinate sono state poste le variabili indipendenti in ordine di Variable Importance dal basso verso l'alto.

![alt text](C:\Users\fcanonico\Desktop\heatmap.png "Logo Title Text 1")

Moltiplicando questa misura per il ricavo marginale medio mensuile dei singoli clienti è posssibile ottenere una stima del valore economico potenziale del cliente, detta **Lifetime Value (LTV)**. 












