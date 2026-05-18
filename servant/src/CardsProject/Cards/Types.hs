{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Cards.Types where

import Data.Aeson (ToJSON(..), FromJSON(..), toJSON, parseJSON, withText, genericToJSON, genericParseJSON, defaultOptions, Options(..))
import Data.Aeson.Casing (camelCase)
import Data.Text (Text)
import Database.SQLite.Simple (FromRow(..), ToRow(..), field)
import Database.SQLite.Simple.ToField (ToField(..))
import Database.SQLite.Simple.FromField (FromField(..), returnError, ResultError(ConversionFailed))
import Database.SQLite.Simple.Ok (Ok(..))
import GHC.Generics (Generic)

_toCamel :: String -> String
_toCamel = camelCase

data CardCardTypeType
  = CardCardTypeType_Creature
  | CardCardTypeType_Spell
  | CardCardTypeType_Land
  | CardCardTypeType_Artifact
  | CardCardTypeType_Enchantment
  | CardCardTypeType_Planeswalker
  deriving (Show, Eq, Generic)

instance ToJSON CardCardTypeType where
  toJSON v = case v of
    CardCardTypeType_Creature -> toJSON ("Creature" :: Text)
    CardCardTypeType_Spell -> toJSON ("Spell" :: Text)
    CardCardTypeType_Land -> toJSON ("Land" :: Text)
    CardCardTypeType_Artifact -> toJSON ("Artifact" :: Text)
    CardCardTypeType_Enchantment -> toJSON ("Enchantment" :: Text)
    CardCardTypeType_Planeswalker -> toJSON ("Planeswalker" :: Text)
instance FromJSON CardCardTypeType where
  parseJSON = withText "CardCardTypeType" $ \txt ->
    if txt == "Creature" then pure CardCardTypeType_Creature
    else if txt == "Spell" then pure CardCardTypeType_Spell
    else if txt == "Land" then pure CardCardTypeType_Land
    else if txt == "Artifact" then pure CardCardTypeType_Artifact
    else if txt == "Enchantment" then pure CardCardTypeType_Enchantment
    else if txt == "Planeswalker" then pure CardCardTypeType_Planeswalker
    else fail ("Unknown CardCardTypeType: " ++ show txt)

instance ToField CardCardTypeType where
  toField CardCardTypeType_Creature = toField ("Creature" :: Text)
  toField CardCardTypeType_Spell = toField ("Spell" :: Text)
  toField CardCardTypeType_Land = toField ("Land" :: Text)
  toField CardCardTypeType_Artifact = toField ("Artifact" :: Text)
  toField CardCardTypeType_Enchantment = toField ("Enchantment" :: Text)
  toField CardCardTypeType_Planeswalker = toField ("Planeswalker" :: Text)

instance FromField CardCardTypeType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "Creature" then return CardCardTypeType_Creature
    else if txt == "Spell" then return CardCardTypeType_Spell
    else if txt == "Land" then return CardCardTypeType_Land
    else if txt == "Artifact" then return CardCardTypeType_Artifact
    else if txt == "Enchantment" then return CardCardTypeType_Enchantment
    else if txt == "Planeswalker" then return CardCardTypeType_Planeswalker
    else returnError ConversionFailed f ("Unknown CardCardTypeType: " ++ show txt)

data CardRarityType
  = CardRarityType_Common
  | CardRarityType_Uncommon
  | CardRarityType_Rare
  | CardRarityType_MythicRare
  | CardRarityType_Legendary
  deriving (Show, Eq, Generic)

instance ToJSON CardRarityType where
  toJSON v = case v of
    CardRarityType_Common -> toJSON ("Common" :: Text)
    CardRarityType_Uncommon -> toJSON ("Uncommon" :: Text)
    CardRarityType_Rare -> toJSON ("Rare" :: Text)
    CardRarityType_MythicRare -> toJSON ("MythicRare" :: Text)
    CardRarityType_Legendary -> toJSON ("Legendary" :: Text)
instance FromJSON CardRarityType where
  parseJSON = withText "CardRarityType" $ \txt ->
    if txt == "Common" then pure CardRarityType_Common
    else if txt == "Uncommon" then pure CardRarityType_Uncommon
    else if txt == "Rare" then pure CardRarityType_Rare
    else if txt == "MythicRare" then pure CardRarityType_MythicRare
    else if txt == "Legendary" then pure CardRarityType_Legendary
    else fail ("Unknown CardRarityType: " ++ show txt)

instance ToField CardRarityType where
  toField CardRarityType_Common = toField ("Common" :: Text)
  toField CardRarityType_Uncommon = toField ("Uncommon" :: Text)
  toField CardRarityType_Rare = toField ("Rare" :: Text)
  toField CardRarityType_MythicRare = toField ("MythicRare" :: Text)
  toField CardRarityType_Legendary = toField ("Legendary" :: Text)

instance FromField CardRarityType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "Common" then return CardRarityType_Common
    else if txt == "Uncommon" then return CardRarityType_Uncommon
    else if txt == "Rare" then return CardRarityType_Rare
    else if txt == "MythicRare" then return CardRarityType_MythicRare
    else if txt == "Legendary" then return CardRarityType_Legendary
    else returnError ConversionFailed f ("Unknown CardRarityType: " ++ show txt)

data CardManaColorsType
  = CardManaColorsType_White
  | CardManaColorsType_Blue
  | CardManaColorsType_Black
  | CardManaColorsType_Red
  | CardManaColorsType_Green
  | CardManaColorsType_Colorless
  deriving (Show, Eq, Generic)

instance ToJSON CardManaColorsType where
  toJSON v = case v of
    CardManaColorsType_White -> toJSON ("White" :: Text)
    CardManaColorsType_Blue -> toJSON ("Blue" :: Text)
    CardManaColorsType_Black -> toJSON ("Black" :: Text)
    CardManaColorsType_Red -> toJSON ("Red" :: Text)
    CardManaColorsType_Green -> toJSON ("Green" :: Text)
    CardManaColorsType_Colorless -> toJSON ("Colorless" :: Text)
instance FromJSON CardManaColorsType where
  parseJSON = withText "CardManaColorsType" $ \txt ->
    if txt == "White" then pure CardManaColorsType_White
    else if txt == "Blue" then pure CardManaColorsType_Blue
    else if txt == "Black" then pure CardManaColorsType_Black
    else if txt == "Red" then pure CardManaColorsType_Red
    else if txt == "Green" then pure CardManaColorsType_Green
    else if txt == "Colorless" then pure CardManaColorsType_Colorless
    else fail ("Unknown CardManaColorsType: " ++ show txt)

instance ToField CardManaColorsType where
  toField CardManaColorsType_White = toField ("White" :: Text)
  toField CardManaColorsType_Blue = toField ("Blue" :: Text)
  toField CardManaColorsType_Black = toField ("Black" :: Text)
  toField CardManaColorsType_Red = toField ("Red" :: Text)
  toField CardManaColorsType_Green = toField ("Green" :: Text)
  toField CardManaColorsType_Colorless = toField ("Colorless" :: Text)

instance FromField CardManaColorsType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "White" then return CardManaColorsType_White
    else if txt == "Blue" then return CardManaColorsType_Blue
    else if txt == "Black" then return CardManaColorsType_Black
    else if txt == "Red" then return CardManaColorsType_Red
    else if txt == "Green" then return CardManaColorsType_Green
    else if txt == "Colorless" then return CardManaColorsType_Colorless
    else returnError ConversionFailed f ("Unknown CardManaColorsType: " ++ show txt)

data CardLegalFormatsType
  = CardLegalFormatsType_Standard
  | CardLegalFormatsType_Extended
  | CardLegalFormatsType_Legacy
  | CardLegalFormatsType_Vintage
  | CardLegalFormatsType_Commander
  | CardLegalFormatsType_Draft
  deriving (Show, Eq, Generic)

instance ToJSON CardLegalFormatsType where
  toJSON v = case v of
    CardLegalFormatsType_Standard -> toJSON ("Standard" :: Text)
    CardLegalFormatsType_Extended -> toJSON ("Extended" :: Text)
    CardLegalFormatsType_Legacy -> toJSON ("Legacy" :: Text)
    CardLegalFormatsType_Vintage -> toJSON ("Vintage" :: Text)
    CardLegalFormatsType_Commander -> toJSON ("Commander" :: Text)
    CardLegalFormatsType_Draft -> toJSON ("Draft" :: Text)
instance FromJSON CardLegalFormatsType where
  parseJSON = withText "CardLegalFormatsType" $ \txt ->
    if txt == "Standard" then pure CardLegalFormatsType_Standard
    else if txt == "Extended" then pure CardLegalFormatsType_Extended
    else if txt == "Legacy" then pure CardLegalFormatsType_Legacy
    else if txt == "Vintage" then pure CardLegalFormatsType_Vintage
    else if txt == "Commander" then pure CardLegalFormatsType_Commander
    else if txt == "Draft" then pure CardLegalFormatsType_Draft
    else fail ("Unknown CardLegalFormatsType: " ++ show txt)

instance ToField CardLegalFormatsType where
  toField CardLegalFormatsType_Standard = toField ("Standard" :: Text)
  toField CardLegalFormatsType_Extended = toField ("Extended" :: Text)
  toField CardLegalFormatsType_Legacy = toField ("Legacy" :: Text)
  toField CardLegalFormatsType_Vintage = toField ("Vintage" :: Text)
  toField CardLegalFormatsType_Commander = toField ("Commander" :: Text)
  toField CardLegalFormatsType_Draft = toField ("Draft" :: Text)

instance FromField CardLegalFormatsType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "Standard" then return CardLegalFormatsType_Standard
    else if txt == "Extended" then return CardLegalFormatsType_Extended
    else if txt == "Legacy" then return CardLegalFormatsType_Legacy
    else if txt == "Vintage" then return CardLegalFormatsType_Vintage
    else if txt == "Commander" then return CardLegalFormatsType_Commander
    else if txt == "Draft" then return CardLegalFormatsType_Draft
    else returnError ConversionFailed f ("Unknown CardLegalFormatsType: " ++ show txt)

_cardOpts :: Options
_cardOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 4 }

