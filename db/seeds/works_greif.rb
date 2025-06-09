require 'faker'

puts "🎵 Creating GREIF works"

greif = Composer.find_by(last_name: "Greif")

## Hölderlin Lieder
holderlin = greif.works.create!(
  opus: "Op. 270/271",
  title: "Hölderlin Lieder",
  description: Faker::Lorem.paragraph(sentence_count: 4),
  duration: 5400,
  instrumentation: "Voice, Piano",
  recorded: false,
  form: :song_cycle,
  structure: :lied,
  start_date_composed: Date.new(1990, 12, 21),
  end_date_composed: Date.new(1992, 01, 01),
  unsure_start_date: false,
  unsure_end_date: true
)
holderlin.movements.create!(
  title: "I. Die Entschlafenen",
  position: 1,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)
holderlin.movements.create!(
  title: "II. Der Tod fürs Vaterland",
  position: 2,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)
holderlin.movements.create!(
  title: "III. Sonnenuntergang",
  position: 3,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)
holderlin.movements.create!(
  title: "IV. Die Kürze",
  position: 4,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)
holderlin.movements.create!(
  title: "V. Die Schönheit",
  position: 5,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)
holderlin.movements.create!(
  title: "VI. Lebenslauf",
  position: 6,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)
holderlin.movements.create!(
  title: "VII. Reif sind, in Feuer getaucht…",
  position: 7,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)
holderlin.movements.create!(
  title: "VIII. Der Zeitgeist",
  position: 8,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)
holderlin.movements.create!(
  title: "IX. Abendfantasie",
  position: 9,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)
holderlin.movements.create!(
  title: "X. Wie Vögel…",
  position: 10,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)
holderlin.movements.create!(
  title: "XI. Hälfte des Lebens",
  position: 11,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)

## Imago Mundi
imago_mundi = greif.works.create!(
  opus: "s.o.",
  title: "Imago Mundi",
  description: Faker::Lorem.paragraph(sentence_count: 4),
  instrumentation: "Voice, Piano",
  recorded: false,
  form: :song_cycle,
  structure: :lied,
  start_date_composed: Date.new(1998, 10, 2),
  end_date_composed: Date.new(1998, 11, 23),
  unsure_start_date: false,
  unsure_end_date: false
)
imago_mundi.movements.create!(
  title: "I Fellowed Sleep",
  position: 1,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)
imago_mundi.movements.create!(
  title: "Hark,…",
  position: 2,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)
imago_mundi.movements.create!(
  title: "[Sie kämmt ihr Haar]",
  position: 3,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)
imago_mundi.movements.create!(
  title: "Fugue",
  position: 4,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)
imago_mundi.movements.create!(
  title: "Night",
  position: 5,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)
imago_mundi.movements.create!(
  title: "Étude sur le mouvement des corps célestes",
  position: 6,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)
imago_mundi.movements.create!(
  title: "Auf der Elter",
  position: 7,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)
imago_mundi.movements.create!(
  title: "Le Kaddish de l'univers",
  position: 8,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)

## Thème varié
theme_varie = greif.works.create!(
  opus: "Op. 5",
  title: "Thème varié",
  description: Faker::Lorem.paragraph(sentence_count: 4),
  instrumentation: "Piano",
  recorded: false,
  form: :variation,
  structure: nil,
  start_date_composed: Date.new(1965, 1, 1),
  end_date_composed: Date.new(1965, 1, 1),
  unsure_start_date: false,
  unsure_end_date: false
)

## Variations sur un thème de R. Schumann
variation_schumann = greif.works.create!(
  opus: "Op. 9",
  title: "Variations sur un thème de R. Schumann",
  description: Faker::Lorem.paragraph(sentence_count: 4),
  instrumentation: "Piano",
  recorded: false,
  form: :variation,
  structure: nil,
  start_date_composed: Date.new(1966, 1, 1),
  end_date_composed: Date.new(1966, 1, 1),
  unsure_start_date: false,
  unsure_end_date: false
)

