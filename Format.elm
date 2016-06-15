module Format exposing (..) --where

import String


type FormatStyle
  = Normal
  | Quotation
  | AuthorOfQuotation


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


