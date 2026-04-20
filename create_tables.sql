CREATE DATABASE IF NOT EXISTS EttevotteLahendus DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_estonian_ci;
USE EttevotteLahendus;

-- ==========================================
-- 1. MOODUL: PERSONAL JA ETTEVÕTE
-- ==========================================

CREATE TABLE ettevotted (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nimi VARCHAR(100) NOT NULL COMMENT 'Ettevõtte ärinimi',
    registrikood VARCHAR(20) UNIQUE NOT NULL COMMENT 'Äriregistri kood',
    asutatud DATE COMMENT 'Ettevõtte asutamise kuupäev'
) COMMENT='Sihtasutused ja ettevõtted süsteemis';

CREATE TABLE osakonnad (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ettevote_id INT NOT NULL COMMENT 'Viide ettevõttele',
    nimi VARCHAR(100) NOT NULL COMMENT 'Osakonna nimi (nt IT, HR)',
    FOREIGN KEY (ettevote_id) REFERENCES ettevotted(id) ON DELETE CASCADE
) COMMENT='Ettevõtte struktuuriüksused';

CREATE TABLE ametikohad (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nimetus VARCHAR(100) NOT NULL COMMENT 'Ametikoha nimetus',
    min_palk DECIMAL(10, 2) COMMENT 'Palga alampiir',
    max_palk DECIMAL(10, 2) COMMENT 'Palga ülempiir'
) COMMENT='Asutuses olevad standardsed ametikohad';

CREATE TABLE tootajad (
    id INT AUTO_INCREMENT PRIMARY KEY,
    eesnimi VARCHAR(50) NOT NULL COMMENT 'Töötaja eesnimi',
    perenimi VARCHAR(50) NOT NULL COMMENT 'Töötaja perekonnanimi',
    isikukood VARCHAR(11) UNIQUE NOT NULL COMMENT 'Eesti isikukood',
    epost VARCHAR(100) UNIQUE NOT NULL COMMENT 'Töökoha e-post',
    telefon VARCHAR(20) COMMENT 'Kontakttelefon',
    osakond_id INT COMMENT 'Viide osakonnale',
    ametikoht_id INT COMMENT 'Viide ametikohale',
    palgale_voetud DATE COMMENT 'Töölepingu algus',
    FOREIGN KEY (osakond_id) REFERENCES osakonnad(id),
    FOREIGN KEY (ametikoht_id) REFERENCES ametikohad(id)
) COMMENT='Tuumiktabel: Kõik ettevõtte töötajad';

CREATE TABLE toolepingud (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tootaja_id INT NOT NULL COMMENT 'Viide töötajale',
    lepingu_number VARCHAR(50) UNIQUE NOT NULL COMMENT 'Lepingudokumendi viide',
    alguskuupaev DATE NOT NULL COMMENT 'Kehtivuse algus',
    loppkuupaev DATE COMMENT 'Kehtivuse lõpp (kui tähtajaline)',
    brutopalk DECIMAL(10, 2) NOT NULL COMMENT 'Kuupalk',
    FOREIGN KEY (tootaja_id) REFERENCES tootajad(id) ON DELETE CASCADE
) COMMENT='Töötajate lepingute ajalugu ja aktiivsed lepingud';

CREATE TABLE palgalogi (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tootaja_id INT NOT NULL,
    maksekuupaev DATE NOT NULL COMMENT 'Millal palk välja maksti',
    summa DECIMAL(10, 2) NOT NULL COMMENT 'Väljamakstud netosumma',
    FOREIGN KEY (tootaja_id) REFERENCES tootajad(id)
) COMMENT='Igakuiste palgamaksete register';

CREATE TABLE puudumised (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tootaja_id INT NOT NULL,
    tyyp ENUM('puhkus', 'haigusleht', 'õppepuhkus') NOT NULL COMMENT 'Puudumise põhjus',
    algus DATE NOT NULL,
    lopp DATE NOT NULL,
    FOREIGN KEY (tootaja_id) REFERENCES tootajad(id)
) COMMENT='Register töötajate puhkuste ja haiguste kohta';