data Card = Card
  { cardId :: Int
  , cardName :: Text
  , cardCardType :: CardCardTypeType
  , cardRarity :: CardRarityType
  , cardManaCost :: Int
  , cardManaColors :: CardManaColorsType
  , cardAttack :: Maybe Int
  , cardDefense :: Maybe Int
  , cardLoyalty :: Maybe Int
  , cardDescription :: Text
  , cardFlavorText :: Maybe Text
  , cardImageUrl :: Maybe Text
  , cardArtistName :: Maybe Text
  , cardLegalFormats :: CardLegalFormatsType
  , cardIsBanned :: Bool
  , cardIsRestricted :: Bool
  , cardPowerLevel :: Int
  , cardSetId :: Maybe Int
  , cardRulingsId :: Maybe Int
  , cardAbilitiesId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON Card where
  toJSON = genericToJSON _cardOpts
instance FromJSON Card where
  parseJSON = genericParseJSON _cardOpts

instance FromRow Card where
  fromRow = Card <$> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field

_newCardOpts :: Options
_newCardOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 5 }

data NewCard = NewCard
  { bCardName :: Text
  , bCardCardType :: CardCardTypeType
  , bCardRarity :: CardRarityType
  , bCardManaCost :: Int
  , bCardManaColors :: CardManaColorsType
  , bCardAttack :: Maybe Int
  , bCardDefense :: Maybe Int
  , bCardLoyalty :: Maybe Int
  , bCardDescription :: Text
  , bCardFlavorText :: Maybe Text
  , bCardImageUrl :: Maybe Text
  , bCardArtistName :: Maybe Text
  , bCardLegalFormats :: CardLegalFormatsType
  , bCardIsBanned :: Bool
  , bCardIsRestricted :: Bool
  , bCardPowerLevel :: Int
  , bCardSetId :: Maybe Int
  , bCardRulingsId :: Maybe Int
  , bCardAbilitiesId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON NewCard where
  toJSON = genericToJSON _newCardOpts
instance FromJSON NewCard where
  parseJSON = genericParseJSON _newCardOpts

instance ToRow NewCard where
  toRow b = [toField (bCardName b), toField (bCardCardType b), toField (bCardRarity b), toField (bCardManaCost b), toField (bCardManaColors b), toField (bCardAttack b), toField (bCardDefense b), toField (bCardLoyalty b), toField (bCardDescription b), toField (bCardFlavorText b), toField (bCardImageUrl b), toField (bCardArtistName b), toField (bCardLegalFormats b), toField (bCardIsBanned b), toField (bCardIsRestricted b), toField (bCardPowerLevel b), toField (bCardSetId b), toField (bCardRulingsId b), toField (bCardAbilitiesId b)]

data CardSetSetTypeType
  = CardSetSetTypeType_Core
  | CardSetSetTypeType_Expansion
  | CardSetSetTypeType_Supplemental
  | CardSetSetTypeType_Masters
  | CardSetSetTypeType_Draft
  deriving (Show, Eq, Generic)

instance ToJSON CardSetSetTypeType where
  toJSON v = case v of
    CardSetSetTypeType_Core -> toJSON ("Core" :: Text)
    CardSetSetTypeType_Expansion -> toJSON ("Expansion" :: Text)
    CardSetSetTypeType_Supplemental -> toJSON ("Supplemental" :: Text)
    CardSetSetTypeType_Masters -> toJSON ("Masters" :: Text)
    CardSetSetTypeType_Draft -> toJSON ("Draft" :: Text)
instance FromJSON CardSetSetTypeType where
  parseJSON = withText "CardSetSetTypeType" $ \txt ->
    if txt == "Core" then pure CardSetSetTypeType_Core
    else if txt == "Expansion" then pure CardSetSetTypeType_Expansion
    else if txt == "Supplemental" then pure CardSetSetTypeType_Supplemental
    else if txt == "Masters" then pure CardSetSetTypeType_Masters
    else if txt == "Draft" then pure CardSetSetTypeType_Draft
    else fail ("Unknown CardSetSetTypeType: " ++ show txt)

instance ToField CardSetSetTypeType where
  toField CardSetSetTypeType_Core = toField ("Core" :: Text)
  toField CardSetSetTypeType_Expansion = toField ("Expansion" :: Text)
  toField CardSetSetTypeType_Supplemental = toField ("Supplemental" :: Text)
  toField CardSetSetTypeType_Masters = toField ("Masters" :: Text)
  toField CardSetSetTypeType_Draft = toField ("Draft" :: Text)

instance FromField CardSetSetTypeType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "Core" then return CardSetSetTypeType_Core
    else if txt == "Expansion" then return CardSetSetTypeType_Expansion
    else if txt == "Supplemental" then return CardSetSetTypeType_Supplemental
    else if txt == "Masters" then return CardSetSetTypeType_Masters
    else if txt == "Draft" then return CardSetSetTypeType_Draft
    else returnError ConversionFailed f ("Unknown CardSetSetTypeType: " ++ show txt)

_cardSetOpts :: Options
_cardSetOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 7 }

