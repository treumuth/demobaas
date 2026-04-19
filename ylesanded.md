# Ülesanded

Siin on 10 ülesannet, mis põhinevad meie 50 tabeliga *EttevotteLahendus* andmebaasil. Nende lahendamiseks läheb vaja mitme tabeli sidumist (`JOIN`), alampäringuid (`Subquery`), agregeerimisfunktsioone, aknafunktsioone (`Window functions`) ja andmestruktuuri muutmist (`DDL` ja `DML`).

## Ülesanded

### 1. Iga osakonna suurima palgaga töötaja (Analüütiline päring)
Koosta päring, mis leiab iga osakonna töötaja(d), kes teenib selles osakonnas hetkel kõige suuremat brutopalka. 
**Vihjed:** 
- Tabelid: `tootajad`, `osakonnad`, `toolepingud`.
- Arvesta lepinguid ja nendel määratud palka (brutopalk). 
- Kasuks tulevad kas `CTE` (Common Table Expression) ja alampäring või edasijõudnute `RANK()` / `MAX()` aknafunktsioonid (Window function).
- Väljasta: osakonna nimi, töötaja ees- ja perenimi ning brutopalk.

### 2. "Magavad" kliendid (Kliendianalüüs)
Leia kliendid, kellega on küll suheldud (neil on kirjed tabelis `kliendisuhtlus`), kuid kes ei ole viimase 12 kuu jooksul teinud ühtegi tellimust (või ei ole kunagi tellinud).
**Vihjed:**
- Tabelid: `kliendid`, `kliendisuhtlus`, `tellimused`.
- Kasuta `LEFT JOIN`, `NOT IN` või `NOT EXISTS` lauseid tellimuste tabeli kontrollimiseks.
- Kuupäevade võrdlemisel kasuta funktsioone nagu `CURRENT_DATE()` ja `INTERVAL 1 YEAR`.

### 3. Toodete kasumimarginaali TOP 5 (Agregeerimine ja seosed)
Leia 5 toodet, millel on süsteemis kõige suurem prognoositav kasumimarginaal. Marginaali arvutamiseks võta toote süsteemne `baashind` ja lahuta sellest kõigi antud toote tarnijate keskmine `ostuhind`.
**Vihjed:**
- Tabelid: `tooted`, `toodete_tarnijad`.
- Grupeeri tarnijate hinnad toodete kaupa (`GROUP BY`) ja arvuta iga toote keskmine ostuhind (`AVG`).
- Järjesta saadud vahe (`baashind - keskmine ostuhind`) kahanevalt ja piira tulemust (`LIMIT 5`).
- Väljasta: toote kood, nimetus, baashind, oodatav ostuhind ja arvutatud marginaal.

### 4. Tugipiletite lahendusaja analüüs (Kuupäevade matemaatika)
Arvuta tugipiletite lahendamise kiirus: kui kaua aega kulub pileti registreerimisest (esimese sõnumi kellaaeg) selle lahendamiseni (viimase sõnumi kellaaeg). Rühmita tulemused prioriteetide kaupa koondtabelisse, arvestades ainult "Lahendatud" staatusega pileteid.
**Vihjed:**
- Tabelid: `tugipiletid`, `tugipiletite_prioriteedid`, `tugipiletite_sonumid`, `tugipiletite_staatused`.
- Leia lahendatud piletite puhul esimese (`MIN(aeg)`) ja viimase (`MAX(aeg)`) sõnumi vahe ning rühmita need.
- Kasuta kuupäevade arvutamiseks funktsiooni, näiteks `TIMESTAMPDIFF(HOUR, algus, lopp)`.
- Väljasta: prioriteedi nimetus ja nendesse piletitesse kulunud keskmine lahendusaeg tundides.

### 5. Keerukas tellimuste koondraport (Mitmekordsed seosed ja CASE WHEN)
Koosta klientide kohta koondtabel, mis kuvaks finantsosakonnale ühel real lühikokkuvõtte:
- kliendi täisnimi ja e-post.
- kõikide tema tellimuste koguarv.
- suurtellimuste arv: tellimused, mille `kogusumma` on üle 100€ (`CASE WHEN`).
- tellimuste kogusumma rahalises väärtuses.
- sooduskupongide kasutusprotsent (mitmel protsendil tema tellimustest oli kaasas ostukorvi kupong tabelist `tellimuse_kupongid`).
**Vihjed:**
- Tuleb kasutada mitmeid `LEFT JOIN` seoseid (nt tellimuste ja kupongide vahel).
- Suurtellimuste arvu leidmiseks kasuta: `SUM(CASE WHEN tellimused.kogusumma > 100 THEN 1 ELSE 0 END)`.
- Protsendi arvutamiseks: `(COUNT(kupongid) / COUNT(tellimused)) * 100`.