CREATE TABLE oskused (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nimetus VARCHAR(50) UNIQUE NOT NULL COMMENT 'Oskuse nimi (nt Python, Raamatupidamine)',
    kategooria VARCHAR(50) COMMENT 'Valdkond'
) COMMENT='Klassifikaator erinevatele kompetentsidele';

CREATE TABLE tootajate_oskused (
    tootaja_id INT NOT NULL,
    oskus_id INT NOT NULL,
    tase ENUM('algaja', 'kesktase', 'ekspert') DEFAULT 'algaja' COMMENT 'Kompetentsi tase',
    PRIMARY KEY (tootaja_id, oskus_id),
    FOREIGN KEY (tootaja_id) REFERENCES tootajad(id) ON DELETE CASCADE,
    FOREIGN KEY (oskus_id) REFERENCES oskused(id) ON DELETE CASCADE
) COMMENT='Seostab töötajad nende oskustega (mitu-mitmele)';

CREATE TABLE labipaasu_logid (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tootaja_id INT NOT NULL,
    aeg DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Sisenemise hetk',
    asukoht VARCHAR(100) COMMENT 'Uks või süsteem, kuhu logiti',
    FOREIGN KEY (tootaja_id) REFERENCES tootajad(id)
) COMMENT='Logib töötajate sisenemisi hoonessse või IT sisevõrku';

-- ==========================================
-- 2. MOODUL: KLIENDIHALDUS (CRM)
-- ==========================================

CREATE TABLE kliendigrupid (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nimetus VARCHAR(50) NOT NULL COMMENT 'Grupi nimi (nt VIP, Eraisik)',
    soodustus_protsent DECIMAL(5, 2) DEFAULT 0.00 COMMENT 'Automaatne allahindlus'
) COMMENT='Klientide klastrid ja nende baassoodustused';

CREATE TABLE kliendid (
    id INT AUTO_INCREMENT PRIMARY KEY,
    grupp_id INT COMMENT 'Viide kliendigrupile',
    tyyp ENUM('eraisik', 'ettevõte') NOT NULL COMMENT 'Kliendi juriidiline vorm',
    taisnimi VARCHAR(150) NOT NULL COMMENT 'Ees- ja perenimi või ärinimi',
    registrikood VARCHAR(20) UNIQUE COMMENT 'Eraisikukood või asutuse reg nr',
    epost VARCHAR(100) COMMENT 'Peamine kontakt e-post',
    telefon VARCHAR(20) COMMENT 'Peamine kontakttelefon',
    lisatud DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (grupp_id) REFERENCES kliendigrupid(id)
) COMMENT='Tuumiktabel: Ostjad ja partnerid';

CREATE TABLE aadressi_tyybid (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nimetus VARCHAR(50) NOT NULL COMMENT 'Nt. Juriidiline, Tarne, Arveldus'
) COMMENT='Klassifikaator aadresside eesmärkide eristamiseks';

CREATE TABLE klientide_aadressid (
    id INT AUTO_INCREMENT PRIMARY KEY,
    klient_id INT NOT NULL,
    tyyp_id INT NOT NULL,
    maakond VARCHAR(50) COMMENT 'Eesti maakonnad',
    asula VARCHAR(100) COMMENT 'Linn, vald või küla',
    tanav_maja VARCHAR(255) COMMENT 'Tänava nimi ja maja number',
    postikoht VARCHAR(10) COMMENT 'Postiindeks',
    FOREIGN KEY (klient_id) REFERENCES kliendid(id) ON DELETE CASCADE,
    FOREIGN KEY (tyyp_id) REFERENCES aadressi_tyybid(id)
) COMMENT='Klientidega seotud asukohad (igal võib olla mitu)';

CREATE TABLE kontaktisikud (
    id INT AUTO_INCREMENT PRIMARY KEY,
    klient_id INT NOT NULL COMMENT 'Ettevõttest kliendi id',
    eesnimi VARCHAR(50) NOT NULL,
    perenimi VARCHAR(50) NOT NULL,
    amet VARCHAR(100) COMMENT 'Kliendi esindaja amet',
    epost VARCHAR(100),
    telefon VARCHAR(20),
    FOREIGN KEY (klient_id) REFERENCES kliendid(id) ON DELETE CASCADE
) COMMENT='B2B klientide esindajad';

