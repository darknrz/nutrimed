-- ============================================================
-- NUTRIMED - INIT.SQL COMPLETO
-- Versión consolidada lista para ejecutar desde cero
-- Enfoque: Perú (con estructura para otros países)
-- Enfermedades: Diabetes T2, Hipertensión, Obesidad,
--               Colesterol alto, Gastritis, Anemia,
--               Enfermedad renal, Gota, Hipotiroidismo
-- ============================================================


-- ────────────────────────────────────────────────────────────
-- 1. TABLA USERS (creación completa)
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
  id                  BIGSERIAL PRIMARY KEY,
  email               VARCHAR(255) UNIQUE NOT NULL,
  username            VARCHAR(100) NOT NULL,
  name                VARCHAR(150),
  picture             TEXT,
  password            VARCHAR(255),
  provider            VARCHAR(10)  NOT NULL DEFAULT 'EMAIL',
  is_active           BOOLEAN      DEFAULT TRUE,
  created_at          TIMESTAMP    DEFAULT NOW(),

  -- campos de onboarding
  onboarding_done     BOOLEAN      DEFAULT FALSE,
  country_code        VARCHAR(3)   DEFAULT 'PE',
  birth_year          INT,
  sex                 VARCHAR(10),
  weight_kg           DECIMAL(5,2),
  height_cm           DECIMAL(5,2),
  activity_level      VARCHAR(20)  DEFAULT 'moderado',
  diet_type           VARCHAR(20)  DEFAULT 'omnivoro',
  health_goal         VARCHAR(30)  DEFAULT 'controlar_enfermedad',
  available_countries TEXT[],
  last_checkin_at     TIMESTAMP
);
-- ────────────────────────────────────────────────────────────
-- 2. TABLA COUNTRIES
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS countries (
  code        VARCHAR(3) PRIMARY KEY,
  name        VARCHAR(100) NOT NULL,
  region      VARCHAR(50),
  is_active   BOOLEAN DEFAULT TRUE
);

INSERT INTO countries (code, name, region) VALUES
  ('PE', 'Perú',           'América del Sur'),
  ('MX', 'México',         'América del Norte'),
  ('CO', 'Colombia',       'América del Sur'),
  ('AR', 'Argentina',      'América del Sur'),
  ('CL', 'Chile',          'América del Sur'),
  ('ES', 'España',         'Europa'),
  ('BO', 'Bolivia',        'América del Sur'),
  ('EC', 'Ecuador',        'América del Sur'),
  ('VE', 'Venezuela',      'América del Sur'),
  ('US', 'Estados Unidos', 'América del Norte')
ON CONFLICT (code) DO NOTHING;


-- ────────────────────────────────────────────────────────────
-- 3. TABLA DISEASES (enfermedades / condiciones)
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS diseases (
  id          BIGSERIAL PRIMARY KEY,
  name        VARCHAR(100) NOT NULL,
  slug        VARCHAR(50)  UNIQUE NOT NULL,
  description TEXT,
  category    VARCHAR(50),
  icon_code   VARCHAR(10),
  is_active   BOOLEAN DEFAULT TRUE
);

INSERT INTO diseases (name, slug, description, category, icon_code, is_active) VALUES
  ('Diabetes tipo 2',         'diabetes_t2',         'Resistencia a la insulina. Requiere control de carbohidratos y azúcares.',          'metabolica',    '🩸', TRUE),
  ('Hipertensión arterial',   'hipertension',        'Presión arterial elevada. Requiere dieta baja en sodio.',                           'cardiovascular','❤️', TRUE),
  ('Colesterol alto',         'colesterol_alto',     'Dislipidemia. Requiere reducir grasas saturadas y trans.',                          'cardiovascular','🫀', TRUE),
  ('Obesidad',                'obesidad',            'IMC > 30. Requiere déficit calórico y alimentos de alta saciedad.',                 'metabolica',    '⚖️', TRUE),
  ('Gastritis / Reflujo',     'gastritis',           'Inflamación gástrica. Requiere evitar alimentos irritantes y ácidos.',              'digestiva',     '🫃', TRUE),
  ('Anemia ferropénica',      'anemia',              'Déficit de hierro. Requiere aumentar alimentos ricos en hierro y vitamina C.',      'hematologica',  '💉', TRUE),
  ('Enfermedad renal crónica','enfermedad_renal',    'Daño renal. Requiere control estricto de potasio, fósforo y proteína.',            'renal',         '🫘', TRUE),
  ('Gota / Hiperuricemia',    'gota',                'Exceso de ácido úrico. Requiere evitar purinas (carnes rojas, mariscos, alcohol).', 'metabolica',    '🦴', TRUE),
  ('Hipotiroidismo',          'hipotiroidismo',      'Tiroides poco activa. Evitar bociógenos en exceso, aumentar selenio y yodo.',       'endocrina',     '🦋', TRUE),
  ('Síndrome metabólico',     'sindrome_metabolico', 'Combinación de obesidad abdominal, dislipidemia, hipertensión y glucosa alta.',     'metabolica',    '🔬', TRUE)
ON CONFLICT (slug) DO NOTHING;


-- ────────────────────────────────────────────────────────────
-- 4. TABLA USER_DISEASES (condiciones del usuario)
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS user_diseases (
  id          BIGSERIAL PRIMARY KEY,
  user_id     BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  disease_id  BIGINT NOT NULL REFERENCES diseases(id),
  since_year  INT,
  is_active   BOOLEAN DEFAULT TRUE,
  severity    VARCHAR(20) DEFAULT 'moderado',
  created_at  TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, disease_id)
);


-- ────────────────────────────────────────────────────────────
-- 5. TABLA INGREDIENTS
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS ingredients (
  id                  BIGSERIAL PRIMARY KEY,
  name                VARCHAR(100) NOT NULL,
  unit                VARCHAR(20)  DEFAULT 'g',
  kcal_per_100g       DECIMAL(6,2),
  glycemic_index      INT,
  sodium_mg           DECIMAL(6,2),
  protein_g           DECIMAL(5,2),
  carbs_g             DECIMAL(5,2),
  fat_g               DECIMAL(5,2),
  fiber_g             DECIMAL(5,2),
  iron_mg             DECIMAL(5,2),
  potassium_mg        DECIMAL(7,2),
  phosphorus_mg       DECIMAL(7,2),
  purines_mg          DECIMAL(7,2),
  is_allergen         BOOLEAN DEFAULT FALSE,
  allergen_type       VARCHAR(50),
  available_countries TEXT[],
  is_active           BOOLEAN DEFAULT TRUE
);

-- GRANOS Y CEREALES
INSERT INTO ingredients (name, kcal_per_100g, glycemic_index, sodium_mg, protein_g, carbs_g, fat_g, fiber_g, iron_mg, potassium_mg, phosphorus_mg, purines_mg, available_countries) VALUES
  ('Quinoa cocida',            120, 53,  7,   4.4,  21.3, 1.9, 2.8, 1.5,  172,  152,  15, ARRAY['PE','BO','CL','AR','CO','MX','ES','EC','US']),
  ('Arroz integral cocido',    123, 55,  5,   2.6,  25.6, 0.9, 1.8, 0.5,   77,   83,  18, ARRAY['PE','MX','CO','AR','CL','ES','BO','EC','VE','US']),
  ('Avena en hojuelas',        389, 55,  6,  17.0,  66.3, 6.9,10.6, 4.7,  429,  523,  40, ARRAY['PE','MX','CO','AR','CL','ES','BO','EC','VE','US']),
  ('Kiwicha cocida',           371, 45,  5,  14.5,  65.2, 6.5, 6.7, 7.6,  508,  557,  20, ARRAY['PE','BO','EC']),
  ('Lentejas cocidas',         116, 32,  4,   9.0,  20.1, 0.4, 7.9, 3.3,  369,  180,  27, ARRAY['PE','MX','CO','AR','CL','ES','BO','EC','VE','US']),
  ('Frijoles negros cocidos',  132, 30,  1,   8.9,  23.7, 0.5, 8.7, 2.1,  355,  140,  32, ARRAY['PE','MX','CO','AR','CL','ES','BO','EC','VE','US']),
  ('Garbanzo cocido',          164, 28,  7,   8.9,  27.4, 2.6, 7.6, 2.9,  291,  168,  30, ARRAY['PE','MX','CO','AR','CL','ES','BO','EC','VE','US']),
  ('Pan integral',             247, 51,472,   8.9,  47.5, 3.4, 6.9, 2.5,  248,  212,  25, ARRAY['PE','MX','CO','AR','CL','ES','BO','EC','VE','US']);

