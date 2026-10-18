# Come contribuire a PiantalAPP

Grazie! PiantalAPP cresce grazie a chi conosce le piante. Non serve saper
programmare: ogni pianta è un semplice file di testo.

## Aggiungere o correggere una scheda

1. Copia una scheda esistente da `dati/piante/` e rinominala con l'id della
   nuova pianta (minuscole e trattini, es. `monstera-deliciosa.yaml`).
2. Compila i campi. Lo schema completo, con la descrizione di ogni campo, è in
   `schema/pianta.schema.json`.
3. Metti `stato: bozza`, il tuo handle GitHub in `autori` e la data di oggi in
   `aggiornato`.
4. Indica in `fonti` da dove vengono le informazioni.
5. Apri una pull request. La validazione automatica controlla la scheda e
   segnala eventuali errori.

Si può fare tutto dal sito di GitHub, con il pulsante "Add file" o la matita di
modifica, senza installare nulla.

### Verificare in locale (facoltativo)

```bash
pip install -r scripts/requirements.txt
python scripts/valida.py
```

## Regole per i contenuti

- **I giorni di annaffiatura sono indicativi.** Il campo `quando` descrive il
  criterio vero (es. "quando i primi 3 cm sono asciutti"): è quello che conta.
- **Scrivi per chi inizia:** frasi brevi, niente gergo non spiegato.
- **Come si propaga:** per ogni metodo elencato in `propagazione` serve una
  voce in `come_si_propaga` con il periodo giusto (`quando`), da 2 a 8 `passi`
  e, se utile, `tempo`, `difficolta` e `note`. Se un testo contiene «: »
  mettilo tra virgolette, altrimenti il file YAML non è valido.
- **Niente copia-incolla** da libri o siti protetti da copyright: riformula con
  parole tue e cita la fonte.
- **Foto:** si usano foto reali da Wikimedia Commons. Basta scrivere nella
  scheda il nome del file, ad esempio:

  ```yaml
  immagini:
    - commons: "Ficus Benjamina.JPG"
  ```

  Dopo l'approvazione, GitHub scarica la foto, controlla che la licenza sia
  libera e salva da solo autore e licenza.
- **Attenzione a YAML:** scrivi `"no"` tra virgolette, altrimenti viene letto
  come valore booleano.

## Revisione

Una scheda passa da `bozza` a `revisionata` quando un revisore esperto l'ha
controllata e approvata. Chi vuole diventare revisore può aprire una issue.

## Licenza

Inviando un contributo ai dati accetti che venga pubblicato con licenza
CC BY-SA 4.0 (vedi `dati/LICENSE.md`); i contributi al codice ricadono sotto
Apache 2.0.
