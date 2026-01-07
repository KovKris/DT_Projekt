# DT_Projekt

1️⃣ Úvod a popis zdrojových dát
Tento projekt sa zameriava na analýzu baseballových zápasov pomocou dát zo Snowflake Marketplace.
Použitý dataset pochádza od poskytovateľa Stats Perform (Opta) a obsahuje detailné informácie o zápasoch, tímoch, skóre, súťažiach a štadiónoch.

Prečo som si vybral tento dataset
baseball je dátovo bohatý šport, ideálny na analytické modelovanie,

dataset obsahuje časové, geografické aj výkonové údaje,

umožňuje vytvoriť plnohodnotný dimenzionálny model,

dá sa na ňom demonštrovať kompletný ELT proces v Snowflake.

Biznis proces
Dataset podporuje proces „odohratie baseballového zápasu“.
Každý riadok predstavuje jeden zápas a obsahuje informácie o:

tímoch (home/away),

skóre,

dátume a čase zápasu,

súťaži a sezóne,

mieste konania.

Typy údajov
Dataset obsahuje:

VARCHAR – textové údaje (tímy, súťaže, krajiny, štadióny)

NUMBER – skóre, počty, identifikátory

TIMESTAMP_NTZ – dátum a čas zápasu

DATE – dátumová dimenzia

BOOLEAN (1/0) – výhra, prehra, remíza

Popis zdrojovej tabuľky
FIXTURES
Obsahuje kompletný zoznam baseballových zápasov.
Hlavné polia:

GAME_UUID – identifikátor zápasu

HOME / AWAY – názvy tímov

HOME_SCORE / AWAY_SCORE – výsledok

COMPETITION, SEASON – súťaž a sezóna

DATE_TIME – dátum a čas zápasu

VENUE – štadión

COUNTRY, REGION – geografické údaje

ERD pôvodného datasetu

