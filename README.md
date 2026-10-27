<img src="grafica/logo-512.png" width="96" alt="Logo di PiantalAPP">

# PiantalAPP

Un database aperto di schede per la cura di piante e fiori, e un'app Android
che lo rende consultabile anche offline.

Ogni scheda spiega come annaffiare, concimare ed esporre una pianta, quanta luce
vuole, se sta in casa, fuori o in un terrarium. I contenuti sono scritti e
revisionati da una comunità di appassionati ed esperti.

## Struttura

```
dati/piante/        una scheda YAML per pianta (contenuti, CC BY-SA 4.0)
dati/funghi/        una scheda YAML per fungo, solo divulgativa
schema/             schemi JSON di piante e funghi
scripts/valida.py   validazione e generazione di dist/piante.json
.github/            validazione automatica delle pull request e modelli
app/                app Flutter (vedi app/README.md)
grafica/            logo e immagini per lo store
ARCHITETTURA.md     scelte tecniche e piano di lavoro
```

## Piante presenti

Nell'app le piante sono divise in sette categorie, indicate nel campo
`gruppo` di ogni scheda: *Da appartamento*, *Piante grasse*, *Orchidee*,
*Da esterno*, *Aromatiche*, *Alberi* e *Terrari*.

| Pianta | Nome scientifico | Dove |
|---|---|---|
| Ficus benjamina | *Ficus benjamina* | appartamento |
| Ficus robusta | *Ficus elastica* | appartamento |
| Ficus lyrata | *Ficus lyrata* | appartamento |
| Pothos | *Epipremnum aureum* | appartamento, ricadente |
| Sansevieria | *Dracaena trifasciata* | appartamento, succulenta |
| Fittonia | *Fittonia albivenis* | terrarium, appartamento |
| Spatifillo | *Spathiphyllum wallisii* | appartamento, fiorita |
| Liquidambar | *Liquidambar styraciflua* | esterno |
| Ficus Bambino | *Ficus lyrata* 'Bambino' | appartamento, da ufficio |
| Rosa ibrida di tea | *Rosa × hybrida* (Ibridi di Tea) | esterno, balcone, fiorita |
| Rosa floribunda | *Rosa × hybrida* (Floribunda) | esterno, balcone, fiorita |
| Rosa rampicante | *Rosa × hybrida* (rampicanti) | esterno, fiorita |
| Rosa inglese | *Rosa × hybrida* (arbustive e inglesi) | esterno, balcone, fiorita |
| Rosa miniatura | *Rosa × hybrida* (miniatura) | balcone, fiorita |
| Ortensia | *Hydrangea macrophylla* | esterno, balcone, fiorita |
| Phalaenopsis | *Phalaenopsis* | appartamento, fiorita |
| Dendrobium | *Dendrobium nobile* | appartamento, fiorita |
| Cymbidium | *Cymbidium* | appartamento, balcone, fiorita |
| Stella di Natale | *Euphorbia pulcherrima* | appartamento, fiorita |
| Kalanchoe | *Kalanchoe blossfeldiana* | appartamento, succulenta, fiorita |
| Aloe vera | *Aloe vera* | appartamento, balcone, succulenta |
| Albero di giada | *Crassula ovata* | appartamento, balcone, succulenta |
| Echeveria | *Echeveria elegans* | appartamento, balcone, succulenta |
| Haworthia | *Haworthiopsis attenuata* | appartamento, succulenta |
| Mammillaria | *Mammillaria zeilmanniana* | appartamento, balcone, succulenta, fiorita |
| Fico d'India nano | *Opuntia microdasys* | appartamento, balcone, succulenta |
| Oleandro | *Nerium oleander* | esterno, balcone, fiorita, siepe |
| Alloro | *Laurus nobilis* | esterno, balcone, siepe |
| Lauroceraso | *Prunus laurocerasus* | esterno, siepe |
| Fotinia | *Photinia × fraseri* | esterno, siepe |
| Bosso | *Buxus sempervirens* | esterno, balcone, siepe |
| Ligustro | *Ligustrum ovalifolium* | esterno, fiorita, siepe |
| Pitosforo | *Pittosporum tobira* | esterno, balcone, fiorita, siepe |
| Basilico | *Ocimum basilicum* | esterno, balcone, pet_friendly |
| Rosmarino | *Salvia rosmarinus* | esterno, balcone, fiorita, siepe, pet_friendly |
| Salvia | *Salvia officinalis* | esterno, balcone, fiorita, pet_friendly |
| Timo | *Thymus vulgaris* | esterno, balcone, fiorita, pet_friendly |
| Origano | *Origanum vulgare* | esterno, balcone, fiorita |
| Menta | *Mentha spicata* | esterno, balcone |
| Prezzemolo | *Petroselinum crispum* | esterno, balcone |
| Lavanda | *Lavandula angustifolia* | esterno, balcone, fiorita, siepe |
| Maggiorana | *Origanum majorana* | esterno, balcone |
| Erba cipollina | *Allium schoenoprasum* | esterno, balcone, fiorita |
| Geranio | *Pelargonium × hortorum* | esterno, balcone, fiorita |
| Falso gelsomino | *Trachelospermum jasminoides* | esterno, balcone, fiorita, siepe |
| Glicine | *Wisteria sinensis* | esterno, fiorita |
| Bouganvillea | *Bougainvillea glabra* | esterno, balcone, fiorita |
| Monstera | *Monstera deliciosa* | appartamento, da_ufficio |
| Zamioculcas | *Zamioculcas zamiifolia* | appartamento, da_ufficio |
| Anthurium | *Anthurium andraeanum* | appartamento, fiorita, da_ufficio |
| Falangio | *Chlorophytum comosum* | appartamento, ricadente, da_ufficio, pet_friendly |
| Cactus di Natale | *Schlumbergera × buckleyi* | appartamento, succulenta, fiorita, ricadente, pet_friendly |
| Oncidium | *Oncidium* | appartamento, fiorita, pet_friendly |
| Aechmea | *Aechmea fasciata* | appartamento, fiorita, pet_friendly |
| Aglaonema | *Aglaonema commutatum* | appartamento, da_ufficio |
| Alocasia | *Alocasia × amazonica* | appartamento |
| Areca | *Dypsis lutescens* | appartamento, da_ufficio, pet_friendly |
| Aspidistra | *Aspidistra elatior* | appartamento, da_ufficio, pet_friendly |
| Asplenio | *Asplenium nidus* | appartamento, pet_friendly |
| Azalea | *Rhododendron simsii* | appartamento, fiorita, balcone |
| Beaucarnea | *Beaucarnea recurvata* | appartamento, succulenta, da_ufficio, pet_friendly |
| Begonia maculata | *Begonia maculata* | appartamento, fiorita |
| Begonia rex | *Begonia rex* | appartamento |
| Pianta del caffè | *Coffea arabica* | appartamento |
| Caladium | *Caladium bicolor* | appartamento |
| Calamondino | *Citrus × microcarpa* | appartamento, fiorita, balcone |
| Calathea | *Goeppertia makoyana* | appartamento, pet_friendly |
| Ceropegia | *Ceropegia woodii* | appartamento, succulenta, ricadente, pet_friendly |
| Chamaedorea | *Chamaedorea elegans* | appartamento, da_ufficio, pet_friendly |
| Ciclamino | *Cyclamen persicum* | appartamento, fiorita, balcone |
| Cissus | *Cissus rhombifolia* | appartamento, ricadente, da_ufficio, pet_friendly |
| Clivia | *Clivia miniata* | appartamento, fiorita |
| Cordyline | *Cordyline fruticosa* | appartamento |
| Croton | *Codiaeum variegatum* | appartamento |
| Ctenanthe | *Ctenanthe burle-marxii* | appartamento, pet_friendly |
| Dieffenbachia | *Dieffenbachia seguine* | appartamento |
| Dracena marginata | *Dracaena marginata* | appartamento, da_ufficio |
| Edera | *Hedera helix* | appartamento, ricadente |
| Felce di Boston | *Nephrolepis exaltata* | appartamento, ricadente, pet_friendly |
| Ficus ginseng | *Ficus microcarpa* | appartamento, da_ufficio |
| Filodendro a foglia di cuore | *Philodendron hederaceum* | appartamento, ricadente, da_ufficio |
| Filodendro selloum | *Thaumatophyllum bipinnatifidum* | appartamento |
| Gardenia | *Gardenia jasminoides* | appartamento, fiorita, balcone |
| Gelsomino polyanthum | *Jasminum polyanthum* | appartamento, fiorita, balcone, ricadente, pet_friendly |
| Guzmania | *Guzmania lingulata* | appartamento, fiorita, pet_friendly |
| Hoya | *Hoya carnosa* | appartamento, ricadente, fiorita, pet_friendly |
| Ibisco | *Hibiscus rosa-sinensis* | appartamento, fiorita, balcone, pet_friendly |
| Kenzia | *Howea forsteriana* | appartamento, da_ufficio, pet_friendly |
| Lucky bamboo | *Dracaena sanderiana* | appartamento, da_ufficio |
| Maranta | *Maranta leuconeura* | appartamento, ricadente, pet_friendly |
| Monstera adansonii | *Monstera adansonii* | appartamento, ricadente |
| Pachira | *Pachira aquatica* | appartamento, da_ufficio, pet_friendly |
| Peperomia anguria | *Peperomia argyreia* | appartamento, da_ufficio, pet_friendly |
| Peperomia obtusifolia | *Peperomia obtusifolia* | appartamento, da_ufficio, pet_friendly |
| Pilea | *Pilea peperomioides* | appartamento, da_ufficio, pet_friendly |
| Platicerio | *Platycerium bifurcatum* | appartamento, pet_friendly |
| Radermachera | *Radermachera sinica* | appartamento, pet_friendly |
| Rhapis | *Rhapis excelsa* | appartamento, da_ufficio, pet_friendly |
| Schefflera | *Schefflera arboricola* | appartamento, da_ufficio |
| Scindapsus pictus | *Scindapsus pictus* | appartamento, ricadente, da_ufficio |
| Strelitzia | *Strelitzia reginae* | appartamento, fiorita |
| Syngonium | *Syngonium podophyllum* | appartamento, ricadente, da_ufficio |
| Tradescantia zebrina | *Tradescantia zebrina* | appartamento, ricadente |
| Tronchetto della felicità | *Dracaena fragrans* | appartamento, da_ufficio |
| Violetta africana | *Streptocarpus ionanthus* | appartamento, fiorita, pet_friendly |
| Yucca | *Yucca gigantea* | appartamento, da_ufficio |
| Castagno | *Castanea sativa* | esterno |
| Faggio | *Fagus sylvatica* | esterno, siepe |
| Farnia | *Quercus robur* | esterno |
| Roverella | *Quercus pubescens* | esterno |
| Leccio | *Quercus ilex* | esterno, siepe |
| Acero campestre | *Acer campestre* | esterno, siepe |
| Acero di monte | *Acer pseudoplatanus* | esterno |
| Acero giapponese | *Acer palmatum* | esterno, balcone |
| Selaginella | *Selaginella kraussiana* | appartamento, terrarium, pet_friendly |
| Soleirolia | *Soleirolia soleirolii* | appartamento, terrarium, pet_friendly |
| Ipoestes | *Hypoestes phyllostachya* | appartamento, terrarium, pet_friendly |
| Capelvenere | *Adiantum raddianum* | appartamento, terrarium, pet_friendly |
| Peperomia caperata | *Peperomia caperata* | appartamento, terrarium, da_ufficio, pet_friendly |
| Cryptanthus | *Cryptanthus bivittatus* | appartamento, terrarium, pet_friendly |
| Ficus pumila | *Ficus pumila* | appartamento, terrarium, ricadente |
| Dionea | *Dionaea muscipula* | terrarium, balcone, pet_friendly |
| Muschio a cuscino | *Leucobryum glaucum* | terrarium, pet_friendly |