data CardSet = CardSet
  { cardSetId :: Int
  , cardSetName :: Text
  , cardSetCode :: Text
  , cardSetReleaseDate :: Text
  , cardSetRotationDate :: Maybe Text
  , cardSetSetType :: CardSetSetTypeType
  , cardSetTotalCards :: Int
  , cardSetIsRotated :: Bool
  , cardSetDescription :: Maybe Text
  , cardSetLogoUrl :: Maybe Text
  } deriving (Show, Generic)

instance ToJSON CardSet where
  toJSON = genericToJSON _cardSetOpts
instance FromJSON CardSet where
  parseJSON = genericParseJSON _cardSetOpts

instance FromRow CardSet where
  fromRow = CardSet <$> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field

_newCardSetOpts :: Options
_newCardSetOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 8 }

data NewCardSet = NewCardSet
  { bCardSetName :: Text
  , bCardSetCode :: Text
  , bCardSetReleaseDate :: Text
  , bCardSetRotationDate :: Maybe Text
  , bCardSetSetType :: CardSetSetTypeType
  , bCardSetTotalCards :: Int
  , bCardSetIsRotated :: Bool
  , bCardSetDescription :: Maybe Text
  , bCardSetLogoUrl :: Maybe Text
  } deriving (Show, Generic)