## Alabama Song
alabama_song = greif.works.create!(
  opus: "Op. 23",
  title: "Alabama Song",
  description: Faker::Lorem.paragraph(sentence_count: 4),
  instrumentation: "Piano",
  recorded: false,
  form: :paraphrase,
  structure: nil,
  start_date_composed: Date.new(1968, 11, 1),
  end_date_composed: Date.new(1968, 11, 1),
  unsure_start_date: false,
  unsure_end_date: false
)

## L'île du Docteur Moreau
dr_moreau = greif.works.create!(
  opus: "Op. 29",
  title: "L'île du Docteur Moreau",
  description: Faker::Lorem.paragraph(sentence_count: 4),
  instrumentation: "Piano",
  recorded: false,
  form: :piece,
  structure: nil,
  start_date_composed: Date.new(1969, 10, 1),
  end_date_composed: Date.new(1969, 10, 1),
  unsure_start_date: false,
  unsure_end_date: false
)

## Sonate pour piano n° 9
sonata_9 = greif.works.create!(
  opus: "Op. 33",
  title: "Sonate pour piano n° 9",
  description: Faker::Lorem.paragraph(sentence_count: 4),
  instrumentation: "Piano",
  duration: 840,
  recorded: true,
  form: :sonata,
  structure: nil,
  start_date_composed: Date.new(1970, 2, 1),
  end_date_composed: Date.new(1970, 6, 1),
  unsure_start_date: false,
  unsure_end_date: false
)
sonata_9.movements.create!(
  title: "I. A Mourning Brew",
  position: 1,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)
sonata_9.movements.create!(
  title: "II. The Ægyptian Mathematician",
  position: 2,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)
sonata_9.movements.create!(
  title: "III. Stars! Stars!",
  position: 3,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)
sonata_9.movements.create!(
  title: "IV. 42nd Street",
  position: 4,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)

## Sonate pour piano n° 10
sonata_10 = greif.works.create!(
  opus: "Op. 34",
  title: "Sonate pour piano n° 10",
  description: Faker::Lorem.paragraph(sentence_count: 4),
  instrumentation: "Piano",
  recorded: false,
  form: :sonata,
  structure: nil,
  start_date_composed: Date.new(1970, 7, 1),
  end_date_composed: Date.new(1970, 12, 1),
  unsure_start_date: false,
  unsure_end_date: false
)
sonata_10.movements.create!(
  title: "Marche",
  position: 1,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)
sonata_10.movements.create!(
  title: "Valse",
  position: 2,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)

### Wiener Konzert
wiener_koncert = greif.works.create!(
  opus: "Op. 40",
  title: "Wiener Konzert",
  description: Faker::Lorem.paragraph(sentence_count: 4),
  duration: 1080,
  instrumentation: "Voice, Piano",
  recorded: true,
  form: :song_cycle,
  structure: :lied,
  start_date_composed: Date.new(1973, 5, 8),
  end_date_composed: Date.new(1973, 11, 26),
  unsure_start_date: false,
  unsure_end_date: false
)
wiener_koncert.movements.create!(
  title: "I. Vergiftet sind meine Lieder",
  position: 1,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)
wiener_koncert.movements.create!(
  title: "II. Aus meinen großen Schmerzen",
  position: 2,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)
wiener_koncert.movements.create!(
  title: "III. Wenn zwei von einander scheiden",
  position: 3,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)
wiener_koncert.movements.create!(
  title: "IV. Am Kreuzweg wird begraben",
  position: 4,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)
wiener_koncert.movements.create!(
  title: "V. Mein süßes Lieb, wenn du im Grab",
  position: 5,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)

## Sonate pour piano n° 13
sonata_13 = greif.works.create!(
  opus: "Op. 47",
  title: "Sonate pour piano n° 13",
  description: Faker::Lorem.paragraph(sentence_count: 4),
  instrumentation: "Piano",
  recorded: false,
  form: :sonata,
  structure: :movement,
  start_date_composed: Date.new(1974, 5, 12),
  end_date_composed: Date.new(1974, 9, 30),
  unsure_start_date: false,
  unsure_end_date: false
)
sonata_13.movements.create!(
  title: "I. Fantaisie-Caprice",
  position: 1,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)
sonata_13.movements.create!(
  title: "II. Shadrack",
  position: 2,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)
sonata_13.movements.create!(
  title: "III. Rondo Burlesk",
  position: 3,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)