## Funghi

La sezione *Funghi* mostra ogni specie con il nome comune e, tra parentesi, il
nome latino: ad esempio *Porcino (Boletus edulis)*. Ogni scheda ha una foto
da Wikimedia Commons e descrive habitat, stagione, aspetto, commestibilità e
soprattutto i **sosia** con cui si può confondere.

> **Le schede non servono a riconoscere i funghi da mangiare.** L'app lo
> ricorda in cima all'elenco e in ogni scheda: prima di consumare funghi
> raccolti bisogna farli controllare, gratis, dall'Ispettorato micologico
> della ASL.

| Fungo | Commestibilità |
|---|---|
| Chiodino (*Armillaria mellea*) | commestibile con cautela |
| Colombina (*Russula virescens*) | commestibile |
| Dentino (*Hydnum repandum*) | commestibile |
| Galletto (*Cantharellus cibarius*) | commestibile |
| Grifone o maitake, 舞茸 (*Grifola frondosa*) | commestibile |
| Mazza di tamburo (*Macrolepiota procera*) | commestibile |
| Ovolo (*Amanita caesarea*) | commestibile |
| Pioppino (*Cyclocybe aegerita*) | commestibile |
| Porcino (*Boletus edulis*) | commestibile |
| Prataiolo (*Agaricus campestris*) | commestibile |
| Tartufo bianco (*Tuber magnatum*) | commestibile |
| Tartufo nero (*Tuber melanosporum*) | commestibile |
| Tignosa verdognola (*Amanita phalloides*) | mortale |
| Trombetta dei morti (*Craterellus cornucopioides*) | commestibile |