-- VERDURAS Y TUBÉRCULOS
INSERT INTO ingredients (name, kcal_per_100g, glycemic_index, sodium_mg, protein_g, carbs_g, fat_g, fiber_g, iron_mg, potassium_mg, phosphorus_mg, purines_mg, available_countries) VALUES
  ('Espinaca cruda',            23, 15,  79,  2.9,   3.6, 0.4, 2.2, 2.7,  558,   49,  57, ARRAY['PE','MX','CO','AR','CL','ES','BO','EC','VE','US']),
  ('Brócoli cocido',            35, 10,  41,  2.4,   7.2, 0.4, 2.6, 0.7,  293,   66,  28, ARRAY['PE','MX','CO','AR','CL','ES','BO','EC','VE','US']),
  ('Zanahoria cruda',           41, 35,  69,  0.9,   9.6, 0.2, 2.8, 0.3,  320,   35,   5, ARRAY['PE','MX','CO','AR','CL','ES','BO','EC','VE','US']),
  ('Tomate',                    18, 15,   5,  0.9,   3.9, 0.2, 1.2, 0.3,  237,   24,   4, ARRAY['PE','MX','CO','AR','CL','ES','BO','EC','VE','US']),
  ('Papa blanca cocida',        87, 78,  10,  1.9,  20.1, 0.1, 1.8, 0.3,  379,   44,   6, ARRAY['PE','MX','CO','AR','CL','ES','BO','EC','VE','US']),
  ('Camote / Batata cocida',    90, 63,  36,  2.0,  20.7, 0.1, 3.0, 0.7,  475,   54,   7, ARRAY['PE','MX','CO','AR','CL','ES','BO','EC','VE','US']),
  ('Yuca cocida',              112, 46,  14,  0.9,  26.8, 0.3, 1.8, 0.3,  271,   28,   5, ARRAY['PE','CO','BO','EC','VE','MX']),
  ('Ají amarillo',              26, 15,   7,  1.1,   5.9, 0.3, 1.9, 0.5,  200,   30,  10, ARRAY['PE','BO','EC']),
  ('Cebolla',                   40, 10,   4,  1.1,   9.3, 0.1, 1.7, 0.2,  146,   29,   2, ARRAY['PE','MX','CO','AR','CL','ES','BO','EC','VE','US']),
  ('Ajo',                      149, 30,  17,  6.4,  33.1, 0.5, 2.1, 1.7,  401,  153,  12, ARRAY['PE','MX','CO','AR','CL','ES','BO','EC','VE','US']),
  ('Palta / Aguacate',         160, 10,   7,  2.0,   8.5,14.7, 6.7, 0.6,  485,   52,  19, ARRAY['PE','MX','CO','AR','CL','ES','BO','EC','VE','US']),
  ('Pepino',                    16, 15,   2,  0.7,   3.6, 0.1, 0.5, 0.3,  147,   24,   6, ARRAY['PE','MX','CO','AR','CL','ES','BO','EC','VE','US']),
  ('Apio',                      16, 15,  80,  0.7,   3.0, 0.2, 1.6, 0.2,  260,   24,   8, ARRAY['PE','MX','CO','AR','CL','ES','BO','EC','VE','US']),
  ('Chuño',                    344, 70,  20,  2.6,  79.9, 0.3, 8.4, 1.0,  896,   82,  10, ARRAY['PE','BO','CL','AR']),
  ('Choclo / Maíz cocido',      96, 52,  15,  3.4,  21.0, 1.5, 2.4, 0.5,  270,   89,  24, ARRAY['PE','MX','CO','AR','CL','ES','BO','EC','VE','US']);

-- PROTEÍNAS ANIMALES
INSERT INTO ingredients (name, kcal_per_100g, glycemic_index, sodium_mg, protein_g, carbs_g, fat_g, fiber_g, iron_mg, potassium_mg, phosphorus_mg, purines_mg, is_allergen, allergen_type, available_countries) VALUES
  ('Pollo pechuga cocida', 165, 0,  74, 31.0, 0.0,  3.6, 0.0, 0.7, 256, 220, 175, FALSE, NULL,      ARRAY['PE','MX','CO','AR','CL','ES','BO','EC','VE','US']),
  ('Trucha cocida',        148, 0,  56, 20.8, 0.0,  6.6, 0.0, 0.5, 481, 279, 150, TRUE,  'pescado', ARRAY['PE','CL','AR','BO','EC']),
  ('Atún en agua',         116, 0, 333, 25.5, 0.0,  1.0, 0.0, 1.3, 279, 190, 142, TRUE,  'pescado', ARRAY['PE','MX','CO','AR','CL','ES','BO','EC','VE','US']),
  ('Huevo entero',         155, 0, 124, 12.6, 1.1, 10.6, 0.0, 1.9, 126, 172,  14, TRUE,  'huevo',   ARRAY['PE','MX','CO','AR','CL','ES','BO','EC','VE','US']),
  ('Claras de huevo',       52, 0, 166, 10.9, 0.7,  0.2, 0.0, 0.1, 163,  13,   0, TRUE,  'huevo',   ARRAY['PE','MX','CO','AR','CL','ES','BO','EC','VE','US']),
  ('Res magra cocida',     217, 0,  64, 26.1, 0.0, 12.0, 0.0, 2.5, 318, 198, 280, FALSE, NULL,      ARRAY['PE','MX','CO','AR','CL','ES','BO','EC','VE','US']),
  ('Hígado de res',        175, 0,  82, 27.0, 3.9,  4.9, 0.0, 6.2, 313, 387, 554, FALSE, NULL,      ARRAY['PE','MX','CO','AR','CL','ES','BO','EC','VE','US']),
  ('Cuy cocido',           175, 0,  70, 27.0, 0.0,  6.8, 0.0, 3.5, 330, 250, 160, FALSE, NULL,      ARRAY['PE','BO','EC','CO']);

-- LÁCTEOS
INSERT INTO ingredients (name, kcal_per_100g, glycemic_index, sodium_mg, protein_g, carbs_g, fat_g, fiber_g, iron_mg, potassium_mg, phosphorus_mg, purines_mg, is_allergen, allergen_type, available_countries) VALUES
  ('Yogur natural sin azúcar',  59, 36,  46, 3.5, 3.6, 3.3, 0.0, 0.1, 155, 112, 0, TRUE, 'lactosa', ARRAY['PE','MX','CO','AR','CL','ES','BO','EC','VE','US']),
  ('Queso fresco bajo sal',     98, 27, 300, 7.0, 3.4, 6.5, 0.0, 0.2,  90, 120, 0, TRUE, 'lactosa', ARRAY['PE','MX','CO','AR','CL','ES','BO','EC','VE','US']),
  ('Leche descremada',          34, 32,  44, 3.4, 4.9, 0.1, 0.0, 0.1, 150, 105, 0, TRUE, 'lactosa', ARRAY['PE','MX','CO','AR','CL','ES','BO','EC','VE','US']);

-- FRUTAS
INSERT INTO ingredients (name, kcal_per_100g, glycemic_index, sodium_mg, protein_g, carbs_g, fat_g, fiber_g, iron_mg, potassium_mg, phosphorus_mg, purines_mg, available_countries) VALUES
  ('Plátano de seda',            89, 51,  1, 1.1, 22.8, 0.3,  2.6, 0.3, 358,  22, 12, ARRAY['PE','MX','CO','AR','CL','ES','BO','EC','VE','US']),
  ('Manzana',                    52, 39,  1, 0.3, 13.8, 0.2,  2.4, 0.1, 107,  11,  5, ARRAY['PE','MX','CO','AR','CL','ES','BO','EC','VE','US']),
  ('Papaya',                     43, 59,  8, 0.5, 10.8, 0.3,  1.7, 0.1, 182,  10, 10, ARRAY['PE','MX','CO','BO','EC','VE']),
  ('Maracuyá / Maracuya',        97, 30, 28, 2.2, 23.4, 0.7, 10.4, 1.6, 348,  68, 25, ARRAY['PE','CO','BO','EC','VE','MX']),
  ('Lúcuma en polvo',           329, 25, 10, 4.0, 82.0, 2.4,  1.5, 1.8, 490,  60, 15, ARRAY['PE','CL','BO']),
  ('Arándanos / Blueberries',    57, 53,  1, 0.7, 14.5, 0.3,  2.4, 0.3,  77,  12, 10, ARRAY['PE','MX','CO','AR','CL','ES','US']),
  ('Naranja',                    47, 40,  0, 0.9, 11.8, 0.1,  2.4, 0.1, 181,  14,  9, ARRAY['PE','MX','CO','AR','CL','ES','BO','EC','VE','US']),
  ('Limón',                      29, 20,  2, 1.1,  9.3, 0.3,  2.8, 0.6, 138,  16, 10, ARRAY['PE','MX','CO','AR','CL','ES','BO','EC','VE','US']);

-- GRASAS SALUDABLES Y SEMILLAS
INSERT INTO ingredients (name, kcal_per_100g, glycemic_index, sodium_mg, protein_g, carbs_g, fat_g, fiber_g, iron_mg, potassium_mg, phosphorus_mg, purines_mg, is_allergen, allergen_type, available_countries) VALUES
  ('Aceite de oliva',   884, 0,  0,  0.0,  0.0,100.0,  0.0, 0.6,   1,   0,   0, FALSE, NULL,           ARRAY['PE','MX','CO','AR','CL','ES','BO','EC','VE','US']),
  ('Semillas de chía',  486, 1, 16, 16.5, 42.1, 30.7, 34.4, 7.7, 407, 860,  30, FALSE, NULL,           ARRAY['PE','MX','CO','AR','CL','ES','BO','EC','VE','US']),
  ('Nueces',            654,15,  2, 15.2, 13.7, 65.2,  6.7, 2.9, 441, 346, 100, TRUE,  'frutos_secos', ARRAY['PE','MX','CO','AR','CL','ES','BO','EC','VE','US']),
  ('Maní sin sal',      567,14, 18, 25.8, 16.1, 49.2,  8.5, 4.6, 705, 376, 100, TRUE,  'mani',         ARRAY['PE','MX','CO','AR','CL','ES','BO','EC','VE','US']);

-- CONDIMENTOS Y HIERBAS
INSERT INTO ingredients (name, kcal_per_100g, glycemic_index, sodium_mg, protein_g, carbs_g, fat_g, fiber_g, iron_mg, potassium_mg, phosphorus_mg, purines_mg, available_countries) VALUES
  ('Cúrcuma en polvo',     354, 0, 38,  7.8, 64.9,  9.9, 21.1, 67.8, 2525, 268, 30, ARRAY['PE','MX','CO','AR','CL','ES','BO','EC','VE','US']),
  ('Jengibre fresco',       80, 0, 13,  1.8, 17.8,  0.8,  2.0,  0.6,  415,  34, 10, ARRAY['PE','MX','CO','AR','CL','ES','BO','EC','VE','US']),
  ('Culantro / Cilantro',   23, 0, 46,  2.1,  3.7,  0.5,  2.8,  1.8,  521,  48, 10, ARRAY['PE','MX','CO','AR','CL','ES','BO','EC','VE','US']),
  ('Orégano seco',         265, 0, 25, 11.0, 68.9,  4.3, 42.5, 44.0, 1669, 148, 30, ARRAY['PE','MX','CO','AR','CL','ES','BO','EC','VE','US']);


-- ────────────────────────────────────────────────────────────
-- 6. TABLA DISEASE_RESTRICTIONS
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS disease_restrictions (
  id               BIGSERIAL PRIMARY KEY,
  disease_id       BIGINT NOT NULL REFERENCES diseases(id),
  ingredient_id    BIGINT NOT NULL REFERENCES ingredients(id),
  restriction_type VARCHAR(10) NOT NULL CHECK (restriction_type IN ('AVOID','LIMIT','PREFER')),
  reason           TEXT,
  max_daily_g      DECIMAL(6,2),
  UNIQUE(disease_id, ingredient_id)
);