instance ToJSON NewCardSet where
  toJSON = genericToJSON _newCardSetOpts
instance FromJSON NewCardSet where
  parseJSON = genericParseJSON _newCardSetOpts

instance ToRow NewCardSet where
  toRow b = [toField (bCardSetName b), toField (bCardSetCode b), toField (bCardSetReleaseDate b), toField (bCardSetRotationDate b), toField (bCardSetSetType b), toField (bCardSetTotalCards b), toField (bCardSetIsRotated b), toField (bCardSetDescription b), toField (bCardSetLogoUrl b)]

_cardRulingOpts :: Options
_cardRulingOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 10 }

data CardRuling = CardRuling
  { cardRulingId :: Int
  , cardRulingRulingText :: Text
  , cardRulingPublishedAt :: Text
  , cardRulingSource :: Text
  , cardRulingCardId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON CardRuling where
  toJSON = genericToJSON _cardRulingOpts
instance FromJSON CardRuling where
  parseJSON = genericParseJSON _cardRulingOpts

instance FromRow CardRuling where
  fromRow = CardRuling <$> field <*> field <*> field <*> field <*> field

_newCardRulingOpts :: Options
_newCardRulingOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 11 }

data NewCardRuling = NewCardRuling
  { bCardRulingRulingText :: Text
  , bCardRulingPublishedAt :: Text
  , bCardRulingSource :: Text
  , bCardRulingCardId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON NewCardRuling where
  toJSON = genericToJSON _newCardRulingOpts
instance FromJSON NewCardRuling where
  parseJSON = genericParseJSON _newCardRulingOpts

instance ToRow NewCardRuling where
  toRow b = [toField (bCardRulingRulingText b), toField (bCardRulingPublishedAt b), toField (bCardRulingSource b), toField (bCardRulingCardId b)]

data CardAbilityAbilityTypeType
  = CardAbilityAbilityTypeType_Keyword
  | CardAbilityAbilityTypeType_Activated
  | CardAbilityAbilityTypeType_Triggered
  | CardAbilityAbilityTypeType_Static
  deriving (Show, Eq, Generic)

instance ToJSON CardAbilityAbilityTypeType where
  toJSON v = case v of
    CardAbilityAbilityTypeType_Keyword -> toJSON ("Keyword" :: Text)
    CardAbilityAbilityTypeType_Activated -> toJSON ("Activated" :: Text)
    CardAbilityAbilityTypeType_Triggered -> toJSON ("Triggered" :: Text)
    CardAbilityAbilityTypeType_Static -> toJSON ("Static" :: Text)
instance FromJSON CardAbilityAbilityTypeType where
  parseJSON = withText "CardAbilityAbilityTypeType" $ \txt ->
    if txt == "Keyword" then pure CardAbilityAbilityTypeType_Keyword
    else if txt == "Activated" then pure CardAbilityAbilityTypeType_Activated
    else if txt == "Triggered" then pure CardAbilityAbilityTypeType_Triggered
    else if txt == "Static" then pure CardAbilityAbilityTypeType_Static
    else fail ("Unknown CardAbilityAbilityTypeType: " ++ show txt)

instance ToField CardAbilityAbilityTypeType where
  toField CardAbilityAbilityTypeType_Keyword = toField ("Keyword" :: Text)
  toField CardAbilityAbilityTypeType_Activated = toField ("Activated" :: Text)
  toField CardAbilityAbilityTypeType_Triggered = toField ("Triggered" :: Text)
  toField CardAbilityAbilityTypeType_Static = toField ("Static" :: Text)

instance FromField CardAbilityAbilityTypeType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "Keyword" then return CardAbilityAbilityTypeType_Keyword
    else if txt == "Activated" then return CardAbilityAbilityTypeType_Activated
    else if txt == "Triggered" then return CardAbilityAbilityTypeType_Triggered
    else if txt == "Static" then return CardAbilityAbilityTypeType_Static
    else returnError ConversionFailed f ("Unknown CardAbilityAbilityTypeType: " ++ show txt)

data CardAbilityTimingType
  = CardAbilityTimingType_Any
  | CardAbilityTimingType_Sorcery
  | CardAbilityTimingType_Instant
  | CardAbilityTimingType_Combat
  deriving (Show, Eq, Generic)

instance ToJSON CardAbilityTimingType where
  toJSON v = case v of
    CardAbilityTimingType_Any -> toJSON ("Any" :: Text)
    CardAbilityTimingType_Sorcery -> toJSON ("Sorcery" :: Text)
    CardAbilityTimingType_Instant -> toJSON ("Instant" :: Text)
    CardAbilityTimingType_Combat -> toJSON ("Combat" :: Text)
instance FromJSON CardAbilityTimingType where
  parseJSON = withText "CardAbilityTimingType" $ \txt ->
    if txt == "Any" then pure CardAbilityTimingType_Any
    else if txt == "Sorcery" then pure CardAbilityTimingType_Sorcery
    else if txt == "Instant" then pure CardAbilityTimingType_Instant
    else if txt == "Combat" then pure CardAbilityTimingType_Combat
    else fail ("Unknown CardAbilityTimingType: " ++ show txt)

instance ToField CardAbilityTimingType where
  toField CardAbilityTimingType_Any = toField ("Any" :: Text)
  toField CardAbilityTimingType_Sorcery = toField ("Sorcery" :: Text)
  toField CardAbilityTimingType_Instant = toField ("Instant" :: Text)
  toField CardAbilityTimingType_Combat = toField ("Combat" :: Text)

instance FromField CardAbilityTimingType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "Any" then return CardAbilityTimingType_Any
    else if txt == "Sorcery" then return CardAbilityTimingType_Sorcery
    else if txt == "Instant" then return CardAbilityTimingType_Instant
    else if txt == "Combat" then return CardAbilityTimingType_Combat
    else returnError ConversionFailed f ("Unknown CardAbilityTimingType: " ++ show txt)

_cardAbilityOpts :: Options
_cardAbilityOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 11 }