## Google Play Store

I passi per la pubblicazione, le risposte ai moduli della Play Console e la
gestione della chiave di caricamento sono in [docs/PLAY-STORE.md](docs/PLAY-STORE.md).
Testi, icona, grafica e screenshot della scheda sono in
`fastlane/metadata/android/it-IT`.

## iPhone e iPad

- **Subito, senza App Store:** apri https://pxcalleg.github.io/piantalapp/ con
  Safari, tocca *Condividi* e poi *Aggiungi alla schermata Home*. PiantalAPP
  compare tra le app con la sua icona e si apre a schermo intero.
- **App vera e propria:** il progetto iOS è in `app/ios` e GitHub lo compila a
  ogni modifica (controllo *App iOS*). Per installarla sugli iPhone serve:
  1. un account [Apple Developer](https://developer.apple.com/programs/)
     (99 € l'anno, a nome di una persona o di un'azienda);
  2. registrare l'identificativo `io.github.pxcalleg.piantalapp` e creare
     l'app su [App Store Connect](https://appstoreconnect.apple.com);
  3. firmare e caricare la build: da un Mac con Xcode, oppure aggiungendo a
     GitHub le chiavi di App Store Connect perché la carichi da solo su
     TestFlight;
  4. provarla con TestFlight e inviarla alla revisione di Apple.

## Riconoscere una pianta da una foto

Il pulsante *Riconosci* invia la foto a [Pl@ntNet](https://plantnet.org),
che la analizza senza conservarla e propone le specie più probabili, con il
link alla scheda quando la pianta è già in archivio. Il piano gratuito
consente 500 riconoscimenti al giorno.

La chiave del servizio non è nel codice: GitHub la inserisce al momento della
compilazione dal secret `PLANTNET_API_KEY`. Nelle impostazioni della chiave su
[my.plantnet.org](https://my.plantnet.org) va spuntato *expose my API key*,
con `https://pxcalleg.github.io` tra i domini autorizzati. Per provarla in
locale: `flutter run --dart-define=PLANTNET_API_KEY=la-tua-chiave`.

## Contribuire

Vedi [CONTRIBUTING.md](CONTRIBUTING.md). Non serve saper programmare.

## Licenze

- Codice: [Apache 2.0](LICENSE)
- Contenuti in `dati/`: [CC BY-SA 4.0](dati/LICENSE.md)
- Foto: da Wikimedia Commons, ognuna con la sua licenza libera; autore e licenza
  sono in `app/assets/immagini/crediti.json` e sotto ogni foto nell'app