-- DIABETES T2
INSERT INTO disease_restrictions (disease_id, ingredient_id, restriction_type, reason, max_daily_g)
SELECT d.id, i.id, r.rtype, r.reason, r.max_g::numeric
FROM diseases d, ingredients i,
(VALUES
  ('Papa blanca cocida',   'LIMIT',  'Alto índice glucémico — elevan rápido la glucosa', '100'),
  ('Arroz integral cocido','LIMIT',  'IG moderado — consumir en porciones pequeñas',      '80'),
  ('Plátano de seda',      'LIMIT',  'Alto en azúcares naturales',                        '80'),
  ('Choclo / Maíz cocido', 'LIMIT',  'IG moderado-alto',                                 '100'),
  ('Quinoa cocida',        'PREFER', 'IG bajo, proteína completa, fibra',                 NULL),
  ('Lentejas cocidas',     'PREFER', 'IG bajo, fibra alta, saciedad',                     NULL),
  ('Avena en hojuelas',    'PREFER', 'Beta-glucano regula glucosa postprandial',           NULL),
  ('Brócoli cocido',       'PREFER', 'Bajo en carbos, rico en fibra y cromio',            NULL),
  ('Semillas de chía',     'PREFER', 'Fibra soluble ralentiza absorción de glucosa',       NULL)
) AS r(iname, rtype, reason, max_g)
WHERE d.slug = 'diabetes_t2' AND i.name = r.iname
ON CONFLICT DO NOTHING;

-- HIPERTENSIÓN
INSERT INTO disease_restrictions (disease_id, ingredient_id, restriction_type, reason, max_daily_g)
SELECT d.id, i.id, r.rtype, r.reason, r.max_g::numeric
FROM diseases d, ingredients i,
(VALUES
  ('Pan integral',         'LIMIT',  'Alto en sodio — preferir pan sin sal',              '50'),
  ('Queso fresco bajo sal','LIMIT',  'Contiene sodio — consumir con moderación',          '30'),
  ('Atún en agua',         'LIMIT',  'Sodio del enlatado — lavar antes de consumir',      '80'),
  ('Apio',                 'LIMIT',  'Sodio natural — moderado',                         '150'),
  ('Palta / Aguacate',     'PREFER', 'Potasio y grasas mono-insaturadas bajan presión',   NULL),
  ('Plátano de seda',      'PREFER', 'Rico en potasio — contrarresta el sodio',           NULL),
  ('Quinoa cocida',        'PREFER', 'Bajo en sodio, rico en magnesio',                   NULL),
  ('Espinaca cruda',       'PREFER', 'Rica en potasio, magnesio y nitratos naturales',    NULL),
  ('Semillas de chía',     'PREFER', 'Omega-3, reduce inflamación vascular',              NULL),
  ('Aceite de oliva',      'PREFER', 'Polifenoles reducen presión arterial',              NULL)
) AS r(iname, rtype, reason, max_g)
WHERE d.slug = 'hipertension' AND i.name = r.iname
ON CONFLICT DO NOTHING;

-- COLESTEROL ALTO
INSERT INTO disease_restrictions (disease_id, ingredient_id, restriction_type, reason, max_daily_g)
SELECT d.id, i.id, r.rtype, r.reason, r.max_g::numeric
FROM diseases d, ingredients i,
(VALUES
  ('Res magra cocida',          'LIMIT',  'Grasas saturadas elevan LDL — no más de 2x semana', '100'),
  ('Huevo entero',              'LIMIT',  'Yema rica en colesterol — máx 4 unidades/semana',    '50'),
  ('Nueces',                    'PREFER', 'Omega-3 y fitoesteroles reducen LDL',                NULL),
  ('Avena en hojuelas',         'PREFER', 'Beta-glucano captura colesterol en intestino',        NULL),
  ('Aceite de oliva',           'PREFER', 'Ácido oleico eleva HDL y reduce LDL',                NULL),
  ('Lentejas cocidas',          'PREFER', 'Fibra soluble reduce absorción de colesterol',        NULL),
  ('Semillas de chía',          'PREFER', 'Omega-3 reduce triglicéridos',                        NULL),
  ('Palta / Aguacate',          'PREFER', 'Grasas mono-insaturadas mejoran perfil lipídico',     NULL),
  ('Arándanos / Blueberries',   'PREFER', 'Antocianinas reducen LDL oxidado',                   NULL),
  ('Ajo',                       'PREFER', 'Alicina reduce colesterol total',                     NULL)
) AS r(iname, rtype, reason, max_g)
WHERE d.slug = 'colesterol_alto' AND i.name = r.iname
ON CONFLICT DO NOTHING;

-- GASTRITIS
INSERT INTO disease_restrictions (disease_id, ingredient_id, restriction_type, reason, max_daily_g)
SELECT d.id, i.id, r.rtype, r.reason, r.max_g::numeric
FROM diseases d, ingredients i,
(VALUES
  ('Ají amarillo',             'AVOID',  'Capsaicina irrita la mucosa gástrica',               '0'),
  ('Ajo',                      'LIMIT',  'Puede irritar el estómago vacío',                    '10'),
  ('Cebolla',                  'LIMIT',  'Fructanos causan gases y acidez',                    '30'),
  ('Naranja',                  'LIMIT',  'Ácido cítrico puede aumentar acidez gástrica',        '80'),
  ('Limón',                    'LIMIT',  'Ácido cítrico — evitar en ayunas',                   '20'),
  ('Maracuyá / Maracuya',      'LIMIT',  'Alta acidez — evitar en crisis',                     '50'),
  ('Avena en hojuelas',        'PREFER', 'Mucílago protege la mucosa gástrica',                NULL),
  ('Papa blanca cocida',       'PREFER', 'Almidón calma la acidez',                            NULL),
  ('Plátano de seda',          'PREFER', 'Pectina protege la mucosa gástrica',                 NULL),
  ('Zanahoria cruda',          'PREFER', 'Alcalina, antiinflamatoria',                         NULL),
  ('Jengibre fresco',          'PREFER', 'Antiinflamatorio gástrico natural',                  NULL),
  ('Yogur natural sin azúcar', 'PREFER', 'Probióticos mejoran microbiota gástrica',            NULL)
) AS r(iname, rtype, reason, max_g)
WHERE d.slug = 'gastritis' AND i.name = r.iname
ON CONFLICT DO NOTHING;

-- ANEMIA
INSERT INTO disease_restrictions (disease_id, ingredient_id, restriction_type, reason, max_daily_g)
SELECT d.id, i.id, r.rtype, r.reason, r.max_g::numeric
FROM diseases d, ingredients i,
(VALUES
  ('Espinaca cruda',   'PREFER', 'Rico en hierro no hemo + vitamina C mejora absorción', NULL),
  ('Hígado de res',    'PREFER', 'Hierro hemo de alta biodisponibilidad',                NULL),
  ('Lentejas cocidas', 'PREFER', 'Hierro no hemo + folato',                              NULL),
  ('Kiwicha cocida',   'PREFER', 'Rico en hierro, calcio y proteína',                   NULL),
  ('Cuy cocido',       'PREFER', 'Hierro hemo, alta biodisponibilidad',                  NULL),
  ('Naranja',          'PREFER', 'Vitamina C potencia absorción de hierro no hemo',      NULL),
  ('Limón',            'PREFER', 'Vitamina C — consumir junto con fuentes de hierro',    NULL),
  ('Brócoli cocido',   'PREFER', 'Vitamina C y folato',                                  NULL),
  ('Semillas de chía', 'PREFER', 'Hierro no hemo + omega-3',                             NULL)
) AS r(iname, rtype, reason, max_g)
WHERE d.slug = 'anemia' AND i.name = r.iname
ON CONFLICT DO NOTHING;

-- GOTA
INSERT INTO disease_restrictions (disease_id, ingredient_id, restriction_type, reason, max_daily_g)
SELECT d.id, i.id, r.rtype, r.reason, r.max_g::numeric
FROM diseases d, ingredients i,
(VALUES
  ('Hígado de res',           'AVOID',  'Muy alto en purinas — desencadena crisis de gota',    '0'),
  ('Res magra cocida',        'LIMIT',  'Purinas moderadas — máx 100g/día',                  '100'),
  ('Pollo pechuga cocida',    'LIMIT',  'Purinas moderadas — consumo controlado',             '120'),
  ('Trucha cocida',           'LIMIT',  'Purinas moderadas en pescado',                       '100'),
  ('Atún en agua',            'LIMIT',  'Purinas moderadas — lavar y limitar',                 '80'),
  ('Lentejas cocidas',        'LIMIT',  'Purinas vegetales — menos problemáticas que carne',   '80'),
  ('Arándanos / Blueberries', 'PREFER', 'Reducen inflamación en articulaciones',               NULL),
  ('Papa blanca cocida',      'PREFER', 'Baja en purinas, alcalina',                          NULL),
  ('Leche descremada',        'PREFER', 'Proteínas lácteas reducen ácido úrico',               NULL),
  ('Zanahoria cruda',         'PREFER', 'Baja en purinas, rica en antioxidantes',              NULL),
  ('Quinoa cocida',           'PREFER', 'Proteína completa baja en purinas',                   NULL)
) AS r(iname, rtype, reason, max_g)
WHERE d.slug = 'gota' AND i.name = r.iname
ON CONFLICT DO NOTHING;

-- ENFERMEDAD RENAL
INSERT INTO disease_restrictions (disease_id, ingredient_id, restriction_type, reason, max_daily_g)
SELECT d.id, i.id, r.rtype, r.reason, r.max_g::numeric
FROM diseases d, ingredients i,
(VALUES
  ('Plátano de seda',      'LIMIT',  'Alto potasio — riesgo hipercalemia',               '80'),
  ('Papa blanca cocida',   'LIMIT',  'Alto potasio — remojar y cocinar 2 veces',         '80'),
  ('Espinaca cruda',       'LIMIT',  'Alto potasio y oxalatos',                           '50'),
  ('Naranja',              'LIMIT',  'Alto potasio y fósforo',                            '80'),
  ('Leche descremada',     'LIMIT',  'Alto fósforo — limitar a 100ml/día',              '100'),
  ('Nueces',               'AVOID',  'Muy alto en potasio y fósforo',                     '0'),
  ('Hígado de res',        'AVOID',  'Alto fósforo y proteína — dañino en ERC',           '0'),
  ('Arroz integral cocido','PREFER', 'Bajo en potasio y fósforo vs otros cereales',       NULL),
  ('Manzana',              'PREFER', 'Bajo potasio, segura en ERC',                       NULL),
  ('Zanahoria cruda',      'PREFER', 'Moderado potasio, puede consumirse cocida',         NULL),
  ('Claras de huevo',      'PREFER', 'Proteína de alta calidad, bajo fósforo',            NULL)
) AS r(iname, rtype, reason, max_g)
WHERE d.slug = 'enfermedad_renal' AND i.name = r.iname
ON CONFLICT DO NOTHING;