CREATE TABLE suhtluse_tyybid (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nimetus VARCHAR(50) NOT NULL COMMENT 'Nt. Kõne, E-kiri, Kohtumine'
) COMMENT='Suhtluskanalite klassifikaator CRM jaoks';

CREATE TABLE kliendisuhtlus (
    id INT AUTO_INCREMENT PRIMARY KEY,
    klient_id INT NOT NULL,
    tootaja_id INT NOT NULL COMMENT 'Milline müügiesindaja tegeles',
    tyyp_id INT NOT NULL,
    kuupaev DATETIME DEFAULT CURRENT_TIMESTAMP,
    sisu TEXT COMMENT 'Suhtluse lühikokkuvõte',
    FOREIGN KEY (klient_id) REFERENCES kliendid(id),
    FOREIGN KEY (tootaja_id) REFERENCES tootajad(id),
    FOREIGN KEY (tyyp_id) REFERENCES suhtluse_tyybid(id)
) COMMENT='CRM ajalugu: kõik kontaktipunktid lahendatud teemadega';

CREATE TABLE lojaalsusprogrammid (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nimetus VARCHAR(100) NOT NULL,
    punktide_kordaja DECIMAL(3, 2) DEFAULT 1.0 COMMENT 'Kuidas punkte arvutatakse'
) COMMENT='Turundusprogrammide definitsioonid';

CREATE TABLE kliendikaardid (
    triipkood VARCHAR(20) PRIMARY KEY COMMENT 'Füüsilise kaardi nr',
    klient_id INT NOT NULL,
    programm_id INT NOT NULL,
    punktid INT DEFAULT 0 COMMENT 'Kogunenud boonuspunktid',
    FOREIGN KEY (klient_id) REFERENCES kliendid(id),
    FOREIGN KEY (programm_id) REFERENCES lojaalsusprogrammid(id)
) COMMENT='Väljastatud allahindlus- või boonuskaardid kliendile';

CREATE TABLE must_nimekiri (
    id INT AUTO_INCREMENT PRIMARY KEY,
    klient_id INT UNIQUE NOT NULL,
    pohjus TEXT COMMENT 'Võlgnevus vms',
    lisatud DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (klient_id) REFERENCES kliendid(id)
) COMMENT='Probleemsed kliendid, kellele krediiti ei anta';

-- ==========================================
-- 3. MOODUL: PIM ("product information management" ehk tooteinformatsiooni haldus) JA LAONDUS
-- ==========================================

CREATE TABLE mootuhikud (
    id INT AUTO_INCREMENT PRIMARY KEY,
    lyhend VARCHAR(10) NOT NULL COMMENT 'Nt tk, kg, liiter'
) COMMENT='Standartsed kauba baasmõõtühikud';

CREATE TABLE tootekategooriad (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ylemkategooria_id INT NULL COMMENT 'Hierarhia (parent)',
    nimetus VARCHAR(100) NOT NULL,
    FOREIGN KEY (ylemkategooria_id) REFERENCES tootekategooriad(id)
) COMMENT='Kaubagruppide puukataloog';

CREATE TABLE brandid (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nimi VARCHAR(100) NOT NULL COMMENT 'Kaubamärk',
    paaritolu_riik VARCHAR(50)
) COMMENT='Tootjate märgid';

CREATE TABLE tooted (
    id INT AUTO_INCREMENT PRIMARY KEY,
    kategooria_id INT,
    brand_id INT,
    uhik_id INT NOT NULL,
    tootekood VARCHAR(50) UNIQUE NOT NULL COMMENT 'SKU',
    ribakood VARCHAR(13) UNIQUE COMMENT 'EAN',
    nimetus VARCHAR(255) NOT NULL COMMENT 'Täpne toote nimi',
    baashind DECIMAL(10, 2) NOT NULL COMMENT 'Myygihind käibemaksuta',
    FOREIGN KEY (kategooria_id) REFERENCES tootekategooriad(id),
    FOREIGN KEY (brand_id) REFERENCES brandid(id),
    FOREIGN KEY (uhik_id) REFERENCES mootuhikud(id)
) COMMENT='Põhikataloog kõikide müüdavate toodetega';

