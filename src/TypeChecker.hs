module TypeChecker where

import Lexer
import Parser

data Type = BB | II

instance Show Type where
  show BB = "Boolean"
  show II = "Integer"

binErrMsg :: Token -> Expr a -> Type -> Expr a -> Type -> String
binErrMsg op l lt r rt =
  show op
    <> " is not defined for "
    <> show l
    <> " :: "
    <> show lt
    <> " and "
    <> show r
    <> " :: "
    <> show rt

unErrMsg :: Token -> Expr a -> Type -> String
unErrMsg op e t =
  show op
    <> " is not defined for "
    <> show e
    <> " :: "
    <> show t

typeCheck :: Expr a -> Either String Type
typeCheck (Figure _) = return II
typeCheck (Boolean _) = return BB
typeCheck (Pth e) = typeCheck e
typeCheck (Binary op l r) = do
  lt <- typeCheck l
  rt <- typeCheck r
  case (op, lt, rt) of
    (Add, II, II) -> return II
    (Sub, II, II) -> return II
    (Mul, II, II) -> return II
    (Div, II, II) -> return II
    (Equal, II, II) -> return BB
    (Equal, BB, BB) -> return BB
    (Equal, II, BB) -> return BB
    (Equal, BB, II) -> return BB
    (NotEqual, II, II) -> return BB
    (NotEqual, BB, BB) -> return BB
    (NotEqual, II, BB) -> return BB
    (NotEqual, BB, II) -> return BB
    (And, BB, BB) -> return BB
    (Or, BB, BB) -> return BB
    (_, _, _) -> Left $ binErrMsg op l lt r rt
typeCheck (Unary op e) = do
  t <- typeCheck e
  case (op, t) of
    (Add, II) -> return II
    (Sub, II) -> return II
    (Not, BB) -> return BB
    (_, t) -> Left $ unErrMsg op e t