-- OBESIDAD
INSERT INTO disease_restrictions (disease_id, ingredient_id, restriction_type, reason, max_daily_g)
SELECT d.id, i.id, r.rtype, r.reason, r.max_g::numeric
FROM diseases d, ingredients i,
(VALUES
  ('Papa blanca cocida', 'LIMIT',  'Alta densidad calórica y IG alto',              '100'),
  ('Pan integral',       'LIMIT',  'Calorías moderadas — controlar porciones',       '40'),
  ('Plátano de seda',    'LIMIT',  'Más calórico que otras frutas',                  '80'),
  ('Palta / Aguacate',   'LIMIT',  'Alta en grasas buenas pero calórico',            '60'),
  ('Aceite de oliva',    'LIMIT',  'Muy calórico — usar con medida',                 '10'),
  ('Quinoa cocida',      'PREFER', 'Proteína + fibra = alta saciedad, IG bajo',      NULL),
  ('Lentejas cocidas',   'PREFER', 'Fibra y proteína aumentan saciedad',             NULL),
  ('Brócoli cocido',     'PREFER', 'Muy bajo en calorías, alto en fibra',            NULL),
  ('Espinaca cruda',     'PREFER', 'Casi sin calorías, muy nutritiva',               NULL),
  ('Semillas de chía',   'PREFER', 'Fibra absorbe agua, produce saciedad',           NULL),
  ('Claras de huevo',    'PREFER', 'Proteína pura con mínimas calorías',             NULL),
  ('Pepino',             'PREFER', '96% agua, muy bajo en calorías',                 NULL)
) AS r(iname, rtype, reason, max_g)
WHERE d.slug = 'obesidad' AND i.name = r.iname
ON CONFLICT DO NOTHING;


-- ────────────────────────────────────────────────────────────
-- 7. TABLA RECIPES
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS recipes (
  id              BIGSERIAL PRIMARY KEY,
  title           VARCHAR(150) NOT NULL,
  description     TEXT,
  meal_type       VARCHAR(20)  NOT NULL CHECK (meal_type IN ('desayuno','almuerzo','cena','snack','bebida')),
  prep_min        INT,
  cook_min        INT,
  servings        INT DEFAULT 1,
  kcal            DECIMAL(6,1),
  protein_g       DECIMAL(5,1),
  carbs_g         DECIMAL(5,1),
  fat_g           DECIMAL(5,1),
  fiber_g         DECIMAL(5,1),
  sodium_mg       DECIMAL(7,1),
  image_emoji     VARCHAR(10),
  image_url       TEXT,
  difficulty      VARCHAR(10)  DEFAULT 'facil' CHECK (difficulty IN ('facil','medio','dificil')),
  origin_country  VARCHAR(3)   DEFAULT 'PE',
  is_active       BOOLEAN DEFAULT TRUE,
  created_at      TIMESTAMP DEFAULT NOW()
);

-- DESAYUNOS
INSERT INTO recipes (title, description, meal_type, prep_min, cook_min, servings, kcal, protein_g, carbs_g, fat_g, fiber_g, sodium_mg, image_emoji, difficulty, origin_country) VALUES
  ('Avena cremosa con frutas andinas',
   'Avena cocida a fuego lento con leche descremada, decorada con arándanos frescos y una cucharadita de lúcuma en polvo. Endulzada naturalmente sin azúcar refinada.',
   'desayuno', 5, 10, 1, 285, 10.5, 48.2,  5.1, 6.8,  85, '🥣', 'facil', 'PE'),

  ('Bowl de quinoa con huevo y espinaca',
   'Quinoa cocida mezclada con espinaca salteada en aceite de oliva, acompañada de un huevo poché. Rico en hierro, proteína completa y fibra.',
   'desayuno', 8, 15, 1, 320, 18.4, 32.1,  9.8, 5.2, 210, '🥗', 'facil', 'PE'),

  ('Smoothie verde de espinaca y maracuyá',
   'Batido nutritivo de espinaca fresca, maracuyá, plátano y semillas de chía. Sin azúcar añadida, rico en hierro, vitamina C y omega-3.',
   'desayuno', 5,  0, 1, 195,  5.8, 38.4,  4.2, 7.6,  45, '🥤', 'facil', 'PE'),

  ('Tortilla de claras con verduras',
   'Claras de huevo batidas con brócoli, tomate y cebolla. Cocción sin aceite o con spray vegetal. Alta en proteína, baja en calorías.',
   'desayuno', 5,  8, 1, 145, 18.2,  8.4,  2.1, 2.8, 195, '🍳', 'facil', 'PE'),

  ('Kiwicha con leche descremada y manzana',
   'Kiwicha cocida en leche descremada, servida tibia con rodajas de manzana y canela. Excelente fuente de hierro, calcio y proteína vegetal.',
   'desayuno', 3, 12, 1, 265,  9.8, 44.6,  3.2, 5.4,  95, '🌾', 'facil', 'PE'),

  ('Pan integral con palta y tomate',
   'Rebanada de pan integral tostado con palta aplastada, rodajas de tomate fresco, limón y orégano. Sin sal añadida.',
   'desayuno', 5,  3, 1, 285,  7.2, 32.4, 14.8, 8.2, 340, '🥑', 'facil', 'PE');

-- ALMUERZOS
INSERT INTO recipes (title, description, meal_type, prep_min, cook_min, servings, kcal, protein_g, carbs_g, fat_g, fiber_g, sodium_mg, image_emoji, difficulty, origin_country) VALUES
  ('Sopa de quinoa con pollo y verduras',
   'Sopa andina tradicional con quinoa, pechuga de pollo deshebrada, zanahoria, apio y culantro. Baja en sodio, alta en proteína y fibra.',
   'almuerzo', 10, 30, 2, 295, 24.8, 28.4,  5.2, 4.6, 285, '🍲', 'facil', 'PE'),

  ('Trucha a la plancha con ensalada de quinoa',
   'Filete de trucha cocido a la plancha con ajo y limón, acompañado de quinoa cocida con pepino, tomate y culantro. Fuente excelente de omega-3.',
   'almuerzo', 10, 20, 1, 385, 34.2, 24.8, 12.4, 3.8, 185, '🐟', 'medio', 'PE'),

  ('Guiso de lentejas con camote',
   'Lentejas cocidas con camote, zanahoria, cebolla y especias andinas. Plato completo con proteína vegetal, fibra y carbohidratos complejos.',
   'almuerzo', 10, 35, 2, 310, 14.8, 52.4,  2.8,12.4, 195, '🫘', 'facil', 'PE'),

  ('Caldo de cuy con papa y yerbabuena',
   'Caldo tradicional andino de cuy con papa blanca, zanahoria y yerbabuena. Rico en hierro hemo y proteína de alta calidad.',
   'almuerzo', 15, 45, 2, 265, 28.4, 18.2,  6.8, 2.4, 245, '🍵', 'medio', 'PE'),

  ('Estofado de pollo con quinoa y brócoli',
   'Pechuga de pollo guisada con tomate, cebolla, ajo y especias, servida sobre cama de quinoa y brócoli al vapor.',
   'almuerzo', 12, 30, 1, 345, 32.8, 28.6,  7.4, 5.8, 265, '🍗', 'facil', 'PE'),

  ('Causa de atún con palta',
   'Versión saludable de la causa limeña: papa blanca cocida mezclada con limón y ají amarillo moderado, rellena de atún en agua y palta.',
   'almuerzo', 20, 15, 2, 320, 18.4, 34.8, 10.2, 4.8, 285, '🥘', 'medio', 'PE'),

  ('Ensalada de garbanzos con verduras frescas',
   'Garbanzos cocidos con pepino, tomate, cebolla morada, limón y aceite de oliva. Proteína vegetal completa, alta en fibra.',
   'almuerzo', 10,  0, 1, 285, 12.4, 36.8,  8.6,10.2, 185, '🥗', 'facil', 'PE'),

  ('Arroz integral con pollo y verduras salteadas',
   'Arroz integral cocido acompañado de pechuga de pollo salteada con brócoli, zanahoria y pimiento. Bajo en sodio.',
   'almuerzo', 10, 25, 1, 365, 28.4, 42.6,  6.8, 4.2, 195, '🍚', 'facil', 'PE');

-- CENAS
INSERT INTO recipes (title, description, meal_type, prep_min, cook_min, servings, kcal, protein_g, carbs_g, fat_g, fiber_g, sodium_mg, image_emoji, difficulty, origin_country) VALUES
  ('Crema de zapallo con jengibre',
   'Crema suave de zapallo loche con jengibre, cúrcuma y leche descremada. Antiinflamatoria, baja en calorías y reconfortante.',
   'cena', 10, 20, 2, 145,  5.2, 24.8,  2.4, 3.6, 185, '🎃', 'facil', 'PE'),

  ('Ensalada tibia de lentejas con espinaca',
   'Lentejas cocidas tibias mezcladas con espinaca fresca, tomate cherry, limón y aceite de oliva. Excelente fuente de hierro y proteína.',
   'cena',  5, 20, 1, 265, 14.8, 34.2,  6.4,10.8, 145, '🥗', 'facil', 'PE'),

  ('Filete de trucha al vapor con verduras',
   'Trucha cocida al vapor con ajo, limón y culantro, acompañada de brócoli y zanahoria al vapor. Mínimo sodio, máxima nutrición.',
   'cena',  8, 18, 1, 245, 28.4, 12.6,  8.2, 4.4, 125, '🐟', 'facil', 'PE'),

  ('Sopa de verduras con pollo desmenuzado',
   'Caldo ligero de pollo con apio, zanahoria, cebolla y culantro. Bajo en sodio y calorías, reconfortante y digestivo.',
   'cena',  8, 25, 2, 185, 18.4, 14.8,  3.2, 3.8, 195, '🍵', 'facil', 'PE'),

  ('Tortilla de quinoa y espinaca',
   'Quinoa cocida mezclada con espinaca, huevo y especias, formada en tortilla y cocida a fuego bajo. Rica en proteína y hierro.',
   'cena',  8, 12, 1, 265, 16.8, 24.4,  8.6, 4.2, 215, '🫓', 'facil', 'PE'),

  ('Ensalada de brócoli con aderezo de limón',
   'Brócoli blanqueado con zanahoria rallada, semillas de chía, limón y aceite de oliva. Antioxidante, alta en fibra y vitamina C.',
   'cena', 10,  5, 1, 165,  6.4, 18.4,  7.8, 6.2,  85, '🥦', 'facil', 'PE');