CREATE TABLE tarnijad (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nimi VARCHAR(150) NOT NULL,
    kontaktisik VARCHAR(100),
    epost VARCHAR(100)
) COMMENT='Partnerid, kellelt kaupa ostetakse varude täiendamiseks';

CREATE TABLE toodete_tarnijad (
    toode_id INT NOT NULL,
    tarnija_id INT NOT NULL,
    ostuhind DECIMAL(10, 2) COMMENT 'Hind edasimyyjale',
    PRIMARY KEY (toode_id, tarnija_id),
    FOREIGN KEY (toode_id) REFERENCES tooted(id) ON DELETE CASCADE,
    FOREIGN KEY (tarnija_id) REFERENCES tarnijad(id) ON DELETE CASCADE
) COMMENT='Millist kaupa milliselt tarnijalt ja mis hinnaga saame';

CREATE TABLE laod (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nimi VARCHAR(100) NOT NULL COMMENT 'Lao asukoht (nt Pealadu Loo)',
    maakond VARCHAR(50)
) COMMENT='Füüsilised müügi- ja logistikapunktid';

CREATE TABLE lao_tsoonid (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ladu_id INT NOT NULL,
    kood VARCHAR(50) NOT NULL COMMENT 'Nt A-Riiul, Külmik',
    FOREIGN KEY (ladu_id) REFERENCES laod(id) ON DELETE CASCADE
) COMMENT='Geograafiline jaotus ühe lao sees (riiulid)';

CREATE TABLE laoseis (
    toode_id INT NOT NULL,
    tsoon_id INT NOT NULL,
    kogus DECIMAL(12, 3) DEFAULT 0 COMMENT 'Füüsiliselt tsoonis asetsev kogus',
    PRIMARY KEY (toode_id, tsoon_id),
    FOREIGN KEY (toode_id) REFERENCES tooted(id),
    FOREIGN KEY (tsoon_id) REFERENCES lao_tsoonid(id)
) COMMENT='Kvantitatiivne ülevaade inventarist antud ajahetkel';

CREATE TABLE lao_liikumised (
    id INT AUTO_INCREMENT PRIMARY KEY,
    toode_id INT NOT NULL,
    tsoon_id INT NOT NULL COMMENT 'Kuhu või kust kaup liikus',
    kogus DECIMAL(12, 3) NOT NULL COMMENT 'Positiivne: lisandus, negatiivne: kanti maha',
    aeg DATETIME DEFAULT CURRENT_TIMESTAMP,
    pohjus ENUM('ost', 'myyk', 'inventuur', 'praak') NOT NULL,
    FOREIGN KEY (toode_id) REFERENCES tooted(id),
    FOREIGN KEY (tsoon_id) REFERENCES lao_tsoonid(id)
) COMMENT='Täielik audit-logi kõikidest kaupade lahkumistest ja saabumistest';

-- ==========================================
-- 4. MOODUL: MÜÜK JA ARVELDUS
-- ==========================================

CREATE TABLE tellimuse_staatused (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nimetus VARCHAR(50) NOT NULL COMMENT 'Nt. Uus, Komplekteerimisel, Saadetud'
) COMMENT='Tellimuste elutsükli sammud';

CREATE TABLE tarneviisid (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nimetus VARCHAR(50) NOT NULL COMMENT 'Nt Kuller, Pakiautomaat',
    baashind DECIMAL(10, 2) DEFAULT 0.00
) COMMENT='Klientide seotust lahendavad logistikavalikud';

CREATE TABLE tellimused (
    id INT AUTO_INCREMENT PRIMARY KEY,
    klient_id INT NOT NULL,
    staatus_id INT NOT NULL,
    tarneviis_id INT,
    aeg DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Ostu sooritamise moment',
    kogusumma DECIMAL(15, 2) DEFAULT 0.00 COMMENT 'Kogu arve summa KM-ga',
    FOREIGN KEY (klient_id) REFERENCES kliendid(id),
    FOREIGN KEY (staatus_id) REFERENCES tellimuse_staatused(id),
    FOREIGN KEY (tarneviis_id) REFERENCES tarneviisid(id)
) COMMENT='Kliendi vormistatud ostud e-poest või esindusest';

