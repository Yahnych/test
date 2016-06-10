module Data exposing (..) --where
import Markdown

{-
My only suggested change at this time is to change question #4 to:
“What is the title of the work you have excerpted and who is its author?”
-}

type alias Question = 
  { question : String
  , paragraphId : Int
  , rows : Int
  , maxlength : Int
  , format : Format
  }

type Format
  = Normal
  | Quotation
  | AuthorOfQuotation

title = "Authors' Advice to Writers"

instructions = 
  """
Answer the questions on the left to build your essay.
  """

questions : List Question
questions =
  [ 
    { question = 
        """
Find a quotation from one of the authors in this lesson 
that you think is particularly good advice for writers. This can be any quotation from 
**Umberto Eco**, **Susan Sontag**, **Stephen King** and/or **Guy Gavriel Kay**, 
of up to 200 words. Copy the quotation directly into the following text field:
        """
    , paragraphId = 0
    , rows = 7
    , maxlength = 700
    , format = Quotation
    }
  ,
    { question = 
        """
Who wrote the quotation that you listed above?
        """
    , paragraphId = 0
    , rows = 1
    , maxlength = 0
    , format = AuthorOfQuotation
    }
  ,
    { question = 
        """
Choose a short excerpt from one of your favourite authors that you feel is a good piece 
of writing, and seems to follow the author’s advice that you listed in step 1. 
Copy the excerpt into the following text field (maximum 200 words):
        """
    , paragraphId = 1
    , rows = 7
    , maxlength = 700
    , format = Quotation
    }
  ,
    { question = 
        """
Who wrote the quotation that you listed above?
        """
    , paragraphId = 1
    , rows = 1
    , maxlength = 0
    , format = AuthorOfQuotation
    }
  ,
    { question = 
        """
Why do you feel the excerpt that you chose is an effective piece of writing?
(For example: what do you like about it, how does it make you feel, or does it express
important ideas?)
        """
    , paragraphId = 2
    , rows = 7
    , maxlength = 0
    , format = Normal
    }
  ,
    { question = 
        """
Explain how the writing excerpt you chose follows the advice of the author that you selected.
Make sure to prove that what you are saying is true by including direct quotations both from the 
writing excerpt and the author’s advice that you chose.
        """
    , paragraphId = 2
    , rows = 7
    , maxlength = 0
    , format = Normal
    }
  ,
    { question = 
        """
Choose one more example from the writing excerpt you chose and explain how it 
follows the author’s advice. Again, make sure to include direct quotations that
prove your point.
        """
    , paragraphId = 3
    , rows = 7
    , maxlength = 0
    , format = Normal
    }
  ,
    { question = 
        """
What general benefit do you feel the author’s advice had on the overall 
quality of the writing excerpt you chose?         
        """
    , paragraphId = 3
    , rows = 7
    , maxlength = 0
    , format = Normal
    }
  ]