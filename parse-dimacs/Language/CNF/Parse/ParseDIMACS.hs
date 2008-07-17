{-
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

    Copyright 2008 Denis Bueno
-}

-- | A simple Parsec module for parsing CNF files in DIMACS format.
module Language.CNF.Parse.ParseDIMACS
    ( parseFile
    , CNF(..) )
    where

import Control.Monad
import Prelude hiding (readFile, map)
import Text.Parsec( ParseError )
import Text.Parsec.ByteString
import Text.Parsec.Char
import Text.Parsec.Combinator
import Text.Parsec.Prim( try, unexpected )
import qualified Text.Parsec.Token as T


data CNF = CNF
    { numVars    :: !Int
    , numClauses :: !Int
    , clauses    :: ![[Int]] } deriving Show

-- | Parse a file containing DIMACS CNF data.
parseFile :: FilePath -> IO (Either ParseError CNF)
parseFile = parseFromFile cnf

-- A DIMACS CNF file contains a header of the form "p cnf <numVars>
-- <numClauses>" and then a bunch of 0-terminated clauses.
cnf :: Parser CNF
cnf = uncurry CNF `fmap` cnfHeader `ap` lexeme (many1 clause)

cnfHeader :: Parser (Int, Int)
cnfHeader = do
    whiteSpace
    char 'p' >> many1 space -- Can't use symbol here because it uses
                            -- whiteSpace, which will treat the following
                            -- "cnf" as a comment.
    symbol "cnf"
    (,) `fmap` natural `ap` natural

clause :: Parser [Int]
clause = lexeme int `manyTill` try (symbol "0")


-- token parser
tp = T.makeTokenParser $ T.LanguageDef 
   { T.commentStart = ""
   , T.commentEnd = ""
   , T.commentLine = "c"
   , T.nestedComments = False
   , T.identStart = unexpected "ParseDIMACS bug: shouldn't be parsing identifiers..."
   , T.identLetter = unexpected "ParseDIMACS bug: shouldn't be parsing identifiers..."
   , T.opStart = unexpected "ParseDIMACS bug: shouldn't be parsing operators..."
   , T.opLetter = unexpected "ParseDIMACS bug: shouldn't be parsing operators..."
   , T.reservedNames = ["p", "cnf"]
   , T.reservedOpNames = []
   , T.caseSensitive = True
   }

natural :: Parser Int
natural = fromIntegral `fmap` T.natural tp
int :: Parser Int
int = fromIntegral `fmap` T.integer tp
symbol = T.symbol tp
whiteSpace = T.whiteSpace tp
lexeme = T.lexeme tp