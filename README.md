# DT_Projekt

Téma projektu
Témou projektu je analýza vývoja pandémie COVID‑19 na základe dát z Európskeho centra pre prevenciu a kontrolu chorôb (ECDC). Dataset obsahuje denné epidemiologické údaje pre všetky krajiny sveta, vrátane počtu prípadov, úmrtí, populácie a geografických atribútov.

Prečo som si vybral tento dataset:

Dáta sú kvalitné, oficiálne a pravidelne aktualizované.

Dataset je dostupný priamo v Snowflake Marketplace, čo spĺňa požiadavky zadania.

Obsahuje časové, geografické aj numerické metriky, ktoré sú ideálne pre tvorbu dimenzionálneho modelu.

Umožňuje analyzovať reálne udalosti, ako priebeh pandémie, trendy a dopady na jednotlivé krajiny.

Aký biznis proces dáta podporujú:

Dataset podporuje biznis proces monitorovania epidemiologickej situácie.

Konkrétne umožňuje:

sledovať denné prípady a úmrtia,

porovnávať krajiny a kontinenty,

vyhodnocovať trendy a dynamiku šírenia,

podporovať rozhodovanie v oblasti verejného zdravia.

Typy údajov v datasete,
Dataset obsahuje tieto typy dát:

časové údaje – dátum reportu,

geografické údaje – krajina, ISO kód, kontinent,

numerické metriky – denné prípady, denné úmrtia, populácia,

technické údaje – dátum poslednej aktualizácie.

Tieto údaje sú vhodné na tvorbu faktovej tabuľky aj dimenzií.

Popis tabuliek zo zdrojového datasetu
Zdrojová tabuľka pochádza zo Snowflake Marketplace:


COUNTRY_REGION, ISO3166_1, CONTINENTEXP sú základom pre geografické dimenzie.

CASES a DEATHS sú hlavné epidemiologické metriky.

POPULATION umožňuje prepočítať metriky na obyvateľa.

LAST_UPDATE_DATE slúži na deduplikáciu a výber najnovších záznamov.

Zhrnutie
Tento dataset poskytuje kompletný základ pre analytický model sledujúci vývoj pandémie COVID‑19. Obsahuje všetky potrebné typy údajov pre tvorbu staging vrstvy, dimenzií aj faktovej tabuľky. Vďaka tomu je vhodný pre vizualizácie, reporting a podporu rozhodovania.
