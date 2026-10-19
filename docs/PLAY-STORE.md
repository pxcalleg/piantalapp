# Pubblicare PiantalAPP sul Google Play Store

Questa guida raccoglie tutto quello che serve per la prima pubblicazione e le
risposte già pronte per i moduli della Play Console. I materiali della scheda
sono in [`fastlane/metadata/android/it-IT`](../fastlane/metadata/android/it-IT).

## 1. Prima di iniziare

- **Account Play Console di tipo «Organizzazione»**, intestato alla ditta, con
  il numero D-U-N-S. Gli account organizzazione non devono fare il test chiuso
  con 12 tester per 14 giorni richiesto agli account personali.
- **Sito web dello sviluppatore**: https://pxcalleg.github.io/piantalapp/
- **Email di contatto**: piantalapp@lcsoluzioni.it
- **Informativa sulla privacy**: https://pxcalleg.github.io/piantalapp/privacy.html
  (sorgente in [`app/web/privacy.html`](../app/web/privacy.html), raggiungibile
  anche dall'app in *Informazioni › Informativa sulla privacy*).

## 2. La chiave di caricamento (una volta sola)

Google firma l'app con una sua chiave (*Play App Signing*); noi firmiamo il
pacchetto che carichiamo con una **chiave di caricamento privata**, che non
deve mai finire nel repository.

1. Sul PC serve `keytool`, incluso in Java o in Android Studio. Da un terminale:

   ```
   keytool -genkeypair -v -keystore caricamento.jks -storetype PKCS12 -keyalg RSA -keysize 4096 -validity 10000 -alias caricamento
   ```

   Scegli una password lunga e rispondi alle domande (nome, ditta, città, «IT»).
2. Converti il file in testo e copialo negli appunti. Su Windows, in PowerShell:

   ```
   [Convert]::ToBase64String([IO.File]::ReadAllBytes("caricamento.jks")) | Set-Clipboard
   ```

   Su Mac o Linux: `base64 -i caricamento.jks | pbcopy` (Mac) oppure `base64 -w0 caricamento.jks` (Linux).
3. In GitHub, *Settings › Secrets and variables › Actions › New repository secret*,
   aggiungi due secret:
   - `PLAY_UPLOAD_KEYSTORE`: il testo copiato al punto 2;
   - `PLAY_UPLOAD_KEYSTORE_PASSWORD`: la password scelta al punto 1.
4. **Conserva** `caricamento.jks` e la password in un posto sicuro (per esempio
   un gestore di password). Se li perdi, si può chiedere a Google di sostituire
   la chiave di caricamento, ma servono alcuni giorni.

Da quel momento ogni modifica su `main` produce, oltre all'APK di anteprima, il
pacchetto `app-release.aab` firmato: si scarica dalla pagina dell'esecuzione
del controllo *App Android*, nella sezione *Artifacts* (`piantalapp-play-store`).
Il numero di versione cresce da solo a ogni build.

## 3. Creare l'app nella Play Console

*Crea app*: nome **PiantalAPP**, lingua predefinita **Italiano – it-IT**,
tipo **App**, **Gratuita**. Accetta le dichiarazioni.

### Scheda dello Store principale

| Campo | Dove si trova |
| --- | --- |
| Nome dell'app (max 30) | `title.txt` |
| Breve descrizione (max 80) | `short_description.txt` |
| Descrizione completa (max 4000) | `full_description.txt` |
| Icona 512×512 | `images/icon.png` |
| Grafica in evidenza 1024×500 | `images/featureGraphic.png` |
| Screenshot del telefono | `images/phoneScreenshots/1.png` … `6.png` |

Categoria consigliata: **Casa e arredamento**. Tag: giardinaggio, piante.
Email: piantalapp@lcsoluzioni.it. Sito: https://pxcalleg.github.io/piantalapp/

### Contenuti dell'app (moduli)

- **Norme sulla privacy**: https://pxcalleg.github.io/piantalapp/privacy.html
- **Accesso all'app**: *Tutte le funzionalità sono disponibili senza
  restrizioni* (non ci sono account né login).
- **Annunci**: *No, l'app non contiene annunci*.
- **Classificazione dei contenuti** (questionario IARC):
  - email: piantalapp@lcsoluzioni.it; categoria: *Tutti gli altri tipi di app*;
  - violenza, paura, sessualità, linguaggio volgare, sostanze, gioco d'azzardo: **No** a tutto;
  - gli utenti possono interagire o scambiarsi contenuti: **No**;
  - condivide la posizione dell'utente: **No**;
  - acquisti digitali: **Sì** (le donazioni in-app);
  - risultato atteso: **PEGI 3** / *Per tutti*.
- **Pubblico di destinazione**: fasce **13-15, 16-17 e 18+**. Non selezionare
  le fasce sotto i 13 anni, altrimenti si applicano i requisiti del programma
  Famiglie. Attrattiva per i bambini: *No*.
- **App di notizie**: No. **App governative**: No. **Funzionalità finanziarie**:
  nessuna. **App per la salute**: nessuna.
- **Sicurezza dei dati**:
  - *L'app raccoglie o condivide dati utente?* **Sì** (le foto inviate a Pl@ntNet).
  - *I dati sono criptati in transito?* **Sì** (tutte le connessioni sono HTTPS).
  - *Gli utenti possono chiedere la cancellazione dei dati?* **Sì**, scrivendo a
    piantalapp@lcsoluzioni.it (in pratica non conserviamo nulla).
  - Tipo di dati **Foto e video › Foto**:
    raccolti **Sì**, condivisi **No** (Pl@ntNet li elabora per conto dell'app,
    come fornitore del servizio), **trattati in modo temporaneo: Sì**,
    **facoltativi** (solo se l'utente usa «Riconosci»), finalità
    **Funzionalità dell'app**.
  - Le donazioni passano dal sistema di pagamento di Google Play: i dati di
    pagamento li tratta Google e l'app non li vede, quindi non vanno
    dichiarati (da ricontrollare nel modulo al momento della compilazione).
  - Nessun altro tipo di dati. Il modulo «Contattaci» apre l'app di posta
    dell'utente: il messaggio non passa dall'app, quindi non va dichiarato.
- **Autorizzazioni**: l'app non chiede la posizione né l'accesso a tutte le
  foto; la fotocamera e la scelta della foto passano dal sistema.

## 4. Donazioni in-app

Il tasto «Sostieni lo sviluppo di PiantalAPP» propone donazioni da pagare con
Google Play. I soldi arrivano sul profilo pagamenti dell'account Play Console e
Google li bonifica ogni mese sul conto indicato, trattenendo il 15%.

1. *Impostazioni › Profilo pagamenti*: crea il profilo da commerciante della
   ditta, con partita IVA e IBAN. Senza profilo non si possono creare prodotti.
2. Carica almeno una release (anche solo nel test interno): i prodotti in-app
   si possono creare solo dopo.
3. *Monetizza › Prodotti › Prodotti in-app › Crea prodotto*, tre volte:

   | ID prodotto | Nome | Prezzo |
   | --- | --- | --- |
   | `donazione_1` | Donazione piccola | 1 € |
   | `donazione_3` | Donazione media | 3 € |
   | `donazione_5` | Donazione grande | 5 € |

   Descrizione: «Sostieni lo sviluppo di PiantalAPP». Attiva ogni prodotto.
   Gli ID devono essere esattamente questi (sono in
   [`app/lib/dati/donazioni.dart`](../app/lib/dati/donazioni.dart)).
4. *Impostazioni › Test delle licenze*: aggiungi la tua email per provare una
   donazione senza essere addebitato.

Finché i prodotti non esistono, la pagina «Sostieni» dice che le donazioni si
fanno dall'app del Play Store e mostra solo gli altri modi per aiutare. Lo
stesso succede nella versione web.

## 5. Prima release

1. *Test › Test interno*: crea una release, carica `app-release.aab`, accetta
   *Play App Signing* con la chiave gestita da Google. Aggiungi la tua email
   come tester e prova l'app scaricata dal Play Store.
2. *Produzione › Crea nuova release*: carica lo stesso pacchetto (o uno più
   recente), paesi **Italia** (e altri a scelta), note di rilascio, invia per
   la revisione. La prima revisione di Google può richiedere alcuni giorni.

Dopo la pubblicazione, gli aggiornamenti si fanno caricando il nuovo
`app-release.aab` in una nuova release di produzione.
