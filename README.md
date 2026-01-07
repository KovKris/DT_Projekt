# DT_Projekt

1️⃣ Úvod a popis zdrojových dát
Tento projekt sa zameriava na analýzu baseballových zápasov pomocou dát zo Snowflake Marketplace.
Použitý dataset pochádza od poskytovateľa Stats Perform (Opta) a obsahuje detailné informácie o zápasoch, tímoch, skóre, súťažiach a štadiónoch.

Prečo som si vybral tento dataset:
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

INT – skóre, počty, identifikátory

TIMESTAMP_NTZ – dátum a čas zápasu

DATE – dátumová dimenzia

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

<img width="391" height="888" alt="ERD_diagram_projekt" src="https://github.com/user-attachments/assets/f6adf094-693c-454e-bcf1-2b9457163064" />

2️⃣ Návrh dimenzionálneho modelu (Star Schema)
Dimenzionálny model je navrhnutý podľa Kimballovej metodológie.
Obsahuje:

1 faktovú tabuľku: FACT_GAME_RESULTS

4 dimenzie: DIM_DATE, DIM_TEAM, DIM_COMPETITION, DIM_VENUE

Model umožňuje analyzovať:

výkonnosť tímov,

porovnanie súťaží,

produktivitu štadiónov,

vývoj skóre v čase.

Star Schema diagram

<img width="753" height="653" alt="DT_Projekt" src="https://github.com/user-attachments/assets/137a91c6-10fb-4b1e-aa81-d5ec95f63eba" />

Popis tabuliek
⭐ FACT_GAME_RESULTS
Primárny kľúč: game_uuid + team_key  
Cudzie kľúče: date_key, team_key, competition_key, venue_key

Metriky:

-runs_scored

-runs_conceded

-total_runs

-is_win / is_loss / is_draw

Window functions (povinné):

-SUM() OVER → cumulative_runs_scored

-LAG() OVER → previous_game_runs_scored

-ROW_NUMBER() OVER → game_sequence_number

⭐ DIM_DATE
-date_key (PK)

-year

-month

-day
-SCD typ: Type 0

⭐ DIM_TEAM
-team_key (PK)

-team_name

-team_short_name
-SCD typ: Type 1

⭐ DIM_COMPETITION
-competition_key (PK)

-competition

-season

-region

-country

-country_code
-SCD typ: Type 1

⭐ DIM_VENUE
-venue_key (PK)

-venue

-region

-country

-country_code
-SCD typ: Type 1

3️⃣ ELT proces v Snowflake
📥 Extract
Dáta pochádzajú zo Snowflake Marketplace:

Code
OPTA_DATA_BASEBALL_SCHEDULE_AND_RESULTS_DATA__SAMPLE.BASEBALL.FIXTURES
Staging RAW
sql:
    
    CREATE OR REPLACE TABLE STG_FIXTURES_RAW AS
    SELECT *
    FROM OPTA_DATA_BASEBALL_SCHEDULE_AND_RESULTS_DATA__SAMPLE.BASEBALL.FIXTURES;
📤 Load
Čistenie dát
sql:

    CREATE OR REPLACE TABLE STG_FIXTURES_CLEAN AS
    SELECT
        GAME_UUID          AS game_uuid,
        REGION_UUID        AS region_uuid,
        REGION             AS region,
        COUNTRY_UUID       AS country_uuid,
        COUNTRY            AS country,
        COUNTRY_CODE       AS country_code,
        COMPETITION_UUID   AS competition_uuid,
        COMPETITION        AS competition,
        SEASON_UUID        AS season_uuid,
        SEASON             AS season,
        ROUND              AS round,
        DATE_TIME          AS game_datetime,
        HOME_UUID          AS home_team_uuid,
        HOME               AS home_team,
        HOME_SHORT         AS home_team_short,
        AWAY_UUID          AS away_team_uuid,
        AWAY               AS away_team,
        AWAY_SHORT         AS away_team_short,
        HOME_SCORE         AS home_score,
        AWAY_SCORE         AS away_score,
        VENUE_UUID         AS venue_uuid,
        VENUE              AS venue,
        STATUS             AS status
    FROM STG_FIXTURES_RAW
    WHERE HOME_SCORE IS NOT NULL
      AND AWAY_SCORE IS NOT NULL;
