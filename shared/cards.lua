-- Full 78-card tarot deck. Upright/reversed meaning text lives in locales/*.lua
-- under keys `card_<key>_upright` and `card_<key>_reversed` so translation is
-- a locale-file concern, not a code change. `image` paths point into
-- html/assets/cards/ — that folder ships empty; the NUI falls back to a
-- styled name-only card face when the image 404s (see html/js/cards.js).

Cards = {
    -- Major Arcana (0-21)
    { id = 0,  key = 'the_fool',           name = 'The Fool',           image = 'assets/cards/00-the-fool.png' },
    { id = 1,  key = 'the_magician',       name = 'The Magician',       image = 'assets/cards/01-the-magician.png' },
    { id = 2,  key = 'the_high_priestess', name = 'The High Priestess', image = 'assets/cards/02-the-high-priestess.png' },
    { id = 3,  key = 'the_empress',        name = 'The Empress',        image = 'assets/cards/03-the-empress.png' },
    { id = 4,  key = 'the_emperor',        name = 'The Emperor',        image = 'assets/cards/04-the-emperor.png' },
    { id = 5,  key = 'the_hierophant',     name = 'The Hierophant',     image = 'assets/cards/05-the-hierophant.png' },
    { id = 6,  key = 'the_lovers',         name = 'The Lovers',         image = 'assets/cards/06-the-lovers.png' },
    { id = 7,  key = 'the_chariot',        name = 'The Chariot',        image = 'assets/cards/07-the-chariot.png' },
    { id = 8,  key = 'strength',           name = 'Strength',           image = 'assets/cards/08-strength.png' },
    { id = 9,  key = 'the_hermit',         name = 'The Hermit',         image = 'assets/cards/09-the-hermit.png' },
    { id = 10, key = 'wheel_of_fortune',   name = 'Wheel of Fortune',   image = 'assets/cards/10-wheel-of-fortune.png' },
    { id = 11, key = 'justice',            name = 'Justice',            image = 'assets/cards/11-justice.png' },
    { id = 12, key = 'the_hanged_man',     name = 'The Hanged Man',     image = 'assets/cards/12-the-hanged-man.png' },
    { id = 13, key = 'death',              name = 'Death',              image = 'assets/cards/13-death.png' },
    { id = 14, key = 'temperance',         name = 'Temperance',         image = 'assets/cards/14-temperance.png' },
    { id = 15, key = 'the_devil',          name = 'The Devil',          image = 'assets/cards/15-the-devil.png' },
    { id = 16, key = 'the_tower',          name = 'The Tower',          image = 'assets/cards/16-the-tower.png' },
    { id = 17, key = 'the_star',           name = 'The Star',           image = 'assets/cards/17-the-star.png' },
    { id = 18, key = 'the_moon',           name = 'The Moon',           image = 'assets/cards/18-the-moon.png' },
    { id = 19, key = 'the_sun',            name = 'The Sun',            image = 'assets/cards/19-the-sun.png' },
    { id = 20, key = 'judgement',          name = 'Judgement',          image = 'assets/cards/20-judgement.png' },
    { id = 21, key = 'the_world',          name = 'The World',          image = 'assets/cards/21-the-world.png' },

    -- Cups (22-35)
    { id = 22, key = 'ace_of_cups',    name = 'Ace of Cups',    image = 'assets/cards/22-ace-of-cups.png' },
    { id = 23, key = 'two_of_cups',    name = 'Two of Cups',    image = 'assets/cards/23-two-of-cups.png' },
    { id = 24, key = 'three_of_cups',  name = 'Three of Cups',  image = 'assets/cards/24-three-of-cups.png' },
    { id = 25, key = 'four_of_cups',   name = 'Four of Cups',   image = 'assets/cards/25-four-of-cups.png' },
    { id = 26, key = 'five_of_cups',   name = 'Five of Cups',   image = 'assets/cards/26-five-of-cups.png' },
    { id = 27, key = 'six_of_cups',    name = 'Six of Cups',    image = 'assets/cards/27-six-of-cups.png' },
    { id = 28, key = 'seven_of_cups',  name = 'Seven of Cups',  image = 'assets/cards/28-seven-of-cups.png' },
    { id = 29, key = 'eight_of_cups',  name = 'Eight of Cups',  image = 'assets/cards/29-eight-of-cups.png' },
    { id = 30, key = 'nine_of_cups',   name = 'Nine of Cups',   image = 'assets/cards/30-nine-of-cups.png' },
    { id = 31, key = 'ten_of_cups',    name = 'Ten of Cups',    image = 'assets/cards/31-ten-of-cups.png' },
    { id = 32, key = 'page_of_cups',   name = 'Page of Cups',   image = 'assets/cards/32-page-of-cups.png' },
    { id = 33, key = 'knight_of_cups', name = 'Knight of Cups', image = 'assets/cards/33-knight-of-cups.png' },
    { id = 34, key = 'queen_of_cups',  name = 'Queen of Cups',  image = 'assets/cards/34-queen-of-cups.png' },
    { id = 35, key = 'king_of_cups',   name = 'King of Cups',   image = 'assets/cards/35-king-of-cups.png' },

    -- Pentacles (36-49)
    { id = 36, key = 'ace_of_pentacles',    name = 'Ace of Pentacles',    image = 'assets/cards/36-ace-of-pentacles.png' },
    { id = 37, key = 'two_of_pentacles',    name = 'Two of Pentacles',    image = 'assets/cards/37-two-of-pentacles.png' },
    { id = 38, key = 'three_of_pentacles',  name = 'Three of Pentacles',  image = 'assets/cards/38-three-of-pentacles.png' },
    { id = 39, key = 'four_of_pentacles',   name = 'Four of Pentacles',   image = 'assets/cards/39-four-of-pentacles.png' },
    { id = 40, key = 'five_of_pentacles',   name = 'Five of Pentacles',   image = 'assets/cards/40-five-of-pentacles.png' },
    { id = 41, key = 'six_of_pentacles',    name = 'Six of Pentacles',    image = 'assets/cards/41-six-of-pentacles.png' },
    { id = 42, key = 'seven_of_pentacles',  name = 'Seven of Pentacles',  image = 'assets/cards/42-seven-of-pentacles.png' },
    { id = 43, key = 'eight_of_pentacles',  name = 'Eight of Pentacles',  image = 'assets/cards/43-eight-of-pentacles.png' },
    { id = 44, key = 'nine_of_pentacles',   name = 'Nine of Pentacles',   image = 'assets/cards/44-nine-of-pentacles.png' },
    { id = 45, key = 'ten_of_pentacles',    name = 'Ten of Pentacles',    image = 'assets/cards/45-ten-of-pentacles.png' },
    { id = 46, key = 'page_of_pentacles',   name = 'Page of Pentacles',   image = 'assets/cards/46-page-of-pentacles.png' },
    { id = 47, key = 'knight_of_pentacles', name = 'Knight of Pentacles', image = 'assets/cards/47-knight-of-pentacles.png' },
    { id = 48, key = 'queen_of_pentacles',  name = 'Queen of Pentacles',  image = 'assets/cards/48-queen-of-pentacles.png' },
    { id = 49, key = 'king_of_pentacles',   name = 'King of Pentacles',   image = 'assets/cards/49-king-of-pentacles.png' },

    -- Swords (50-63)
    { id = 50, key = 'ace_of_swords',      name = 'Ace of Swords',      image = 'assets/cards/50-ace-of-swords.png' },
    { id = 51, key = 'two_of_swords',      name = 'Two of Swords',      image = 'assets/cards/51-two-of-swords.png' },
    { id = 52, key = 'three_of_swords',    name = 'Three of Swords',    image = 'assets/cards/52-three-of-swords.png' },
    { id = 53, key = 'four_of_swords',     name = 'Four of Swords',     image = 'assets/cards/53-four-of-swords.png' },
    { id = 54, key = 'five_of_swords',     name = 'Five of Swords',     image = 'assets/cards/54-five-of-swords.png' },
    { id = 55, key = 'six_of_swords',      name = 'Six of Swords',      image = 'assets/cards/55-six-of-swords.png' },
    { id = 56, key = 'seven_of_swords',    name = 'Seven of Swords',    image = 'assets/cards/56-seven-of-swords.png' },
    { id = 57, key = 'eight_of_swords',    name = 'Eight of Swords',    image = 'assets/cards/57-eight-of-swords.png' },
    { id = 58, key = 'nine_of_swords',     name = 'Nine of Swords',     image = 'assets/cards/58-nine-of-swords.png' },
    { id = 59, key = 'ten_of_swords',      name = 'Ten of Swords',      image = 'assets/cards/59-ten-of-swords.png' },
    { id = 60, key = 'page_of_swords',     name = 'Page of Swords',     image = 'assets/cards/60-page-of-swords.png' },
    { id = 61, key = 'knight_of_swords',   name = 'Knight of Swords',   image = 'assets/cards/61-knight-of-swords.png' },
    { id = 62, key = 'queen_of_swords',    name = 'Queen of Swords',    image = 'assets/cards/62-queen-of-swords.png' },
    { id = 63, key = 'king_of_swords',     name = 'King of Swords',     image = 'assets/cards/63-king-of-swords.png' },

    -- Wands (64-77)
    { id = 64, key = 'ace_of_wands',       name = 'Ace of Wands',       image = 'assets/cards/64-ace-of-wands.png' },
    { id = 65, key = 'two_of_wands',       name = 'Two of Wands',       image = 'assets/cards/65-two-of-wands.png' },
    { id = 66, key = 'three_of_wands',     name = 'Three of Wands',     image = 'assets/cards/66-three-of-wands.png' },
    { id = 67, key = 'four_of_wands',      name = 'Four of Wands',      image = 'assets/cards/67-four-of-wands.png' },
    { id = 68, key = 'five_of_wands',      name = 'Five of Wands',      image = 'assets/cards/68-five-of-wands.png' },
    { id = 69, key = 'six_of_wands',       name = 'Six of Wands',       image = 'assets/cards/69-six-of-wands.png' },
    { id = 70, key = 'seven_of_wands',     name = 'Seven of Wands',     image = 'assets/cards/70-seven-of-wands.png' },
    { id = 71, key = 'eight_of_wands',     name = 'Eight of Wands',     image = 'assets/cards/71-eight-of-wands.png' },
    { id = 72, key = 'nine_of_wands',      name = 'Nine of Wands',      image = 'assets/cards/72-nine-of-wands.png' },
    { id = 73, key = 'ten_of_wands',       name = 'Ten of Wands',       image = 'assets/cards/73-ten-of-wands.png' },
    { id = 74, key = 'page_of_wands',      name = 'Page of Wands',      image = 'assets/cards/74-page-of-wands.png' },
    { id = 75, key = 'knight_of_wands',    name = 'Knight of Wands',    image = 'assets/cards/75-knight-of-wands.png' },
    { id = 76, key = 'queen_of_wands',     name = 'Queen of Wands',     image = 'assets/cards/76-queen-of-wands.png' },
    { id = 77, key = 'king_of_wands',      name = 'King of Wands',      image = 'assets/cards/77-king-of-wands.png' },
}

-- Fast id -> card lookup, built once at load.
CardsById = {}
for _, card in ipairs(Cards) do
    CardsById[card.id] = card
end