CREATE TABLE tellimuse_read (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tellimus_id INT NOT NULL,
    toode_id INT NOT NULL,
    kogus INT NOT NULL,
    uhikuhind DECIMAL(15, 2) NOT NULL COMMENT 'Hind ostu sooritamise momendil',
    FOREIGN KEY (tellimus_id) REFERENCES tellimused(id) ON DELETE CASCADE,
    FOREIGN KEY (toode_id) REFERENCES tooted(id)
) COMMENT='Milliseid toodeid telliti (arve rea tase)';

CREATE TABLE makseviisid (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nimetus VARCHAR(50) NOT NULL COMMENT 'Nt SEB Pangalink, Krediitkaart, Sularaha'
) COMMENT='Võimalused ostu eest tasumiseks';

CREATE TABLE arved (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tellimus_id INT UNIQUE NOT NULL COMMENT 'Arve on tavaliselt 1:1 tellimusega',
    number VARCHAR(50) UNIQUE NOT NULL COMMENT 'Raamatupidamislik arve number',
    kuupaev DATE NOT NULL,
    maksetahtaeg DATE NOT NULL,
    tasutud BOOLEAN DEFAULT FALSE COMMENT 'Kas laekumine on süsteemis märgitud?',
    FOREIGN KEY (tellimus_id) REFERENCES tellimused(id)
) COMMENT='Ametlikud finantsdokumendid';

CREATE TABLE maksed (
    id INT AUTO_INCREMENT PRIMARY KEY,
    arve_id INT NOT NULL,
    makseviis_id INT NOT NULL,
    aeg DATETIME DEFAULT CURRENT_TIMESTAMP,
    summa DECIMAL(15, 2) NOT NULL,
    valine_viide VARCHAR(100) COMMENT 'Pangatehingu ID failist',
    FOREIGN KEY (arve_id) REFERENCES arved(id),
    FOREIGN KEY (makseviis_id) REFERENCES makseviisid(id)
) COMMENT='Laekumiste reaalne ajalugu, võib olla osaline';

CREATE TABLE kupongid (
    id INT AUTO_INCREMENT PRIMARY KEY,
    kood VARCHAR(20) UNIQUE NOT NULL COMMENT 'Sooduskood. Nt JÕULUD',
    allahindlus_protsent INT DEFAULT 0 COMMENT 'Soodus %',
    kehtib_kuni DATE
) COMMENT='Kampaaniate koodid soodustuste tegemiseks';

CREATE TABLE tellimuse_kupongid (
    tellimus_id INT NOT NULL,
    kupong_id INT NOT NULL,
    PRIMARY KEY (tellimus_id, kupong_id),
    FOREIGN KEY (tellimus_id) REFERENCES tellimused(id) ON DELETE CASCADE,
    FOREIGN KEY (kupong_id) REFERENCES kupongid(id)
) COMMENT='Seostab tellimused rakendatud sooduskoodidega';

CREATE TABLE saadetised (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tellimus_id INT UNIQUE NOT NULL,
    tracking_kood VARCHAR(100) COMMENT 'Jälgimiskood pakiautomaadis',
    saadetud DATETIME,
    FOREIGN KEY (tellimus_id) REFERENCES tellimused(id)
) COMMENT='Tellimustest vormunud kullersaadetised ja nende andmed';


-- ==========================================
-- 5. MOODUL: PROJEKTID, HOOLDUS, TUGI, SEADED
-- ==========================================

CREATE TABLE projektid (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nimi VARCHAR(150) NOT NULL COMMENT 'Ettevõttesisese või kliendiprojekti nimi',
    klient_id INT NULL COMMENT 'Viide tellijale, kui väline',
    alguskuupaev DATE,
    FOREIGN KEY (klient_id) REFERENCES kliendid(id)
) COMMENT='Tööde kogumikud pikema eesmärgiga';

CREATE TABLE projekti_ylesanded (
    id INT AUTO_INCREMENT PRIMARY KEY,
    projekt_id INT NOT NULL,
    vastutav_tootaja_id INT,
    pealkiri VARCHAR(255) NOT NULL,
    lopptahtaeg DATE,
    valmis BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (projekt_id) REFERENCES projektid(id) ON DELETE CASCADE,
    FOREIGN KEY (vastutav_tootaja_id) REFERENCES tootajad(id)
) COMMENT='Ühe projekti alamülesanded (Kanban tahvli piletid)';