### 6. Skeemi muutmine: Väljastatud seadmete loend (DDL ja seosed)
IT-osakond peab hakkama kaardistama, milline töötaja millist riistvara täpselt kasutab. 
Loo andmebaasi uus vahetabel nimega `valjastatud_seadmed`, mille abil saab jälgida, millisele töötajale on milline seade ja millisel ajaperioodil väljastatud.
**Vihjed:**
- Vajalikud veerud: `id` (PK, auto increment), `tootaja_id` (FK), `seade_id` (FK), `valjastamise_kuupaev`, `tagastamise_kuupaev` ning vabateksti väli märkuste jaoks.
- Kirjuta korrektne `CREATE TABLE` lause asjakohaste `FOREIGN KEY` piirangutega tabelitele `tootajad` ja `seadmed`.

### 7. Skeemi muutmine ja massiline andmete uuendamine (DDL + UPDATE)
Veebipoe suure koormuse tõttu ei soovita enam iga kliendi puhul kõiki tellimusi reaalajas uuesti arvutada.
Sinu ülesanne on andmebaasi uuendada ja salvestada kogusumma puhverveerg (caching).
- Samm A: Lisa tabelile `kliendid` uus veerg: `tellimuste_kogusumma` (DECIMAL tüübiga, vaikimisi väärtus 0.00).
- Samm B: Kirjuta `UPDATE` lause, mis summeerib iga kliendi olemasolevad tellimused ja kirjutab saadud väärtuse tema profiilile uude veergu.
**Vihjed:**
- Uuri andmebaasi dokumentatsioonist `ALTER TABLE` käsku.
- Värskendamiseks saad kasutada struktuuri: `UPDATE kliendid SET tellimuste_kogusumma = (SELECT SUM... WHERE...)`.

### 8. Laoseisu audit (Anomaaliate tuvastamine laos, HAVING otsingud)
Laos on tekkinud segadus ja inventuuri jaoks on vaja aruannet.
Kirjuta päring, mis toob välja kõik tooted ja tsoonid, kus süsteemi aktiivne laoseis (`laoseis` tabeli `kogus`) **ei kattu** `lao_liikumised` tabeli ajalooga (kus sissetulekute ja väljaminekute summeerimisel peaks tekkima identne tegelik laojääk).
**Vihjed:**
- Tabelid: `lao_tsoonid`, `laoseis`, `lao_liikumised`.
- Ajalootabelis grupeeri kirjed toote ning tsooni kaupa (`GROUP BY`) ja arvuta liikumiste kogusumma (`SUM(lao_liikumised.kogus)`).
- Erinevuse leidmiseks kasuta: `HAVING SUM(lao_liikumised.kogus) <> laoseis.kogus`.

### 9. Andmete kompleksne püsivaade (VIEW & DQL)
Süsteem peab juhatajale pakkuma lihtsat igapäevast aruannet.
Selle asemel, et käivitada iga kord pikka päringut, loo andmebaasi püsiv vaade (VIEW) nimega `vw_pohjalik_projektiraport`. See peab juhatajale näitama koondarvutusi:
- projekti ID ja nimetus.
- peamise kliendi nimi.
- mitu ülesannet antud projektil kokku on.
- mitu reaalset töötundi on meeskond nendesse ülesannetesse raporteerinud (vaata tabelit `ylesande_tooaeg`).
**Vihjed:**
- Kirjuta testitud `SELECT` päring koos grupeerimisega (`GROUP BY`).
- Salvesta päring vaatena, kasutades süntaksit: `CREATE OR REPLACE VIEW vw_pohjalik_projektiraport AS SELECT ...`.

### 10. Andmebaasi kaitse (TRIGGER)
Ettevõte soovib vältida raamatupidamise sisestusvigu – tuleviku väljamakseid ei tohi süsteemi enneaegselt salvestada.
Loo andmebaasi päästik (`TRIGGER`), mis blokeerib palgalogi kande loomise, kui sisestatav kuupäev asub tulevikus.
**Vihjed:**
- Loo päästik, mis reageerib sündmusele `BEFORE INSERT ON palgalogi`. 
- Määra päästik käivituma iga rea kohta (`FOR EACH ROW`) ja kontrolli uut väärtust `NEW.maksekuupaev`.
- Andmebaasis vea esilekutsumise süntaks on: `SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Palgalogi kannet ei saa tulevikku registreerida!';`.
