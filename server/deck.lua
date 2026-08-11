-- Deck build/shuffle/draw. Server-authoritative: clients never see undrawn
-- card identity or order. Deck.Build returns a full shuffled 78-card deck;
-- Deck.DrawNext pops the next entry for a session's reveal sequence.

Deck = {}

local function shuffledCardIds()
    local ids = {}
    for _, card in ipairs(Cards) do
        ids[#ids + 1] = card.id
    end

    -- Fisher-Yates
    for i = #ids, 2, -1 do
        local j = math.random(1, i)
        ids[i], ids[j] = ids[j], ids[i]
    end

    return ids
end

function Deck.Build()
    local ids = shuffledCardIds()
    local deck = {}

    for i = 1, #ids do
        local orientation = 'upright'
        if math.random(1, 100) <= Config.ReversedChance then
            orientation = 'reversed'
        end
        deck[i] = { cardId = ids[i], orientation = orientation }
    end

    return deck
end

-- Draws the entry at `index` (1-based) from session.deck. Returns nil if the
-- deck is exhausted or the session has no deck.
function Deck.DrawAt(session, index)
    if session == nil or session.deck == nil then return nil end
    return session.deck[index]
end
