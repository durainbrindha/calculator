module Logger where

import Control.Monad
import Data.Map.Strict
import Evaluator
import Lexer
import Parser
import Utils

prettyPrint :: Expr -> Map String Expr -> Bool -> IO ()
prettyPrint e n showTree = do
  case eval e n of
    Left msg -> putStrLn msg
    Right v -> do
      putStrLn $ disp v
      when showTree $ logST e "" True
  putStr "\n"

logST :: Expr -> String -> Bool -> IO ()
logST (If b l r) indent isLast = printBinaryExpr (disp b) indent isLast l r
logST (Binary op l r) indent isLast = printBinaryExpr (disp op) indent isLast l r
logST (Pth e) indent isLast = printUnaryExpr "()" indent isLast e
logST (Unary op e) indent isLast = printUnaryExpr (disp op) indent isLast e
logST (Bind n e) indent isLast = printUnaryExpr n indent isLast e
logST Unit indent _ = do
  putStrLn $ indent <> "└──" <> disp Unit
logST (Figure i) indent _ = do
  putStrLn $ indent <> "└──" <> show i
logST (Boolean b) indent _ = do
  putStrLn $ indent <> "└──" <> show b

type Indent = String

type IsLast = Bool

type Symbol = String

printBinaryExpr :: Symbol -> Indent -> IsLast -> Expr -> Expr -> IO ()
printBinaryExpr sym indent isLast l r =
  let childIndent = indent <> if isLast then "   " else "|  "
      marker = if isLast then "└──" else "├──"
   in do
        putStrLn $ indent <> marker <> sym
        logST l childIndent False
        logST r childIndent True

printUnaryExpr :: Symbol -> Indent -> IsLast -> Expr -> IO ()
printUnaryExpr sym indent isLast e =
  let childIndent = indent <> if isLast then "   " else "|  "
      marker = if isLast then "└──" else "├──"
   in do
        putStrLn $ indent <> marker <> sym
        logST e childIndent True