data CardAbility = CardAbility
  { cardAbilityId :: Int
  , cardAbilityAbilityType :: CardAbilityAbilityTypeType
  , cardAbilityKeyword :: Maybe Text
  , cardAbilityAbilityText :: Text
  , cardAbilityTiming :: Maybe CardAbilityTimingType
  , cardAbilityCardId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON CardAbility where
  toJSON = genericToJSON _cardAbilityOpts
instance FromJSON CardAbility where
  parseJSON = genericParseJSON _cardAbilityOpts

instance FromRow CardAbility where
  fromRow = CardAbility <$> field <*> field <*> field <*> field <*> field <*> field

_newCardAbilityOpts :: Options
_newCardAbilityOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 12 }

data NewCardAbility = NewCardAbility
  { bCardAbilityAbilityType :: CardAbilityAbilityTypeType
  , bCardAbilityKeyword :: Maybe Text
  , bCardAbilityAbilityText :: Text
  , bCardAbilityTiming :: Maybe CardAbilityTimingType
  , bCardAbilityCardId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON NewCardAbility where
  toJSON = genericToJSON _newCardAbilityOpts
instance FromJSON NewCardAbility where
  parseJSON = genericParseJSON _newCardAbilityOpts

instance ToRow NewCardAbility where
  toRow b = [toField (bCardAbilityAbilityType b), toField (bCardAbilityKeyword b), toField (bCardAbilityAbilityText b), toField (bCardAbilityTiming b), toField (bCardAbilityCardId b)]

data DeckFormatType
  = DeckFormatType_Standard
  | DeckFormatType_Extended
  | DeckFormatType_Legacy
  | DeckFormatType_Vintage
  | DeckFormatType_Commander
  | DeckFormatType_Draft
  deriving (Show, Eq, Generic)

instance ToJSON DeckFormatType where
  toJSON v = case v of
    DeckFormatType_Standard -> toJSON ("Standard" :: Text)
    DeckFormatType_Extended -> toJSON ("Extended" :: Text)
    DeckFormatType_Legacy -> toJSON ("Legacy" :: Text)
    DeckFormatType_Vintage -> toJSON ("Vintage" :: Text)
    DeckFormatType_Commander -> toJSON ("Commander" :: Text)
    DeckFormatType_Draft -> toJSON ("Draft" :: Text)
instance FromJSON DeckFormatType where
  parseJSON = withText "DeckFormatType" $ \txt ->
    if txt == "Standard" then pure DeckFormatType_Standard
    else if txt == "Extended" then pure DeckFormatType_Extended
    else if txt == "Legacy" then pure DeckFormatType_Legacy
    else if txt == "Vintage" then pure DeckFormatType_Vintage
    else if txt == "Commander" then pure DeckFormatType_Commander
    else if txt == "Draft" then pure DeckFormatType_Draft
    else fail ("Unknown DeckFormatType: " ++ show txt)

instance ToField DeckFormatType where
  toField DeckFormatType_Standard = toField ("Standard" :: Text)
  toField DeckFormatType_Extended = toField ("Extended" :: Text)
  toField DeckFormatType_Legacy = toField ("Legacy" :: Text)
  toField DeckFormatType_Vintage = toField ("Vintage" :: Text)
  toField DeckFormatType_Commander = toField ("Commander" :: Text)
  toField DeckFormatType_Draft = toField ("Draft" :: Text)

instance FromField DeckFormatType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "Standard" then return DeckFormatType_Standard
    else if txt == "Extended" then return DeckFormatType_Extended
    else if txt == "Legacy" then return DeckFormatType_Legacy
    else if txt == "Vintage" then return DeckFormatType_Vintage
    else if txt == "Commander" then return DeckFormatType_Commander
    else if txt == "Draft" then return DeckFormatType_Draft
    else returnError ConversionFailed f ("Unknown DeckFormatType: " ++ show txt)

data DeckArchetypeType
  = DeckArchetypeType_Aggro
  | DeckArchetypeType_Control
  | DeckArchetypeType_Midrange
  | DeckArchetypeType_Combo
  | DeckArchetypeType_Prison
  | DeckArchetypeType_Tempo
  deriving (Show, Eq, Generic)

instance ToJSON DeckArchetypeType where
  toJSON v = case v of
    DeckArchetypeType_Aggro -> toJSON ("Aggro" :: Text)
    DeckArchetypeType_Control -> toJSON ("Control" :: Text)
    DeckArchetypeType_Midrange -> toJSON ("Midrange" :: Text)
    DeckArchetypeType_Combo -> toJSON ("Combo" :: Text)
    DeckArchetypeType_Prison -> toJSON ("Prison" :: Text)
    DeckArchetypeType_Tempo -> toJSON ("Tempo" :: Text)
instance FromJSON DeckArchetypeType where
  parseJSON = withText "DeckArchetypeType" $ \txt ->
    if txt == "Aggro" then pure DeckArchetypeType_Aggro
    else if txt == "Control" then pure DeckArchetypeType_Control
    else if txt == "Midrange" then pure DeckArchetypeType_Midrange
    else if txt == "Combo" then pure DeckArchetypeType_Combo
    else if txt == "Prison" then pure DeckArchetypeType_Prison
    else if txt == "Tempo" then pure DeckArchetypeType_Tempo
    else fail ("Unknown DeckArchetypeType: " ++ show txt)

instance ToField DeckArchetypeType where
  toField DeckArchetypeType_Aggro = toField ("Aggro" :: Text)
  toField DeckArchetypeType_Control = toField ("Control" :: Text)
  toField DeckArchetypeType_Midrange = toField ("Midrange" :: Text)
  toField DeckArchetypeType_Combo = toField ("Combo" :: Text)
  toField DeckArchetypeType_Prison = toField ("Prison" :: Text)
  toField DeckArchetypeType_Tempo = toField ("Tempo" :: Text)

instance FromField DeckArchetypeType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "Aggro" then return DeckArchetypeType_Aggro
    else if txt == "Control" then return DeckArchetypeType_Control
    else if txt == "Midrange" then return DeckArchetypeType_Midrange
    else if txt == "Combo" then return DeckArchetypeType_Combo
    else if txt == "Prison" then return DeckArchetypeType_Prison
    else if txt == "Tempo" then return DeckArchetypeType_Tempo
    else returnError ConversionFailed f ("Unknown DeckArchetypeType: " ++ show txt)

_deckOpts :: Options
_deckOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 4 }

