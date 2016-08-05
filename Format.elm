module Format exposing (..) --where

import String
import String.Extra


type FormatStyle
  = Normal
  | Quotation
  | AuthorOfQuotation
  | Title


paragraphBreak : String
paragraphBreak =
  """ 

  """

addFinalPeriod : String -> String
addFinalPeriod answer = 
  if String.endsWith "." answer then
    answer
  else
    answer ++ "."


addSpaceBetweenSentences : String -> String
addSpaceBetweenSentences answer =
  answer ++ " "


trimExtraWhitespace : String -> String
trimExtraWhitespace answer =
  (String.join " " << String.words) answer


removeSpaceBeforePeriod : String -> String
removeSpaceBeforePeriod answer =
  (String.join "." << List.map String.trimRight << String.split ".") answer


capitalizeFirstCharacter : String -> String
capitalizeFirstCharacter answer =
  let
    firstCharacter = String.left 1 answer
    remainingString = String.dropLeft 1 answer
    capitalLetter = String.toUpper firstCharacter
    capitalizedSentence = String.concat [ capitalLetter, remainingString ]
  in
    capitalizedSentence


addPossibleQuotes : FormatStyle -> String -> String
addPossibleQuotes formatStyle answer = 
  case formatStyle of
    Quotation -> 
      --">" ++ answer ++ paragraphBreak
      "*" ++ "“" ++ answer ++ "”" ++ "*"
    _ ->
      answer


formatAuthorOfQuotation : FormatStyle -> String -> String
formatAuthorOfQuotation formatStyle answer =
  case formatStyle of
    AuthorOfQuotation -> 
      "— " ++ "*" ++ answer ++ "*"
    _ ->
      answer

formatTitle : String -> String
formatTitle answer =
  let
    capitalizedAnswer =
      String.Extra.toTitleCase answer

    listOfCapitalizedWords =
      String.words capitalizedAnswer

    intelligentlyCapitalize id word =
      let
        shouldBeCapitalized =
          (isArticle word) || (isPreposition word) || (isCoordinatingConjunction word)

        isntTheFirstOrLastWord =
          if id > 0 && id < List.length listOfCapitalizedWords - 1 then
            True
          else
            False
      in
      if shouldBeCapitalized && isntTheFirstOrLastWord then
        String.Extra.decapitalize word
      else
        word

    -- Refactor this and use indexedMap to prevent the first and last word from being decapitalized
    listOfIntelligentlyCapitalizedWords =
      List.indexedMap intelligentlyCapitalize listOfCapitalizedWords 

    intelligentlyCapitalizedString =
      String.join " " listOfIntelligentlyCapitalizedWords
  in
    --capitalizedAnswer ++ paragraphBreakn
    intelligentlyCapitalizedString ++ paragraphBreak


isArticle : String -> Bool
isArticle word =
  List.member (String.toLower word) articles


articles : List String
articles =
  ["the", "a", "an"]


isPreposition : String -> Bool
isPreposition word =
  List.member (String.toLower word) prepositions


prepositions : List String
prepositions =
  ["at", "by", "in", "on", "onto","of", "to", "with", "from", "or", "is"]


isCoordinatingConjunction : String -> Bool
isCoordinatingConjunction word =
  List.member (String.toLower word) coordinatingConjunctions


coordinatingConjunctions : List String
coordinatingConjunctions =
  ["and", "but", "for", "nor", "or", "yet" ]
