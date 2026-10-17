# PiantalAPP: architettura e piano di lavoro

## In breve

- I **contenuti** vivono in un repository GitHub pubblico, una scheda YAML per
  pianta. Chiunque può proporre modifiche con una pull request; una
  validazione automatica controlla ogni scheda contro lo schema.
- A ogni modifica approvata, GitHub Actions genera un unico file
  `piante.json` e lo pubblica (GitHub Pages o Release).
- L'**app Android** include una copia del file al momento dell'installazione,
  quindi funziona offline, e scarica la versione aggiornata quando c'è rete.
  Nuove piante arrivano senza dover pubblicare un aggiornamento sul Play Store.
- Nessun server da mantenere e nessun costo di hosting.

```
 Esperti ──PR──▶ GitHub (dati/piante/*.yaml)
                    │  CI: valida schema + revisione umana
                    ▼
               piante.json su GitHub Pages
                    │  download quando c'è rete
                    ▼
              App Android (copia offline nel telefono)
```

## Scelte tecniche

| Tema | Scelta | Perché |
|---|---|---|
| Formato dati | YAML, uno per pianta | Leggibile da non programmatori, diff chiari nelle PR, pochi conflitti |
| Validazione | JSON Schema + `scripts/valida.py` in CI | Errori segnalati subito, prima della revisione |
| App | **Flutter** (Dart) | Un solo codice per Android oggi e iOS domani; ottima resa grafica; molto documentato |
| Database in app | JSON incluso + cache locale (SQLite/Isar se servirà ricerca avanzata) | Offline, semplice, veloce con migliaia di schede |
| Immagini | Wikimedia Commons o foto dei contributori con licenza libera | Nessun problema di copyright |
| Repository | Unico ("monorepo") con `dati/` e `app/` | Più semplice all'inizio; i dati si possono separare in seguito |

Alternativa valida: Kotlin + Jetpack Compose, se si vuole un'app solo Android e
nativa al 100%. Il formato dei dati non cambia.

## Licenze

- **Codice** (app, script, schema): Apache 2.0, permissiva e con tutela sui brevetti.
- **Contenuti** (schede, testi): CC BY-SA 4.0, la stessa di Wikipedia. Chiunque
  può riusarli citando la fonte, e le versioni modificate restano libere.
- L'app mostra in ogni scheda autori e fonti, come richiesto dalla licenza.

## Schema della scheda

Definito in `schema/pianta.schema.json`. Campi principali:

- identità: `id`, `nome_scientifico`, `sinonimi`, `famiglia`, `nomi_comuni` per lingua
- `categorie` (appartamento, terrarium, esterno, succulenta, fiorita, pet_friendly...)
- `ambiente`: interno, esterno (no / solo estate / tutto l'anno), terrarium (aperto / chiuso)
- `luce`: livello ideale e tollerato, sole diretto, esposizione della finestra
- `annaffiatura`: criterio ("quando..."), intervallo di giorni per stagione, segnali di troppa o poca acqua
- `concimazione`: mesi, frequenza, tipo di concime
- `temperatura`, `umidita`, `terreno`, `rinvaso`, `propagazione`
- `tossicita` per animali e persone
- `problemi_comuni`: sintomo, causa, rimedio
- `immagini` con autore e licenza, `fonti`, `autori`, `aggiornato`
- `stato`: bozza, in revisione, revisionata

I valori strutturati (enumerazioni, intervalli numerici) permettono all'app di
filtrare ("piante per poca luce", "sicure per i gatti") e in futuro di generare
promemoria di annaffiatura.

## Piano a fasi

**Fase 0, fondamenta** (fatto in questo scaffold)
Schema, 5 schede in bozza, validazione, modelli per issue e PR, licenze.

**Fase 1, repository e contenuti**
- Creare il repository pubblico su GitHub e attivare la validazione automatica.
- Arrivare a 25-30 schede, con le prime guide (es. "Come costruire un terrarium").
- Trovare 2-3 revisori esperti e portare le schede a `revisionata`.

**Fase 2, app minima (MVP)**
- Elenco piante con ricerca per nome comune e scientifico.
- Filtri: interno/esterno, luce, terrarium, sicura per animali.
- Pagina della scheda con icone per luce, acqua e concime.
- Funzionamento offline e aggiornamento dei dati dal repository.
- Pagina "Contribuisci" con link a GitHub, crediti e licenze.

**Fase 3, preparazione al Play Store**
- Account sviluppatore Google Play (25 USD una tantum).
- Informativa privacy (obbligatoria anche se l'app non raccoglie dati).
- Icona, screenshot, descrizione della scheda dello store.
- Per i nuovi account personali Google richiede un test chiuso con almeno 12
  tester per 14 giorni prima della pubblicazione: conviene reclutarli presto.

**Fase 4, pubblicazione**
Rilascio in produzione, poi aggiornamenti dell'app solo per nuove funzioni:
le schede si aggiornano da sole.

**Fase 5, crescita**
- Le mie piante: lista personale con promemoria di annaffiatura e concimazione.
- Traduzioni (lo schema prevede già più lingue nei nomi).
- Sezione guide: terrarium, rinvaso, parassiti.
- Eventuale versione iOS dallo stesso codice Flutter.
- Modulo in app per segnalare errori nelle schede, che apre una issue.

## Decisioni ancora aperte

- Nome e account (personale o organizzazione) del repository GitHub.
- Conferma di Flutter oppure Kotlin.