-- SNACKS
INSERT INTO recipes (title, description, meal_type, prep_min, cook_min, servings, kcal, protein_g, carbs_g, fat_g, fiber_g, sodium_mg, image_emoji, difficulty, origin_country) VALUES
  ('Manzana con semillas de chía',
   'Manzana en rodajas espolvoreada con semillas de chía y canela. Snack antidiabético: fibra + omega-3 controlan glucosa postprandial.',
   'snack', 3, 0, 1, 105,  2.2, 24.8,  2.4, 5.8,   5, '🍎', 'facil', 'PE'),

  ('Yogur natural con arándanos',
   'Yogur natural sin azúcar con arándanos frescos y una cucharadita de semillas de chía. Probióticos + antioxidantes.',
   'snack', 3, 0, 1, 125,  6.8, 16.4,  3.2, 3.8,  55, '🫐', 'facil', 'PE'),

  ('Palta aplastada con limón y pepino',
   'Palta aplastada con jugo de limón, servida con rodajas de pepino fresco. Grasas saludables y fibra para media mañana.',
   'snack', 5, 0, 1, 185,  2.8, 10.4, 14.8, 6.8,  15, '🥑', 'facil', 'PE'),

  ('Maní sin sal tostado (porción pequeña)',
   'Porción de 30g de maní sin sal tostado. Rico en proteína, grasas saludables y vitamina E. Satisface el hambre entre comidas.',
   'snack', 1, 0, 1, 170,  7.8,  4.8, 14.8, 2.4,   5, '🥜', 'facil', 'PE');

-- BEBIDAS
INSERT INTO recipes (title, description, meal_type, prep_min, cook_min, servings, kcal, protein_g, carbs_g, fat_g, fiber_g, sodium_mg, image_emoji, difficulty, origin_country) VALUES
  ('Agua de maracuyá sin azúcar',
   'Maracuyá natural diluida en agua fría sin azúcar añadida. Rica en vitamina C, potasio y antioxidantes. Ideal para hipertensión.',
   'bebida', 5, 0, 2,  48,  1.2, 11.4,  0.4, 5.2,  15, '🍹', 'facil', 'PE'),

  ('Infusión de jengibre con limón',
   'Jengibre fresco rallado en agua caliente con jugo de limón. Antiinflamatoria, digestiva y antioxidante. Sin calorías significativas.',
   'bebida', 3, 5, 1,  18,  0.4,  4.2,  0.1, 0.8,   5, '🍵', 'facil', 'PE'),

  ('Smoothie de kiwicha con plátano',
   'Kiwicha en polvo, plátano de seda, leche descremada y canela. Alto en hierro, calcio y proteína vegetal. Ideal para anemia.',
   'bebida', 5, 0, 1, 215,  8.4, 38.6,  2.8, 4.2,  65, '🥤', 'facil', 'PE');

-- Imagen conocida
UPDATE recipes
  SET image_url = 'https://res.cloudinary.com/dca1gayi8/image/upload/v1778376959/bowl_de_quinua_con_huevo_y_espinaca_yjgnqe.png'
  WHERE title = 'Bowl de quinoa con huevo y espinaca';


-- ────────────────────────────────────────────────────────────
-- 8. TABLA RECIPE_INGREDIENTS
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS recipe_ingredients (
  id             BIGSERIAL PRIMARY KEY,
  recipe_id      BIGINT NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
  ingredient_id  BIGINT NOT NULL REFERENCES ingredients(id),
  quantity_g     DECIMAL(7,2) NOT NULL,
  preparation    VARCHAR(100),
  UNIQUE(recipe_id, ingredient_id)
);

-- Avena cremosa con frutas andinas
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity_g, preparation)
SELECT r.id, i.id, ri.qty, ri.prep FROM recipes r, ingredients i,
(VALUES
  ('Avena cremosa con frutas andinas','Avena en hojuelas',        60, 'cocida'),
  ('Avena cremosa con frutas andinas','Leche descremada',        200, 'tibia'),
  ('Avena cremosa con frutas andinas','Arándanos / Blueberries',  50, 'frescos'),
  ('Avena cremosa con frutas andinas','Lúcuma en polvo',          10, 'en polvo'),
  ('Avena cremosa con frutas andinas','Semillas de chía',          8, 'enteras')
) AS ri(rname, iname, qty, prep)
WHERE r.title = ri.rname AND i.name = ri.iname
ON CONFLICT DO NOTHING;

-- Bowl de quinoa con huevo y espinaca
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity_g, preparation)
SELECT r.id, i.id, ri.qty, ri.prep FROM recipes r, ingredients i,
(VALUES
  ('Bowl de quinoa con huevo y espinaca','Quinoa cocida',  100, 'cocida'),
  ('Bowl de quinoa con huevo y espinaca','Huevo entero',    55, 'poché'),
  ('Bowl de quinoa con huevo y espinaca','Espinaca cruda',  80, 'salteada'),
  ('Bowl de quinoa con huevo y espinaca','Aceite de oliva',  5, 'para saltear')
) AS ri(rname, iname, qty, prep)
WHERE r.title = ri.rname AND i.name = ri.iname
ON CONFLICT DO NOTHING;

-- Smoothie verde de espinaca y maracuyá
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity_g, preparation)
SELECT r.id, i.id, ri.qty, ri.prep FROM recipes r, ingredients i,
(VALUES
  ('Smoothie verde de espinaca y maracuyá','Espinaca cruda',       60, 'fresca'),
  ('Smoothie verde de espinaca y maracuyá','Maracuyá / Maracuya',  80, 'jugo'),
  ('Smoothie verde de espinaca y maracuyá','Plátano de seda',       80, 'en trozos'),
  ('Smoothie verde de espinaca y maracuyá','Semillas de chía',       8, 'enteras')
) AS ri(rname, iname, qty, prep)
WHERE r.title = ri.rname AND i.name = ri.iname
ON CONFLICT DO NOTHING;

-- Tortilla de claras con verduras
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity_g, preparation)
SELECT r.id, i.id, ri.qty, ri.prep FROM recipes r, ingredients i,
(VALUES
  ('Tortilla de claras con verduras','Claras de huevo',120, 'batidas'),
  ('Tortilla de claras con verduras','Brócoli cocido',  80, 'picado'),
  ('Tortilla de claras con verduras','Tomate',          60, 'picado'),
  ('Tortilla de claras con verduras','Cebolla',         30, 'picada')
) AS ri(rname, iname, qty, prep)
WHERE r.title = ri.rname AND i.name = ri.iname
ON CONFLICT DO NOTHING;

-- Kiwicha con leche descremada y manzana
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity_g, preparation)
SELECT r.id, i.id, ri.qty, ri.prep FROM recipes r, ingredients i,
(VALUES
  ('Kiwicha con leche descremada y manzana','Kiwicha cocida',   60, 'cocida'),
  ('Kiwicha con leche descremada y manzana','Leche descremada',200, 'tibia'),
  ('Kiwicha con leche descremada y manzana','Manzana',          80, 'en rodajas')
) AS ri(rname, iname, qty, prep)
WHERE r.title = ri.rname AND i.name = ri.iname
ON CONFLICT DO NOTHING;

-- Pan integral con palta y tomate
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity_g, preparation)
SELECT r.id, i.id, ri.qty, ri.prep FROM recipes r, ingredients i,
(VALUES
  ('Pan integral con palta y tomate','Pan integral',      40, 'tostado'),
  ('Pan integral con palta y tomate','Palta / Aguacate',  60, 'aplastada'),
  ('Pan integral con palta y tomate','Tomate',            60, 'en rodajas'),
  ('Pan integral con palta y tomate','Limón',             10, 'jugo')
) AS ri(rname, iname, qty, prep)
WHERE r.title = ri.rname AND i.name = ri.iname
ON CONFLICT DO NOTHING;

-- Sopa de quinoa con pollo y verduras
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity_g, preparation)
SELECT r.id, i.id, ri.qty, ri.prep FROM recipes r, ingredients i,
(VALUES
  ('Sopa de quinoa con pollo y verduras','Quinoa cocida',       80, 'cocida'),
  ('Sopa de quinoa con pollo y verduras','Pollo pechuga cocida',150,'deshebrada'),
  ('Sopa de quinoa con pollo y verduras','Zanahoria cruda',      80, 'en cubos'),
  ('Sopa de quinoa con pollo y verduras','Apio',                 40, 'picado'),
  ('Sopa de quinoa con pollo y verduras','Culantro / Cilantro',  10, 'fresco')
) AS ri(rname, iname, qty, prep)
WHERE r.title = ri.rname AND i.name = ri.iname
ON CONFLICT DO NOTHING;

-- Trucha a la plancha con ensalada de quinoa
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity_g, preparation)
SELECT r.id, i.id, ri.qty, ri.prep FROM recipes r, ingredients i,
(VALUES
  ('Trucha a la plancha con ensalada de quinoa','Trucha cocida',      180, 'a la plancha'),
  ('Trucha a la plancha con ensalada de quinoa','Quinoa cocida',       80, 'cocida'),
  ('Trucha a la plancha con ensalada de quinoa','Pepino',              80, 'en cubos'),
  ('Trucha a la plancha con ensalada de quinoa','Tomate',              80, 'en cubos'),
  ('Trucha a la plancha con ensalada de quinoa','Limón',               20, 'jugo'),
  ('Trucha a la plancha con ensalada de quinoa','Culantro / Cilantro',  8, 'fresco')
) AS ri(rname, iname, qty, prep)
WHERE r.title = ri.rname AND i.name = ri.iname
ON CONFLICT DO NOTHING;

