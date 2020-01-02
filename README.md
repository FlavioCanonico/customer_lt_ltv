# Customer Lifetime e Lifetime Value
Estimate customer lifetime and lifetime value using Random Survival Forest Algorithm

Il progetto mira a stimare il fenomeno dell'abbandono dei clienti (customer churn) in una società che opera nel settore energetico e delle telecomunicazioni. L'evento del churn è definito come il momento in cui il cliente rescinde il contratto e disattiva le proprie utenze.

Gli **obiettivi** sono:
- Stima della probabilità di abbandono per mese in un range temporale di 45 mesi
- Stima del tempo prima dell'abbandono (lifetime o LT)
- Studio delle caratteristiche del parco clienti per comprendere le cause dell'abbandono
- Stima del valore economico potenziale del cliente per l'azienda (lifetime value o LTV)
- Clustering del parco clienti sulla base del LTV adottare delle specifiche strategie nell’ambito della customer care e del marketing aziendale, con lo scopo di aumentare la fidelity (riducendo quindi il churn rate) e massimizzare il lifetime value per l’intero parco clienti.

Per perseguire questi obiettivi sono stati utilizzati gli strumenti dell'analisi statistica della sopravvivenza, in particolare il fulcro dell'analisi è basato sull'applicazione della recente metodologia [Random Survival Forest (RSF)](https://arxiv.org/pdf/0811.1645.pdf), che è in sostanza un estenzione della metodologia Random Forest all'analisi della sopravvivenza.

# Dataset

È stata operata una suddivisione del parco clienti in 3 diversi dataset in base alla tipologia contrattuale e sono stati addestrati 3 algoritimi RSF differenti. In questo repository si farà riferimento all'analisi effettuata sui clienti Business. Il dataframe è composto da circa 40mila osservazioni e 350 variabili. Di questi circa il 50% hanno sperimentato il churn, gli altri seguendo la terminologia dell'analisi della sopravvivenza sono detti ***censurati a destra***. Volendo suddividere in macro categorie le variabili incluse si possono distinguere:

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

Per ragioni di rispetto della privacy non è possibile caricare i dati su questo repository.

Una parte del pre-processing dei dati è stata fatta direttamente in Microsoft SQL, mentre la gran parte dell'analisi è stata portata avanti in RStudio. Il codice semplificato e commentato è consultabile e scaricabile nei file allegati al presente repository Github.