Deduplikácia
sql:
    
    CREATE OR REPLACE TABLE STG_FIXTURES_DEDUP AS
    SELECT *
    FROM (
        SELECT
            *,
            ROW_NUMBER() OVER (
                PARTITION BY game_uuid, game_datetime
                ORDER BY game_datetime DESC
            ) AS rn
        FROM STG_FIXTURES_CLEAN
    )
    WHERE rn = 1;
⚙️ Transform
DIM_DATE
sql:

    CREATE OR REPLACE TABLE DIM_DATE AS
    SELECT DISTINCT
        CAST(game_datetime AS DATE)          AS date_key,
        YEAR(game_datetime)                  AS year,
        MONTH(game_datetime)                 AS month,
        DAY(game_datetime)                   AS day
    FROM STG_FIXTURES_DEDUP;
DIM_TEAM
sql:

    CREATE OR REPLACE TABLE DIM_TEAM AS
    SELECT DISTINCT
        home_team_uuid   AS team_key,
        home_team        AS team_name,
        home_team_short  AS team_short_name
    FROM STG_FIXTURES_DEDUP
    UNION
    SELECT DISTINCT
        away_team_uuid   AS team_key,
        away_team        AS team_name,
        away_team_short  AS team_short_name
    FROM STG_FIXTURES_DEDUP;
DIM_COMPETITION
sql:

    CREATE OR REPLACE TABLE DIM_COMPETITION AS
    SELECT DISTINCT
        competition_uuid     AS competition_key,
        competition,
        season_uuid,
        season,
        region,
        country,
        country_code
    FROM STG_FIXTURES_DEDUP;
DIM_VENUE
sql:

    CREATE OR REPLACE TABLE DIM_VENUE AS
    SELECT DISTINCT
        venue_uuid   AS venue_key,
        venue,
        region,
        country,
        country_code
    FROM STG_FIXTURES_DEDUP;
FACT_GAME_RESULTS (s window functions)
sql:

    CREATE OR REPLACE TABLE FACT_GAME_RESULTS AS
    WITH BASE AS (

    SELECT
        f.game_uuid,
        CAST(f.game_datetime AS DATE)          AS date_key,
        f.competition_uuid                     AS competition_key,
        f.home_team_uuid                       AS team_key,
        f.venue_uuid                           AS venue_key,
        'HOME'                                 AS side,
        f.home_score                           AS runs_scored,
        f.away_score                           AS runs_conceded,
        (f.home_score + f.away_score)          AS total_runs,
        CASE
            WHEN f.home_score > f.away_score THEN 1
            ELSE 0
        END                                    AS is_win,
        CASE
            WHEN f.home_score < f.away_score THEN 1
            ELSE 0
        END                                    AS is_loss,
        CASE
            WHEN f.home_score = f.away_score THEN 1
            ELSE 0
        END                                    AS is_draw
    FROM STG_FIXTURES_DEDUP f

    UNION ALL

    SELECT
        f.game_uuid,
        CAST(f.game_datetime AS DATE)          AS date_key,
        f.competition_uuid                     AS competition_key,
        f.away_team_uuid                       AS team_key,
        f.venue_uuid                           AS venue_key,
        'AWAY'                                 AS side,
        f.away_score                           AS runs_scored,
        f.home_score                           AS runs_conceded,
        (f.home_score + f.away_score)          AS total_runs,
        CASE
            WHEN f.away_score > f.home_score THEN 1
            ELSE 0
        END                                    AS is_win,
        CASE
            WHEN f.away_score < f.home_score THEN 1
            ELSE 0
        END                                    AS is_loss,
        CASE
            WHEN f.away_score = f.home_score THEN 1
            ELSE 0
        END                                    AS is_draw
    FROM STG_FIXTURES_DEDUP f
    ),
    ENRICHED AS (
    SELECT
        b.*,

        SUM(b.runs_scored) OVER (
            PARTITION BY b.team_key, b.competition_key
            ORDER BY b.date_key, b.game_uuid
        ) AS cumulative_runs_scored,

        LAG(b.runs_scored) OVER (
            PARTITION BY b.team_key, b.competition_key
            ORDER BY b.date_key, b.game_uuid
        ) AS previous_game_runs_scored,

        ROW_NUMBER() OVER (
            PARTITION BY b.team_key, b.competition_key
            ORDER BY b.date_key, b.game_uuid
        ) AS game_sequence_number

    FROM BASE b
    )
    SELECT *
    FROM ENRICHED;