data Deck = Deck
  { deckId :: Int
  , deckName :: Text
  , deckDescription :: Maybe Text
  , deckFormat :: DeckFormatType
  , deckIsPublic :: Bool
  , deckIsTournamentLegal :: Bool
  , deckArchetype :: Maybe DeckArchetypeType
  , deckWins :: Int
  , deckLosses :: Int
  , deckDraws :: Int
  , deckCreatedAt :: Text
  , deckUpdatedAt :: Text
  , deckPlayerId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON Deck where
  toJSON = genericToJSON _deckOpts
instance FromJSON Deck where
  parseJSON = genericParseJSON _deckOpts

instance FromRow Deck where
  fromRow = Deck <$> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field

_newDeckOpts :: Options
_newDeckOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 5 }

data NewDeck = NewDeck
  { bDeckName :: Text
  , bDeckDescription :: Maybe Text
  , bDeckFormat :: DeckFormatType
  , bDeckIsPublic :: Bool
  , bDeckIsTournamentLegal :: Bool
  , bDeckArchetype :: Maybe DeckArchetypeType
  , bDeckWins :: Int
  , bDeckLosses :: Int
  , bDeckDraws :: Int
  , bDeckCreatedAt :: Text
  , bDeckUpdatedAt :: Text
  , bDeckPlayerId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON NewDeck where
  toJSON = genericToJSON _newDeckOpts
instance FromJSON NewDeck where
  parseJSON = genericParseJSON _newDeckOpts

instance ToRow NewDeck where
  toRow b = [toField (bDeckName b), toField (bDeckDescription b), toField (bDeckFormat b), toField (bDeckIsPublic b), toField (bDeckIsTournamentLegal b), toField (bDeckArchetype b), toField (bDeckWins b), toField (bDeckLosses b), toField (bDeckDraws b), toField (bDeckCreatedAt b), toField (bDeckUpdatedAt b), toField (bDeckPlayerId b)]

_deckCardOpts :: Options
_deckCardOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 8 }

