# Správa dat Sémantického slovníku pojmů

Správa dat slouží k tvorbě dat dle [Sémantického slovníku pojmů](https://xn--slovnk-7va.gov.cz/). V současné době zahrnuje jedinou komponentu - [Správce dat](https://github.com/opendata-mvcr/ofn-record-manager).

## Nasazení Správce dat

Tento repozitář obsahuje sadu Docker instrukcí pro nasazení.

Postup:

1. Aktualizuj skripty pro generování formulářů pomocí ./bin/update-scripts.sh

2. Spusť `docker-compose` s příslušným `.env.*` souborem. Příklad:

```
docker-compose --env-file=.env.local up
```

3. Vytvoř 2 repozitare na adrese http://localhost:8080/rdf4j-workbench se jmenem ofn-form-manager-app a ofn-form-manager-formgen

4. Vygeneruj formuláře pro 4 předdefinované OFN.

5. Prihlaš se do aplikace pomocí uživatelkého jména admin a hesla "5y5t3mAdm1n." a následně heslo změn.


-----

Tento repozitář vznikl v rámci projektu OPZ č. [CZ.03.4.74/0.0/0.0/15_025/0004172](https://esf2014.esfcr.cz/PublicPortal/Views/Projekty/Public/ProjektDetailPublicPage.aspx?action=get&datovySkladId=7CCECB36-FB27-4B75-9F6B-6892D2107FD8) a je udržován v rámci projektu OPZ č. [CZ.03.4.74/0.0/0.0/15_025/0013983](https://esf2014.esfcr.cz/PublicPortal/Views/Projekty/Public/ProjektDetailPublicPage.aspx?action=get&datovySkladId=F5E162B2-15EC-4BBE-9ABD-066388F3D412).
![Evropská unie - Evropský sociální fond - Operační program Zaměstnanost](https://data.gov.cz/images/ozp_logo_cz.jpg)


