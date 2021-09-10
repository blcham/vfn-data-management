# Správa dat Sémantického slovníku pojmů

Správa dat slouží k tvorbě dat dle [Sémantického slovníku pojmů](https://xn--slovnk-7va.gov.cz/). V současné době zahrnuje jedinou komponentu - [Správce dat](https://github.com/opendata-mvcr/ofn-record-manager).

## Nasazení Správce dat

Tento repozitář obsahuje sadu instrukcí pro nasazení. Predpokládá se, že je nainstalován docker-compose, skript `rdfpipe` (v debiane lze nainstalovat například pomocí `apt install python-rdflib-tools`), perl module URI::Escape (v debiane lze nainstalovat například pomocí `apt install make; cpan URI::Escape`) .

Postup:

1. [Autentikuj se do služby GitHub Packages](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-docker-registry#authenticating-to-github-packages), 
   kde je potřeba mít nastaveny práva `read:packages`. Příklad: 
`cat GITHUB_PERSONAL_ACCESS_TOKEN.txt | docker login https://docker.pkg.github.com -u USERNAME --password-stdin`

2. Aktualizuj skripty pro generování formulářů pomocí `./bin/update-scripts.sh`.


3. Spusť `docker-compose` s příslušným `.env.*` souborem. Příklad:

```
docker-compose --env-file=.env.local up
```

4. Nastav proměnné přikazového řádku pomocí ./bin/set-env.sh s příslušným `.env.*` souborem. Příklad:
`. ./bin/set-env.sh .env.local`.

5. Vytvoř 2 RDF4J repozitáře se jménem ofn-form-manager-app a ofn-form-manager-formgen puštením skriptu 
   `./bin/rdf4j-create-repositories.sh`  
   (alternativně je možné využít RDF4J server UI z adresy http://localhost:8888/rdf4j-workbench)

6. Vygeneruj formuláře pro 4 předdefinované OFN pomocí `./bin/deploy-all-forms.sh`. Pozor, příkaz může trvat až 15 minut. 

7. Restartuj Docker compose skript. Například pomocí:
```
docker-compose restart
```

8. Prihlaš se do aplikace bežící na `http://localhost:4000` pomocí uživatelkého jména "admin" a hesla "5y5t3mAdm1n." 
   a následně heslo změn.


## Logování

Logování orchestované služby definované v `docker-compose.yml` lze najít ve složce `./logs/SLUZBA`, kde `SLUZBA` je jméno dané služby např. `dm-s-pipes-engine`.
Tento adresař lze pak sdílet přes např. `nginx` web server pomocí:
```
    location /logs {
                root /PARENT_DIRECTORY/sgov-data-management ;
                autoindex on ;
        }
```
Pro správné publikování logů pomocí `nginx` web serveru je potřeba ve složce `./logs` nastavit práva dle skupiny uživatele pod kterým web server běží. Uvažujme skupinu `nginx`, pak lze nastavit práva následovně:
```
cd /PARENT_DIRECTORY/sgov-data-management/logs
chmod g+s .
chgrp nginx .
mkdir SLUZBA   # we must do it as docker on service run for unknown reason ignores "chmod g+s"
```
Navíc u služby `dm-rdf4j` je potřeba nastavit práva pro zápis libovolného uživatele, tedy `chown o+w dm-rdf4j` (Důvodem je, že do logu zapisuje dedikovaný uživatel služby `dm-rdf4j`).

-----

Tento repozitář vznikl v rámci projektu OPZ č. [CZ.03.4.74/0.0/0.0/15_025/0004172](https://esf2014.esfcr.cz/PublicPortal/Views/Projekty/Public/ProjektDetailPublicPage.aspx?action=get&datovySkladId=7CCECB36-FB27-4B75-9F6B-6892D2107FD8) a je udržován v rámci projektu OPZ č. [CZ.03.4.74/0.0/0.0/15_025/0013983](https://esf2014.esfcr.cz/PublicPortal/Views/Projekty/Public/ProjektDetailPublicPage.aspx?action=get&datovySkladId=F5E162B2-15EC-4BBE-9ABD-066388F3D412).
![Evropská unie - Evropský sociální fond - Operační program Zaměstnanost](https://data.gov.cz/images/ozp_logo_cz.jpg)