data DeckCard = DeckCard
  { deckCardId :: Int
  , deckCardQuantity :: Int
  , deckCardIsCommander :: Bool
  , deckCardDeckId :: Maybe Int
  , deckCardCardId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON DeckCard where
  toJSON = genericToJSON _deckCardOpts
instance FromJSON DeckCard where
  parseJSON = genericParseJSON _deckCardOpts

instance FromRow DeckCard where
  fromRow = DeckCard <$> field <*> field <*> field <*> field <*> field

_newDeckCardOpts :: Options
_newDeckCardOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 9 }

data NewDeckCard = NewDeckCard
  { bDeckCardQuantity :: Int
  , bDeckCardIsCommander :: Bool
  , bDeckCardDeckId :: Maybe Int
  , bDeckCardCardId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON NewDeckCard where
  toJSON = genericToJSON _newDeckCardOpts
instance FromJSON NewDeckCard where
  parseJSON = genericParseJSON _newDeckCardOpts

instance ToRow NewDeckCard where
  toRow b = [toField (bDeckCardQuantity b), toField (bDeckCardIsCommander b), toField (bDeckCardDeckId b), toField (bDeckCardCardId b)]

_deckSideboardCardOpts :: Options
_deckSideboardCardOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 17 }

data DeckSideboardCard = DeckSideboardCard
  { deckSideboardCardId :: Int
  , deckSideboardCardQuantity :: Int
  , deckSideboardCardDeckId :: Maybe Int
  , deckSideboardCardCardId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON DeckSideboardCard where
  toJSON = genericToJSON _deckSideboardCardOpts
instance FromJSON DeckSideboardCard where
  parseJSON = genericParseJSON _deckSideboardCardOpts

instance FromRow DeckSideboardCard where
  fromRow = DeckSideboardCard <$> field <*> field <*> field <*> field

_newDeckSideboardCardOpts :: Options
_newDeckSideboardCardOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 18 }