CREATE TABLE ylesande_tooaeg (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ylesanne_id INT NOT NULL,
    tootaja_id INT NOT NULL,
    aeg DATETIME DEFAULT CURRENT_TIMESTAMP,
    kulunud_tunde DECIMAL(5,2) NOT NULL COMMENT 'Aruandlus tehtud töö kohta',
    FOREIGN KEY (ylesanne_id) REFERENCES projekti_ylesanded(id) ON DELETE CASCADE,
    FOREIGN KEY (tootaja_id) REFERENCES tootajad(id)
) COMMENT='Töötajate ajatracking (Timesheet) projektide peale';

CREATE TABLE seadmed (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nimetus VARCHAR(100) NOT NULL COMMENT 'Tootmise seade või tööarvuti',
    inventari_kood VARCHAR(50) UNIQUE,
    ostukuupaev DATE
) COMMENT='Ettevõttesisene põhivara';

CREATE TABLE seadmete_hooldus (
    id INT AUTO_INCREMENT PRIMARY KEY,
    seade_id INT NOT NULL,
    hooldus_kuupaev DATE NOT NULL,
    kirjeldus TEXT COMMENT 'Raport tehtud töödest',
    kulu DECIMAL(10,2),
    FOREIGN KEY (seade_id) REFERENCES seadmed(id) ON DELETE CASCADE
) COMMENT='Põhivara parandus- ja hooldusajalugu';

CREATE TABLE tugipiletite_prioriteedid (
    id INT AUTO_INCREMENT PRIMARY KEY,
    aste INT NOT NULL COMMENT 'Mida väiksem nr, seda kriitilisem',
    nimetus VARCHAR(50) NOT NULL
) COMMENT='Erinevad abipalvete kiiruse astmed: Madal, Keskmine, Kõrge';

CREATE TABLE tugipiletite_staatused (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nimetus VARCHAR(50) NOT NULL COMMENT 'Uus, Töös, Ootel, Lahendatud'
) COMMENT='Tugipiletite vood / ticket statuses';

CREATE TABLE tugipiletid (
    id INT AUTO_INCREMENT PRIMARY KEY,
    klient_id INT NULL COMMENT 'Klient, kes vajas abi',
    tootaja_id INT NULL COMMENT 'Klienditoe agent',
    prioriteet_id INT NOT NULL,
    staatus_id INT NOT NULL,
    pealkiri VARCHAR(255) NOT NULL,
    esitatud DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (klient_id) REFERENCES kliendid(id),
    FOREIGN KEY (tootaja_id) REFERENCES tootajad(id),
    FOREIGN KEY (prioriteet_id) REFERENCES tugipiletite_prioriteedid(id),
    FOREIGN KEY (staatus_id) REFERENCES tugipiletite_staatused(id)
) COMMENT='Helpdesk: Vead, soovid, infopäringud klientidelt ja kolleegidelt';

CREATE TABLE tugipiletite_sonumid (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pilet_id INT NOT NULL,
    kirjutas_tootaja BOOLEAN DEFAULT FALSE COMMENT 'Kas saatis klient või agent?',
    sisu TEXT NOT NULL,
    aeg DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (pilet_id) REFERENCES tugipiletid(id) ON DELETE CASCADE
) COMMENT='Kõik vastused ja arutelud ühe kliendipileti raames';

CREATE TABLE susteemi_seaded (
    kood VARCHAR(50) PRIMARY KEY COMMENT 'Nt SITE_NAME, TAX_RATE',
    vaartus VARCHAR(255) NOT NULL,
    kirjeldus TEXT COMMENT 'Lisainfo adminile'
) COMMENT='Konfiguratsiooni parameetrid rakenduse tööks koodis';

CREATE TABLE tegevuste_logi (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tootaja_id INT NULL,
    tegevus VARCHAR(255) NOT NULL COMMENT 'Mida keegi kuskil muutis',
    aeg DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tootaja_id) REFERENCES tootajad(id)
) COMMENT='Süsteemne turbelogi (Audit Trail)';
