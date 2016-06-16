module AppCss exposing (..) --where

import Css exposing (..)
import Css.Elements exposing (..)
import Css.Namespace exposing (namespace)


type CssClasses
    = NavBar
    | Title


type CssIds
    = Page


css =
    (stylesheet << namespace "writersDesk")
    [ body
        [ overflowX auto
        , minWidth (px 1280)
        ]
    , (#) Page
        [ backgroundColor (rgb 200 128 64)
        , color (hex "CCFFFF")
        , width (pct 100)
        , height (pct 100)
        , boxSizing borderBox
        , padding (px 8)
        , margin zero
        ]
    , (.) NavBar
        [ margin zero
        , padding zero
        , children
            [ li
                [ (display inlineBlock) |> important
                , color primaryAccentColor
                ]
            ]
        ]
    ,  (.) Title
        [ color primaryAccentColor
        , fontSize (em 3)
        , fontFamily "SuisseIntl-Thin"
        , paddingTop (em 0.5)
        ]
    ]


primaryAccentColor =
    hex "ccffaa"