data NewDeckSideboardCard = NewDeckSideboardCard
  { bDeckSideboardCardQuantity :: Int
  , bDeckSideboardCardDeckId :: Maybe Int
  , bDeckSideboardCardCardId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON NewDeckSideboardCard where
  toJSON = genericToJSON _newDeckSideboardCardOpts
instance FromJSON NewDeckSideboardCard where
  parseJSON = genericParseJSON _newDeckSideboardCardOpts

instance ToRow NewDeckSideboardCard where
  toRow b = [toField (bDeckSideboardCardQuantity b), toField (bDeckSideboardCardDeckId b), toField (bDeckSideboardCardCardId b)]

_deckTagOpts :: Options
_deckTagOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 7 }

data DeckTag = DeckTag
  { deckTagId :: Int
  , deckTagName :: Text
  , deckTagColor :: Maybe Text
  } deriving (Show, Generic)

instance ToJSON DeckTag where
  toJSON = genericToJSON _deckTagOpts
instance FromJSON DeckTag where
  parseJSON = genericParseJSON _deckTagOpts

instance FromRow DeckTag where
  fromRow = DeckTag <$> field <*> field <*> field

_newDeckTagOpts :: Options
_newDeckTagOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 8 }

data NewDeckTag = NewDeckTag
  { bDeckTagName :: Text
  , bDeckTagColor :: Maybe Text
  } deriving (Show, Generic)

instance ToJSON NewDeckTag where
  toJSON = genericToJSON _newDeckTagOpts
instance FromJSON NewDeckTag where
  parseJSON = genericParseJSON _newDeckTagOpts

instance ToRow NewDeckTag where
  toRow b = [toField (bDeckTagName b), toField (bDeckTagColor b)]

_deckTagAssignmentOpts :: Options
_deckTagAssignmentOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 17 }

data DeckTagAssignment = DeckTagAssignment
  { deckTagAssignmentId :: Int
  , deckTagAssignmentDeckId :: Maybe Int
  , deckTagAssignmentTagId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON DeckTagAssignment where
  toJSON = genericToJSON _deckTagAssignmentOpts
instance FromJSON DeckTagAssignment where
  parseJSON = genericParseJSON _deckTagAssignmentOpts

instance FromRow DeckTagAssignment where
  fromRow = DeckTagAssignment <$> field <*> field <*> field

_newDeckTagAssignmentOpts :: Options
_newDeckTagAssignmentOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 18 }

data NewDeckTagAssignment = NewDeckTagAssignment
  { bDeckTagAssignmentDeckId :: Maybe Int
  , bDeckTagAssignmentTagId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON NewDeckTagAssignment where
  toJSON = genericToJSON _newDeckTagAssignmentOpts
instance FromJSON NewDeckTagAssignment where
  parseJSON = genericParseJSON _newDeckTagAssignmentOpts

instance ToRow NewDeckTagAssignment where
  toRow b = [toField (bDeckTagAssignmentDeckId b), toField (bDeckTagAssignmentTagId b)]