-- Guiso de lentejas con camote
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity_g, preparation)
SELECT r.id, i.id, ri.qty, ri.prep FROM recipes r, ingredients i,
(VALUES
  ('Guiso de lentejas con camote','Lentejas cocidas',       150, 'cocidas'),
  ('Guiso de lentejas con camote','Camote / Batata cocida', 100, 'en cubos'),
  ('Guiso de lentejas con camote','Zanahoria cruda',         80, 'en cubos'),
  ('Guiso de lentejas con camote','Cebolla',                 60, 'picada'),
  ('Guiso de lentejas con camote','Ajo',                      5, 'molido'),
  ('Guiso de lentejas con camote','Aceite de oliva',          8, 'para guisar')
) AS ri(rname, iname, qty, prep)
WHERE r.title = ri.rname AND i.name = ri.iname
ON CONFLICT DO NOTHING;

-- Caldo de cuy con papa y yerbabuena
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity_g, preparation)
SELECT r.id, i.id, ri.qty, ri.prep FROM recipes r, ingredients i,
(VALUES
  ('Caldo de cuy con papa y yerbabuena','Cuy cocido',         200, 'troceado'),
  ('Caldo de cuy con papa y yerbabuena','Papa blanca cocida', 100, 'en cubos'),
  ('Caldo de cuy con papa y yerbabuena','Zanahoria cruda',     60, 'en cubos'),
  ('Caldo de cuy con papa y yerbabuena','Ajo',                  5, 'molido')
) AS ri(rname, iname, qty, prep)
WHERE r.title = ri.rname AND i.name = ri.iname
ON CONFLICT DO NOTHING;

-- Estofado de pollo con quinoa y brócoli
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity_g, preparation)
SELECT r.id, i.id, ri.qty, ri.prep FROM recipes r, ingredients i,
(VALUES
  ('Estofado de pollo con quinoa y brócoli','Pollo pechuga cocida',150, 'en tiras'),
  ('Estofado de pollo con quinoa y brócoli','Quinoa cocida',       100, 'cocida'),
  ('Estofado de pollo con quinoa y brócoli','Brócoli cocido',       80, 'al vapor'),
  ('Estofado de pollo con quinoa y brócoli','Tomate',               80, 'picado'),
  ('Estofado de pollo con quinoa y brócoli','Cebolla',              40, 'picada'),
  ('Estofado de pollo con quinoa y brócoli','Ajo',                   5, 'molido')
) AS ri(rname, iname, qty, prep)
WHERE r.title = ri.rname AND i.name = ri.iname
ON CONFLICT DO NOTHING;

-- Causa de atún con palta
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity_g, preparation)
SELECT r.id, i.id, ri.qty, ri.prep FROM recipes r, ingredients i,
(VALUES
  ('Causa de atún con palta','Papa blanca cocida',150, 'cocida y aplastada'),
  ('Causa de atún con palta','Atún en agua',       80, 'escurrido'),
  ('Causa de atún con palta','Palta / Aguacate',   60, 'en láminas'),
  ('Causa de atún con palta','Limón',              15, 'jugo'),
  ('Causa de atún con palta','Ají amarillo',        5, 'moderado')
) AS ri(rname, iname, qty, prep)
WHERE r.title = ri.rname AND i.name = ri.iname
ON CONFLICT DO NOTHING;

-- Ensalada de garbanzos con verduras frescas
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity_g, preparation)
SELECT r.id, i.id, ri.qty, ri.prep FROM recipes r, ingredients i,
(VALUES
  ('Ensalada de garbanzos con verduras frescas','Garbanzo cocido', 150, 'cocido'),
  ('Ensalada de garbanzos con verduras frescas','Pepino',           80, 'en cubos'),
  ('Ensalada de garbanzos con verduras frescas','Tomate',           80, 'en cubos'),
  ('Ensalada de garbanzos con verduras frescas','Cebolla',          30, 'morada picada'),
  ('Ensalada de garbanzos con verduras frescas','Limón',            15, 'jugo'),
  ('Ensalada de garbanzos con verduras frescas','Aceite de oliva',   8, 'aderezo')
) AS ri(rname, iname, qty, prep)
WHERE r.title = ri.rname AND i.name = ri.iname
ON CONFLICT DO NOTHING;

-- Arroz integral con pollo y verduras salteadas
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity_g, preparation)
SELECT r.id, i.id, ri.qty, ri.prep FROM recipes r, ingredients i,
(VALUES
  ('Arroz integral con pollo y verduras salteadas','Arroz integral cocido',100, 'cocido'),
  ('Arroz integral con pollo y verduras salteadas','Pollo pechuga cocida',120, 'en tiras'),
  ('Arroz integral con pollo y verduras salteadas','Brócoli cocido',       60, 'salteado'),
  ('Arroz integral con pollo y verduras salteadas','Zanahoria cruda',      60, 'salteada'),
  ('Arroz integral con pollo y verduras salteadas','Aceite de oliva',       8, 'para saltear')
) AS ri(rname, iname, qty, prep)
WHERE r.title = ri.rname AND i.name = ri.iname
ON CONFLICT DO NOTHING;

-- Crema de zapallo con jengibre
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity_g, preparation)
SELECT r.id, i.id, ri.qty, ri.prep FROM recipes r, ingredients i,
(VALUES
  ('Crema de zapallo con jengibre','Leche descremada',150, 'tibia'),
  ('Crema de zapallo con jengibre','Jengibre fresco',  10, 'rallado'),
  ('Crema de zapallo con jengibre','Cúrcuma en polvo',  3, 'en polvo')
) AS ri(rname, iname, qty, prep)
WHERE r.title = ri.rname AND i.name = ri.iname
ON CONFLICT DO NOTHING;

-- Ensalada tibia de lentejas con espinaca
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity_g, preparation)
SELECT r.id, i.id, ri.qty, ri.prep FROM recipes r, ingredients i,
(VALUES
  ('Ensalada tibia de lentejas con espinaca','Lentejas cocidas',120, 'cocidas'),
  ('Ensalada tibia de lentejas con espinaca','Espinaca cruda',   60, 'fresca'),
  ('Ensalada tibia de lentejas con espinaca','Tomate',           60, 'cherry'),
  ('Ensalada tibia de lentejas con espinaca','Limón',            15, 'jugo'),
  ('Ensalada tibia de lentejas con espinaca','Aceite de oliva',   8, 'aderezo')
) AS ri(rname, iname, qty, prep)
WHERE r.title = ri.rname AND i.name = ri.iname
ON CONFLICT DO NOTHING;

-- Filete de trucha al vapor con verduras
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity_g, preparation)
SELECT r.id, i.id, ri.qty, ri.prep FROM recipes r, ingredients i,
(VALUES
  ('Filete de trucha al vapor con verduras','Trucha cocida',   180, 'al vapor'),
  ('Filete de trucha al vapor con verduras','Brócoli cocido',   80, 'al vapor'),
  ('Filete de trucha al vapor con verduras','Zanahoria cruda',  60, 'al vapor'),
  ('Filete de trucha al vapor con verduras','Limón',            15, 'jugo'),
  ('Filete de trucha al vapor con verduras','Ajo',               5, 'molido')
) AS ri(rname, iname, qty, prep)
WHERE r.title = ri.rname AND i.name = ri.iname
ON CONFLICT DO NOTHING;

-- Sopa de verduras con pollo desmenuzado
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity_g, preparation)
SELECT r.id, i.id, ri.qty, ri.prep FROM recipes r, ingredients i,
(VALUES
  ('Sopa de verduras con pollo desmenuzado','Pollo pechuga cocida',120, 'desmenuzado'),
  ('Sopa de verduras con pollo desmenuzado','Zanahoria cruda',      60, 'picada'),
  ('Sopa de verduras con pollo desmenuzado','Apio',                 40, 'picado'),
  ('Sopa de verduras con pollo desmenuzado','Cebolla',              30, 'picada'),
  ('Sopa de verduras con pollo desmenuzado','Culantro / Cilantro',  10, 'fresco')
) AS ri(rname, iname, qty, prep)
WHERE r.title = ri.rname AND i.name = ri.iname
ON CONFLICT DO NOTHING;

-- Tortilla de quinoa y espinaca
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity_g, preparation)
SELECT r.id, i.id, ri.qty, ri.prep FROM recipes r, ingredients i,
(VALUES
  ('Tortilla de quinoa y espinaca','Quinoa cocida',  80, 'cocida'),
  ('Tortilla de quinoa y espinaca','Espinaca cruda', 60, 'picada'),
  ('Tortilla de quinoa y espinaca','Huevo entero',   55, 'batido'),
  ('Tortilla de quinoa y espinaca','Aceite de oliva', 5, 'para cocinar')
) AS ri(rname, iname, qty, prep)
WHERE r.title = ri.rname AND i.name = ri.iname
ON CONFLICT DO NOTHING;

-- Ensalada de brócoli con aderezo de limón
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity_g, preparation)
SELECT r.id, i.id, ri.qty, ri.prep FROM recipes r, ingredients i,
(VALUES
  ('Ensalada de brócoli con aderezo de limón','Brócoli cocido',    120, 'blanqueado'),
  ('Ensalada de brócoli con aderezo de limón','Zanahoria cruda',    60, 'rallada'),
  ('Ensalada de brócoli con aderezo de limón','Semillas de chía',    8, 'enteras'),
  ('Ensalada de brócoli con aderezo de limón','Limón',              15, 'jugo'),
  ('Ensalada de brócoli con aderezo de limón','Aceite de oliva',     8, 'aderezo')
) AS ri(rname, iname, qty, prep)
WHERE r.title = ri.rname AND i.name = ri.iname
ON CONFLICT DO NOTHING;

-- Manzana con semillas de chía
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity_g, preparation)
SELECT r.id, i.id, ri.qty, ri.prep FROM recipes r, ingredients i,
(VALUES
  ('Manzana con semillas de chía','Manzana',        120, 'en rodajas'),
  ('Manzana con semillas de chía','Semillas de chía',  8, 'espolvoreadas')
) AS ri(rname, iname, qty, prep)
WHERE r.title = ri.rname AND i.name = ri.iname
ON CONFLICT DO NOTHING;