⭐ Vizualizácia 1: Vývoj skóre tímu v čase
SQL
sql:
    
    SELECT
        d.date_key,
        t.team_name,
        f.runs_scored,
        f.cumulative_runs_scored
    FROM FACT_GAME_RESULTS f
    JOIN DIM_TEAM t
        ON f.team_key = t.team_key
    JOIN DIM_DATE d
        ON f.date_key = d.date_key
    WHERE t.team_name = 'Tokyo Yakult Swallows'
    ORDER BY d.date_key;
Interpretácia
Tento graf ukazuje, ako sa menil výkon tímu Tokyo Yakult Swallows počas sezóny.
Hodnota runs_scored zobrazuje skóre v jednotlivých zápasoch, zatiaľ čo cumulative_runs_scored ukazuje kumulatívny trend.
Graf umožňuje identifikovať obdobia zlepšenia alebo poklesu formy.

Obrázok:

<img width="2560" height="1450" alt="Graf-1" src="https://github.com/user-attachments/assets/c27835aa-f863-4776-8bfb-e3b8cfdc1250" />

⭐ Vizualizácia 2: Poradie tímov podľa počtu výhier
SQL
sql

    SELECT
        t.team_name,
        SUM(f.is_win) AS total_wins
    FROM FACT_GAME_RESULTS f
    JOIN DIM_TEAM t
        ON f.team_key = t.team_key
    GROUP BY t.team_name
    ORDER BY total_wins DESC;
Interpretácia
Graf zobrazuje rebríček tímov podľa počtu výhier.
Umožňuje rýchlo identifikovať najúspešnejšie tímy v súťaži a porovnať ich výkonnosť.
Je vhodný pre bar chart alebo column chart.

Obrázok:

<img width="2560" height="1392" alt="Graf-2" src="https://github.com/user-attachments/assets/abfd0ba8-23c8-4a7a-88b7-abb4645dd641" />

⭐ Vizualizácia 3: Počet odohraných zápasov podľa dátumu
SQL
sql

    SELECT
        d.date_key,
        COUNT(*) AS games_played
    FROM FACT_GAME_RESULTS f
    JOIN DIM_DATE d
        ON f.date_key = d.date_key
    GROUP BY d.date_key
    ORDER BY d.date_key;
Interpretácia
Graf ukazuje, koľko zápasov sa odohralo v jednotlivých dňoch.
Pomáha identifikovať dni s najväčšou zápasovou aktivitou a odhaliť prípadné sezónne vzorce.

Obrázok:

<img width="2560" height="1392" alt="Graf-3" src="https://github.com/user-attachments/assets/5cf57b10-270d-43fc-9e4e-2a0a53d37413" />


⭐ Vizualizácia 4: Priemerné skóre podľa dňa v týždni
SQL
sql

    SELECT
        t.team_name,
        DAYOFWEEK(d.date_key) AS weekday,
        AVG(f.runs_scored) AS avg_runs
    FROM FACT_GAME_RESULTS f
    JOIN DIM_TEAM t
        ON f.team_key = t.team_key
    JOIN DIM_DATE d
        ON f.date_key = d.date_key
    GROUP BY t.team_name, weekday
    ORDER BY t.team_name, weekday;
Interpretácia
Táto vizualizácia ukazuje, ako sa mení priemerné skóre tímov podľa dňa v týždni.
Pomáha odhaliť, či tímy dosahujú lepšie výsledky cez víkend alebo počas pracovných dní.
Je vhodná pre heatmapu alebo grouped bar chart.

Obrázok:

<img width="2560" height="1392" alt="Graf-4" src="https://github.com/user-attachments/assets/b630842a-48c6-4031-b889-c62dab52db54" />

⭐ Vizualizácia 5: Najproduktívnejšie štadióny podľa počtu bodov
SQL
sql

    SELECT
        v.venue,
        SUM(f.total_runs) AS total_runs_at_venue
    FROM FACT_GAME_RESULTS f
    JOIN DIM_VENUE v
        ON f.venue_key = v.venue_key
    GROUP BY v.venue
    ORDER BY total_runs_at_venue DESC;
Interpretácia
Graf porovnáva štadióny podľa celkového počtu bodov, ktoré na nich padli.
Umožňuje identifikovať „najofenzívnejšie“ štadióny, kde zápasy bývajú najproduktívnejšie.

Obrázok:

<img width="2560" height="1392" alt="Graf-5" src="https://github.com/user-attachments/assets/a26291cd-8a7a-4326-bc8c-904ffd0d71c5" />


--------------------------------------------------------------------
Autor:Kristóf Kovács
--------------------------------------------------------------------