sonata_13.movements.create!(
  title: "IV. Finale",
  position: 4,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)

## Sonate pour piano n° 14
sonata_14 = greif.works.create!(
  opus: "Op. 48",
  title: "Sonate pour piano n° 14",
  description: Faker::Lorem.paragraph(sentence_count: 4),
  instrumentation: "Piano",
  recorded: true,
  duration: 1140,
  form: :sonata,
  structure: :movement,
  start_date_composed: Date.new(1965, 1, 1),
  end_date_composed: Date.new(1975, 1, 1),
  unsure_start_date: false,
  unsure_end_date: false
)
sonata_14.movements.create!(
  title: "I. Sinfonia",
  position: 1,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)
sonata_14.movements.create!(
  title: "II. Musette",
  position: 2,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)
sonata_14.movements.create!(
  title: "III. Chasse",
  position: 3,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)

## Light Music
light_music = greif.works.create!(
  opus: "Op. 49",
  title: "Light Music",
  description: Faker::Lorem.paragraph(sentence_count: 4),
  instrumentation: "Voice, Piano",
  recorded: false,
  form: :song_cycle,
  structure: :lied,
  start_date_composed: Date.new(1972, 4, 23),
  end_date_composed: Date.new(1975, 5, 7),
  unsure_start_date: false,
  unsure_end_date: false
)
light_music.movements.create!(
  title: "I. Mir träumte von einem Königskind",
  position: 1,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)
light_music.movements.create!(
  title: "II. Werdet nur nicht ungeduldig",
  position: 2,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)
light_music.movements.create!(
  title: "III. Die Rose, die Lilie, die Taube, die Sonne",
  position: 3,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)
light_music.movements.create!(
  title: "IV. Ein Jüngling liebt ein Mädchen",
  position: 4,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)
light_music.movements.create!(
  title: "V. Es stehen unbeweglich",
  position: 5,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)
light_music.movements.create!(
  title: "VI. The Spirit Song",
  position: 6,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)
light_music.movements.create!(
  title: "VII. Warum sind denn die Rosen so blass",
  position: 7,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)
light_music.movements.create!(
  title: "VIII. Nacht lag auf meinen Augen",
  position: 8,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)

## Birthday Song
birthday_song = greif.works.create!(
  opus: "Op. 51",
  title: "Birthday Song",
  description: Faker::Lorem.paragraph(sentence_count: 4),
  instrumentation: "Voice, Piano",
  recorded: false,
  form: :melody,
  structure: nil,
  start_date_composed: Date.new(1974, 1, 1),
  end_date_composed: Date.new(1974, 1, 1),
  unsure_start_date: false,
  unsure_end_date: false
)

## Scherzo
scherzo = greif.works.create!(
  opus: "Op. 52",
  title: "Scherzo",
  description: Faker::Lorem.paragraph(sentence_count: 4),
  instrumentation: "Piano",
  recorded: false,
  form: :piece,
  structure: nil,
  start_date_composed: Date.new(1975, 1, 1),
  end_date_composed: Date.new(1975, 1, 1),
  unsure_start_date: true,
  unsure_end_date: true
)
scherzo.quotes.create!(
  title: "Ein Heller und ein Batzen",
  author: "Franz Josef Breuer",
  # date: Date.new(1930, 1, 1),
  # circa: true,
)

## Sonate pour piano n° 15
sonata_15 = greif.works.create!(
  opus: "Op. 54",
  title: "Sonate pour piano n° 15",
  description: Faker::Lorem.paragraph(sentence_count: 4),
  instrumentation: "Piano",
  recorded: true,
  duration: 1800,
  form: :sonata,
  structure: :movement,
  start_date_composed: Date.new(1965, 1, 1),
  end_date_composed: Date.new(1975, 1, 1),
  unsure_start_date: false,
  unsure_end_date: false
)
sonata_15.movements.create!(
  title: "I. -",
  position: 1,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)
sonata_15.movements.create!(
  title: "II. In memoriam Louise Clavius Marius",
  position: 2,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)
sonata_15.movements.create!(
  title: "III. Toccata",
  position: 3,
  description: Faker::Lorem.paragraph(sentence_count: 3)
)

puts "✅ Created #{greif.works.count} works in total"
