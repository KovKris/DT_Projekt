# DT_Projekt

🎯 Téma projektu
Tento projekt sa zameriava na analýzu vývoja pandémie COVID‑19 pomocou oficiálnych epidemiologických dát publikovaných Európskym centrom pre prevenciu a kontrolu chorôb (ECDC). Dataset je dostupný priamo v Snowflake Marketplace a obsahuje denné údaje o počte prípadov, úmrtí, populácii a geografických atribútoch pre všetky krajiny sveta.

💡 Prečo som si vybral tento dataset
Dáta sú spoľahlivé, oficiálne a medzinárodne uznávané.

Dataset je dostupný v Snowflake Marketplace, čo spĺňa požiadavky projektu.

Obsahuje časové, geografické aj numerické metriky, ideálne pre tvorbu dimenzionálneho modelu.

Umožňuje analyzovať reálne udalosti a sledovať vývoj pandémie v rôznych krajinách.

Je vhodný na demonštráciu ELT procesov, deduplikácie, čistenia dát a tvorby fact/dim tabuliek.

🏢 Biznis proces, ktorý dáta podporujú
Dataset podporuje biznis proces monitorovania epidemiologickej situácie.
Konkrétne umožňuje:

sledovať denné prípady a úmrtia,

porovnávať krajiny a kontinenty,

vyhodnocovať trendy šírenia,

podporovať rozhodovanie v oblasti verejného zdravia,

vytvárať reporty a vizualizácie pre analytikov a štátne inštitúcie.

🧩 Typy údajov v datasete
Dataset obsahuje tieto typy dát:

časové údaje – dátum reportu,

geografické údaje – krajina, ISO kód, kontinent,

numerické metriky – denné prípady, denné úmrtia, populácia,

technické údaje – dátum poslednej aktualizácie.

Tieto údaje sú vhodné pre tvorbu staging vrstvy, dimenzií aj faktovej tabuľky.

📚 Popis zdrojovej tabuľky
Zdrojová tabuľka pochádza zo Snowflake Marketplace:

COVID19_EPIDEMIOLOGICAL_DATA.PUBLIC.ECDC_GLOBAL
Obsahuje denné epidemiologické údaje pre všetky krajiny sveta.


COUNTRY_REGION, ISO3166_1, CONTINENTEXP sú základom pre geografické dimenzie.

CASES a DEATHS sú hlavné epidemiologické metriky.

POPULATION umožňuje prepočítať metriky na obyvateľa.

LAST_UPDATE_DATE slúži na deduplikáciu a výber najnovších záznamov.
