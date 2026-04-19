# Õppeotstarbeline 50-tabeliline MariaDB andmebaas

Sisaldab Eesti ettevõtte haldussüsteemi (ERP/CRM) demobaasi. Süsteem loodi spetsiaalselt andmebaaside ja SQL-keele õpetamiseks eestikeelsete näidete peal ning katab kõik levinumad seosed, andmetüübid ja struktuurid.

## Struktuur

Baas on jaotatud 5 peamisesse loogilisse moodulisse (täpselt 50 tabelit):
1. **Personal ja ettevõte:** ettevõtted, osakonnad, töötajad, palgad, lepingud.
2. **Kliendihaldus (CRM):** kliendid, aadressid, kontaktisikud, klienditugi, must nimekiri.
3. **Tooteinfo ja laondus:** tooted (SKU/EAN), kategooriad, brändid, laod, tsoonid, laoseis.
4. **Müük ja arveldus:** tellimused, makseviisid, arved, sooduskupongid.
5. **Tugi, projektid, hooldus:** projektid, tundide aruandlus, seadmete register ja tugipiletid.

## Failide ülevaade

- [`create_tables.sql`](create_tables.sql) — Sisaldab andmebaasi skeemi loomise (`CREATE TABLE`) käske koos põhjalike eestikeelsete relatsioonide ja definitsioonide vihjetega (`COMMENT`). 

- [`andmed.sql`](andmed.sql) — andmete sisestamine (vt kirjete arvu allpool).

- [`ylesanded.md`](ylesanded.md) — kümme praktilist SQL ülesannet harjutamiseks.

### Andmebaasi import

Ava MySQL terminal (või oma andmebaasi haldusprogramm, nt DBeaver, HeidiSQL, phpMyAdmin) ja käivita:

```bash
mysql -u root -p < create_tables.sql
mysql -u root -p EttevotteLahendus < andmed.sql
```

## Tabelite suurused (orienteeruv kirjete arv)

Allpool on toodud umbkaudne andmemaht tabelite kaupa pärast baasi täitmist (genereeritud testandmed):

| Tabel | Kirjete arv |
| :--- | :--- |
| **tellimuse_read** | 2940 |
| **arved** | 1000 |
| **tellimused** | 1000 |
| **palgalogi** | 600 |
| **maksed** | 510 |
| **kliendid** | 500 |
| **labipaasu_logid** | 500 |
| **klientide_aadressid** | 500 |
| **kliendisuhtlus** | 400 |
| **tootajate_oskused** | 394 |
| **tugipiletite_sonumid** | 343 |
| **toodete_tarnijad** | 305 |
| **saadetised** | 300 |
| **lao_liikumised** | 271 |
| **laoseis** | 271 |
| **ylesande_tooaeg** | 200 |
| **toolepingud** | 200 |
| **tootajad** | 200 |
| **tugipiletid** | 200 |
| **tooted** | 150 |
| **kontaktisikud** | 150 |
| **tegevuste_logi** | 150 |
| **puudumised** | 150 |
| **kliendikaardid** | 100 |
| **projekti_ylesanded** | 100 |
| **tellimuse_kupongid** | 98 |
| **seadmed** | 50 |
| **seadmete_hooldus** | 34 |
| **projektid** | 20 |
| **must_nimekiri** | 15 |
| **osakonnad** | 12 |
| **brandid** | 10 |
| **tarnijad** | 10 |
| **ametikohad** | 7 |
| **oskused** | 6 |
| **mootuhikud** | 5 |
| **tootekategooriad** | 5 |
| **aadressi_tyybid** | 4 |
| **tellimuse_staatused** | 4 |
| **kupongid** | 3 |
| **suhtluse_tyybid** | 3 |
| **tarneviisid** | 3 |
| **makseviisid** | 3 |
| **tugipiletite_prioriteedid** | 3 |
| **lao_tsoonid** | 3 |
| **tugipiletite_staatused** | 3 |
| **kliendigrupid** | 3 |
| **ettevotted** | 2 |
| **laod** | 2 |
| **susteemi_seaded** | 1 |
| **lojaalsusprogrammid** | 1 |

## Praktilised ülesanded

Oleme koostanud baasi põhjal 10 praktilist SQL ülesannet edasijõudnutele (seoste, alampäringute, agregeerimise ja struktuuri loomise peale).  
👉 **[Vaata ülesandeid siit failist: ylesanded.md](ylesanded.md)**