-- Yogur natural con arándanos
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity_g, preparation)
SELECT r.id, i.id, ri.qty, ri.prep FROM recipes r, ingredients i,
(VALUES
  ('Yogur natural con arándanos','Yogur natural sin azúcar', 150, 'natural'),
  ('Yogur natural con arándanos','Arándanos / Blueberries',   50, 'frescos'),
  ('Yogur natural con arándanos','Semillas de chía',           5, 'enteras')
) AS ri(rname, iname, qty, prep)
WHERE r.title = ri.rname AND i.name = ri.iname
ON CONFLICT DO NOTHING;

-- Palta aplastada con limón y pepino
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity_g, preparation)
SELECT r.id, i.id, ri.qty, ri.prep FROM recipes r, ingredients i,
(VALUES
  ('Palta aplastada con limón y pepino','Palta / Aguacate',80, 'aplastada'),
  ('Palta aplastada con limón y pepino','Pepino',          80, 'en rodajas'),
  ('Palta aplastada con limón y pepino','Limón',           10, 'jugo')
) AS ri(rname, iname, qty, prep)
WHERE r.title = ri.rname AND i.name = ri.iname
ON CONFLICT DO NOTHING;

-- Maní sin sal tostado
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity_g, preparation)
SELECT r.id, i.id, ri.qty, ri.prep FROM recipes r, ingredients i,
(VALUES
  ('Maní sin sal tostado (porción pequeña)','Maní sin sal',30, 'tostado')
) AS ri(rname, iname, qty, prep)
WHERE r.title = ri.rname AND i.name = ri.iname
ON CONFLICT DO NOTHING;

-- Agua de maracuyá sin azúcar
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity_g, preparation)
SELECT r.id, i.id, ri.qty, ri.prep FROM recipes r, ingredients i,
(VALUES
  ('Agua de maracuyá sin azúcar','Maracuyá / Maracuya',100, 'jugo natural')
) AS ri(rname, iname, qty, prep)
WHERE r.title = ri.rname AND i.name = ri.iname
ON CONFLICT DO NOTHING;

-- Infusión de jengibre con limón
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity_g, preparation)
SELECT r.id, i.id, ri.qty, ri.prep FROM recipes r, ingredients i,
(VALUES
  ('Infusión de jengibre con limón','Jengibre fresco',10, 'rallado'),
  ('Infusión de jengibre con limón','Limón',          15, 'jugo')
) AS ri(rname, iname, qty, prep)
WHERE r.title = ri.rname AND i.name = ri.iname
ON CONFLICT DO NOTHING;

-- Smoothie de kiwicha con plátano
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity_g, preparation)
SELECT r.id, i.id, ri.qty, ri.prep FROM recipes r, ingredients i,
(VALUES
  ('Smoothie de kiwicha con plátano','Kiwicha cocida',   30, 'en polvo'),
  ('Smoothie de kiwicha con plátano','Plátano de seda',  80, 'en trozos'),
  ('Smoothie de kiwicha con plátano','Leche descremada',200, 'fría')
) AS ri(rname, iname, qty, prep)
WHERE r.title = ri.rname AND i.name = ri.iname
ON CONFLICT DO NOTHING;


-- ────────────────────────────────────────────────────────────
-- 9. TABLA RECIPE_STEPS (pasos de preparación)
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS recipe_steps (
  id          BIGSERIAL PRIMARY KEY,
  recipe_id   BIGINT NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
  step_number INT  NOT NULL,
  description TEXT NOT NULL
);

