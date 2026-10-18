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
schema/             schema JSON che ogni scheda deve rispettare
scripts/valida.py   validazione e generazione di dist/piante.json
.github/            validazione automatica delle pull request e modelli
app/                app Flutter (vedi app/README.md)
grafica/            logo e immagini per lo store
ARCHITETTURA.md     scelte tecniche e piano di lavoro
```

## Piante presenti

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

## Contribuire

Vedi [CONTRIBUTING.md](CONTRIBUTING.md). Non serve saper programmare.

## Licenze

- Codice: [Apache 2.0](LICENSE)
- Contenuti in `dati/`: [CC BY-SA 4.0](dati/LICENSE.md)
- Foto: da Wikimedia Commons, ognuna con la sua licenza libera; autore e licenza
  sono in `app/assets/immagini/crediti.json` e sotto ogni foto nell'app
