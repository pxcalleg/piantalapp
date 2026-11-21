# Il dominio piantalapp.it

La versione web dell'app è pubblicata da GitHub Pages (workflow *App web*) ed
è raggiungibile su https://piantalapp.it. Il vecchio indirizzo
https://pxcalleg.github.io/piantalapp/ rimanda da solo al dominio.

## Record DNS (pannello del registrar)

| Tipo  | Nome  | Valore                |
|-------|-------|-----------------------|
| A     | @     | 185.199.108.153       |
| A     | @     | 185.199.109.153       |
| A     | @     | 185.199.110.153       |
| A     | @     | 185.199.111.153       |
| AAAA  | @     | 2606:50c0:8000::153   |
| AAAA  | @     | 2606:50c0:8001::153   |
| AAAA  | @     | 2606:50c0:8002::153   |
| AAAA  | @     | 2606:50c0:8003::153   |
| CNAME | www   | pxcalleg.github.io    |

Vanno tolti eventuali altri record A, AAAA o CNAME su `@` e `www` (per esempio
quelli della pagina di parcheggio del registrar). I record MX della posta non
si toccano.

## Impostazioni su GitHub

1. *Settings › Pages › Custom domain*: `piantalapp.it`, poi *Save*.
2. Quando il controllo DNS è verde, spuntare *Enforce HTTPS* (il certificato
   può richiedere fino a un'ora).
3. Facoltativo ma consigliato: in *Settings* del profilo › *Pages* ›
   *Add a domain* si verifica `piantalapp.it` con un record TXT, così nessun
   altro può usarlo su GitHub.

L'app web è compilata con `--base-href /` perché è servita dalla radice del
dominio. Su [my.plantnet.org](https://my.plantnet.org) `https://piantalapp.it`
e `https://www.piantalapp.it` devono essere tra i domini autorizzati.