INSERT INTO recipe_steps (recipe_id, step_number, description)
SELECT r.id, s.step_number, s.description
FROM recipes r
JOIN (VALUES
  -- Avena cremosa con frutas andinas
  ('Avena cremosa con frutas andinas', 1, 'Hierve la leche descremada a fuego medio hasta que esté tibia.'),
  ('Avena cremosa con frutas andinas', 2, 'Agrega la avena en hojuelas y mezcla constantemente por 8 minutos.'),
  ('Avena cremosa con frutas andinas', 3, 'Retira del fuego y agrega el polvo de lúcuma. Mezcla bien.'),
  ('Avena cremosa con frutas andinas', 4, 'Sirve en un bowl y decora con arándanos frescos y semillas de chía.'),
  -- Bowl de quinoa con huevo y espinaca
  ('Bowl de quinoa con huevo y espinaca', 1, 'Cocina la quinoa en agua con una pizca de sal por 15 minutos a fuego bajo.'),
  ('Bowl de quinoa con huevo y espinaca', 2, 'En una sartén con aceite de oliva, saltea la espinaca por 2 minutos.'),
  ('Bowl de quinoa con huevo y espinaca', 3, 'En agua hirviendo con vinagre, pocha el huevo por 3 minutos.'),
  ('Bowl de quinoa con huevo y espinaca', 4, 'Sirve la quinoa en un bowl, agrega la espinaca y coloca el huevo poché encima.'),
  -- Smoothie verde de espinaca y maracuyá
  ('Smoothie verde de espinaca y maracuyá', 1, 'Lava bien la espinaca fresca.'),
  ('Smoothie verde de espinaca y maracuyá', 2, 'Extrae el jugo del maracuyá y colócalo en la licuadora.'),
  ('Smoothie verde de espinaca y maracuyá', 3, 'Agrega la espinaca, el plátano en trozos y las semillas de chía.'),
  ('Smoothie verde de espinaca y maracuyá', 4, 'Licúa por 1 minuto hasta obtener una mezcla homogénea. Sirve frío.'),
  -- Tortilla de claras con verduras
  ('Tortilla de claras con verduras', 1, 'Pica el brócoli, tomate y cebolla en cubos pequeños.'),
  ('Tortilla de claras con verduras', 2, 'Bate las claras de huevo con sal y pimienta al gusto.'),
  ('Tortilla de claras con verduras', 3, 'En sartén antiadherente sin aceite, sofríe las verduras por 3 minutos.'),
  ('Tortilla de claras con verduras', 4, 'Vierte las claras sobre las verduras y cocina a fuego bajo por 5 minutos tapado.'),
  -- Kiwicha con leche descremada y manzana
  ('Kiwicha con leche descremada y manzana', 1, 'Hierve la leche descremada a fuego medio.'),
  ('Kiwicha con leche descremada y manzana', 2, 'Agrega la kiwicha y cocina por 10 minutos revolviendo constantemente.'),
  ('Kiwicha con leche descremada y manzana', 3, 'Pela y corta la manzana en rodajas finas.'),
  ('Kiwicha con leche descremada y manzana', 4, 'Sirve la kiwicha caliente y decora con las rodajas de manzana y canela.'),
  -- Pan integral con palta y tomate
  ('Pan integral con palta y tomate', 1, 'Tuesta la rebanada de pan integral.'),
  ('Pan integral con palta y tomate', 2, 'Aplasta la palta con un tenedor y añade jugo de limón.'),
  ('Pan integral con palta y tomate', 3, 'Unta la palta sobre el pan tostado.'),
  ('Pan integral con palta y tomate', 4, 'Coloca las rodajas de tomate encima y espolvorea orégano.'),
  -- Sopa de quinoa con pollo y verduras
  ('Sopa de quinoa con pollo y verduras', 1, 'Hierve la pechuga de pollo en agua con sal por 20 minutos. Deshebrala.'),
  ('Sopa de quinoa con pollo y verduras', 2, 'En el mismo caldo agrega la quinoa, zanahoria y apio picados.'),
  ('Sopa de quinoa con pollo y verduras', 3, 'Cocina por 15 minutos a fuego medio.'),
  ('Sopa de quinoa con pollo y verduras', 4, 'Agrega el pollo deshebrado y el culantro. Rectifica sal y sirve.'),
  -- Trucha a la plancha con ensalada de quinoa
  ('Trucha a la plancha con ensalada de quinoa', 1, 'Sazona el filete de trucha con ajo molido, limón y pimienta.'),
  ('Trucha a la plancha con ensalada de quinoa', 2, 'Cocina en plancha caliente 5 minutos por cada lado.'),
  ('Trucha a la plancha con ensalada de quinoa', 3, 'Mezcla quinoa cocida con pepino, tomate y culantro picados.'),
  ('Trucha a la plancha con ensalada de quinoa', 4, 'Aliña la ensalada con limón y sirve junto a la trucha.'),
  -- Guiso de lentejas con camote
  ('Guiso de lentejas con camote', 1, 'Sofríe la cebolla y el ajo en aceite de oliva por 3 minutos.'),
  ('Guiso de lentejas con camote', 2, 'Agrega el camote y la zanahoria en cubos. Sofríe 2 minutos más.'),
  ('Guiso de lentejas con camote', 3, 'Añade las lentejas y cubre con agua. Cocina 30 minutos a fuego medio.'),
  ('Guiso de lentejas con camote', 4, 'Sazona con sal, pimienta y comino. Sirve caliente.'),
  -- Caldo de cuy con papa y yerbabuena
  ('Caldo de cuy con papa y yerbabuena', 1, 'Limpia y trocea el cuy. Sazona con sal, pimienta y ajo.'),
  ('Caldo de cuy con papa y yerbabuena', 2, 'Hierve el cuy en agua con cebolla por 30 minutos.'),
  ('Caldo de cuy con papa y yerbabuena', 3, 'Agrega la papa en cubos y la zanahoria. Cocina 15 minutos más.'),
  ('Caldo de cuy con papa y yerbabuena', 4, 'Añade la yerbabuena fresca al final. Sirve caliente.'),
  -- Estofado de pollo con quinoa y brócoli
  ('Estofado de pollo con quinoa y brócoli', 1, 'Dora la pechuga de pollo en aceite de oliva por 5 minutos.'),
  ('Estofado de pollo con quinoa y brócoli', 2, 'Agrega tomate, cebolla y ajo picados. Cocina 10 minutos.'),
  ('Estofado de pollo con quinoa y brócoli', 3, 'Añade especias y agua. Cocina tapado 15 minutos más.'),
  ('Estofado de pollo con quinoa y brócoli', 4, 'Sirve sobre quinoa cocida con brócoli al vapor al lado.'),
  -- Causa de atún con palta
  ('Causa de atún con palta', 1, 'Cocina y aplasta la papa blanca. Mezcla con limón y ají amarillo moderado.'),
  ('Causa de atún con palta', 2, 'Escurre el atún en agua y mezcla con mayonesa light.'),
  ('Causa de atún con palta', 3, 'En un molde, coloca una capa de papa, luego atún, luego palta en láminas.'),
  ('Causa de atún con palta', 4, 'Cubre con otra capa de papa. Refrigera 30 min antes de servir.'),
  -- Ensalada de garbanzos con verduras frescas
  ('Ensalada de garbanzos con verduras frescas', 1, 'Escurre y enjuaga los garbanzos cocidos.'),
  ('Ensalada de garbanzos con verduras frescas', 2, 'Pica el pepino, tomate y cebolla morada en cubos pequeños.'),
  ('Ensalada de garbanzos con verduras frescas', 3, 'Mezcla todo en un bowl grande.'),
  ('Ensalada de garbanzos con verduras frescas', 4, 'Aliña con jugo de limón, aceite de oliva y sal. Sirve fresco.'),
  -- Arroz integral con pollo y verduras salteadas
  ('Arroz integral con pollo y verduras salteadas', 1, 'Cocina el arroz integral en agua con sal por 25 minutos.'),
  ('Arroz integral con pollo y verduras salteadas', 2, 'Corta la pechuga en tiras y saltea en aceite de oliva.'),
  ('Arroz integral con pollo y verduras salteadas', 3, 'Agrega brócoli, zanahoria y pimiento. Saltea 5 minutos más.'),
  ('Arroz integral con pollo y verduras salteadas', 4, 'Sirve el pollo con verduras sobre el arroz integral.'),
  -- Crema de zapallo con jengibre
  ('Crema de zapallo con jengibre', 1, 'Pela y corta el zapallo en cubos. Cocina en agua por 15 minutos.'),
  ('Crema de zapallo con jengibre', 2, 'Ralla el jengibre fresco.'),
  ('Crema de zapallo con jengibre', 3, 'Licúa el zapallo cocido con leche descremada, jengibre y cúrcuma.'),
  ('Crema de zapallo con jengibre', 4, 'Calienta la crema a fuego bajo. Sirve con una pizca de cúrcuma encima.'),
  -- Ensalada tibia de lentejas con espinaca
  ('Ensalada tibia de lentejas con espinaca', 1, 'Cocina las lentejas en agua por 20 minutos hasta que estén tiernas.'),
  ('Ensalada tibia de lentejas con espinaca', 2, 'Escurre y coloca en un bowl todavía tibias.'),
  ('Ensalada tibia de lentejas con espinaca', 3, 'Agrega espinaca fresca, tomate cherry partido y cebolla morada.'),
  ('Ensalada tibia de lentejas con espinaca', 4, 'Aliña con limón, aceite de oliva y sal. Mezcla y sirve.'),
  -- Filete de trucha al vapor con verduras
  ('Filete de trucha al vapor con verduras', 1, 'Sazona el filete con ajo molido, limón y culantro picado.'),
  ('Filete de trucha al vapor con verduras', 2, 'Coloca en vaporera sobre agua hirviendo.'),
  ('Filete de trucha al vapor con verduras', 3, 'Cocina al vapor por 15 minutos.'),
  ('Filete de trucha al vapor con verduras', 4, 'Sirve con brócoli y zanahoria también al vapor.'),
  -- Sopa de verduras con pollo desmenuzado
  ('Sopa de verduras con pollo desmenuzado', 1, 'Hierve el pollo en agua con sal por 20 minutos. Desmenúzalo.'),
  ('Sopa de verduras con pollo desmenuzado', 2, 'En el caldo agrega apio, zanahoria y cebolla picados.'),
  ('Sopa de verduras con pollo desmenuzado', 3, 'Cocina por 15 minutos a fuego medio.'),
  ('Sopa de verduras con pollo desmenuzado', 4, 'Agrega el pollo desmenuzado y culantro fresco. Sirve caliente.'),
  -- Tortilla de quinoa y espinaca
  ('Tortilla de quinoa y espinaca', 1, 'Mezcla quinoa cocida con espinaca picada, huevo batido y especias.'),
  ('Tortilla de quinoa y espinaca', 2, 'Forma una tortilla con la mezcla.'),
  ('Tortilla de quinoa y espinaca', 3, 'Cocina en sartén antiadherente a fuego bajo por 5 minutos.'),
  ('Tortilla de quinoa y espinaca', 4, 'Voltea y cocina 4 minutos más. Sirve caliente.'),
  -- Ensalada de brócoli con aderezo de limón
  ('Ensalada de brócoli con aderezo de limón', 1, 'Blanquea el brócoli en agua hirviendo por 3 minutos.'),
  ('Ensalada de brócoli con aderezo de limón', 2, 'Enfría inmediatamente en agua con hielo para mantener el color.'),
  ('Ensalada de brócoli con aderezo de limón', 3, 'Ralla la zanahoria y mezcla con el brócoli.'),
  ('Ensalada de brócoli con aderezo de limón', 4, 'Aliña con limón, aceite de oliva y semillas de chía. Sirve fresco.'),
  -- Manzana con semillas de chía
  ('Manzana con semillas de chía', 1, 'Lava y corta la manzana en rodajas finas.'),
  ('Manzana con semillas de chía', 2, 'Coloca las rodajas en un plato.'),
  ('Manzana con semillas de chía', 3, 'Espolvorea semillas de chía y canela encima.'),
  ('Manzana con semillas de chía', 4, 'Sirve inmediatamente o refrigera hasta consumir.'),
  -- Yogur natural con arándanos
  ('Yogur natural con arándanos', 1, 'Sirve el yogur natural sin azúcar en un bowl.'),
  ('Yogur natural con arándanos', 2, 'Lava los arándanos frescos.'),
  ('Yogur natural con arándanos', 3, 'Coloca los arándanos sobre el yogur.'),
  ('Yogur natural con arándanos', 4, 'Agrega una cucharadita de semillas de chía encima. Sirve frío.'),
  -- Palta aplastada con limón y pepino
  ('Palta aplastada con limón y pepino', 1, 'Parte la palta y retira la semilla.'),
  ('Palta aplastada con limón y pepino', 2, 'Aplasta la palta con tenedor y añade jugo de limón.'),
  ('Palta aplastada con limón y pepino', 3, 'Corta el pepino en rodajas finas.'),
  ('Palta aplastada con limón y pepino', 4, 'Sirve la palta aplastada acompañada de las rodajas de pepino.'),
  -- Maní sin sal tostado
  ('Maní sin sal tostado (porción pequeña)', 1, 'Mide una porción de 30g de maní sin sal.'),
  ('Maní sin sal tostado (porción pequeña)', 2, 'Si deseas tostarlo, colócalo en sartén seca a fuego bajo por 3 minutos.'),
  ('Maní sin sal tostado (porción pequeña)', 3, 'Remueve constantemente para que no se queme.'),
  ('Maní sin sal tostado (porción pequeña)', 4, 'Deja enfriar y sirve como snack.'),
  -- Agua de maracuyá sin azúcar
  ('Agua de maracuyá sin azúcar', 1, 'Parte los maracuyás y extrae la pulpa.'),
  ('Agua de maracuyá sin azúcar', 2, 'Cuela la pulpa para separar las semillas.'),
  ('Agua de maracuyá sin azúcar', 3, 'Mezcla el jugo con agua fría al gusto.'),
  ('Agua de maracuyá sin azúcar', 4, 'No agregues azúcar. Sirve con hielo.'),
  -- Infusión de jengibre con limón
  ('Infusión de jengibre con limón', 1, 'Pela y ralla 1cm de jengibre fresco.'),
  ('Infusión de jengibre con limón', 2, 'Hierve agua y agrega el jengibre rallado.'),
  ('Infusión de jengibre con limón', 3, 'Deja reposar 5 minutos y cuela.'),
  ('Infusión de jengibre con limón', 4, 'Agrega jugo de limón fresco. Sirve caliente o tibio.'),
  -- Smoothie de kiwicha con plátano
  ('Smoothie de kiwicha con plátano', 1, 'Coloca la leche descremada en la licuadora.'),
  ('Smoothie de kiwicha con plátano', 2, 'Agrega el plátano en trozos y la kiwicha en polvo.'),
  ('Smoothie de kiwicha con plátano', 3, 'Añade una pizca de canela.'),
  ('Smoothie de kiwicha con plátano', 4, 'Licúa por 1 minuto hasta que esté cremoso. Sirve frío.')
) AS s(rname, step_number, description)
ON r.title = s.rname;


-- ────────────────────────────────────────────────────────────
-- 10. TABLA SAVED_RECIPES
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS saved_recipes (
  id          BIGSERIAL PRIMARY KEY,
  user_id     BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  recipe_id   BIGINT NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
  saved_at    TIMESTAMP DEFAULT NOW(),
  notes       TEXT,
  UNIQUE(user_id, recipe_id)
);


-- ────────────────────────────────────────────────────────────
-- 11. TABLA USER_CHECKINS
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS user_checkins (
  id             BIGSERIAL PRIMARY KEY,
  user_id        BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  weight_kg      DECIMAL(5,2),
  wellbeing      INT CHECK (wellbeing BETWEEN 1 AND 5),
  activity_level VARCHAR(20),
  health_goal    VARCHAR(30),
  notes          TEXT,
  created_at     TIMESTAMP DEFAULT NOW()
);


-- ────────────────────────────────────────────────────────────
-- 12. VERIFICACIÓN FINAL
-- ────────────────────────────────────────────────────────────
SELECT 'countries'            AS tabla, COUNT(*) AS registros FROM countries
UNION ALL
SELECT 'diseases',             COUNT(*) FROM diseases
UNION ALL
SELECT 'ingredients',          COUNT(*) FROM ingredients
UNION ALL
SELECT 'disease_restrictions', COUNT(*) FROM disease_restrictions
UNION ALL
SELECT 'recipes',              COUNT(*) FROM recipes
UNION ALL
SELECT 'recipe_ingredients',   COUNT(*) FROM recipe_ingredients
UNION ALL
SELECT 'recipe_steps',         COUNT(*) FROM recipe_steps;