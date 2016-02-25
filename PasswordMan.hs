#! /usr/bin/env runhugs +l
--
-- PasswordMan.hs
-- Copyright (C) 2015 haetze <haetze@ubuntu>
--
-- Distributed under terms of the MIT license.
--

module PasswordMan where

import Data.Maybe
import System.IO
import Random
import qualified Data.ByteString.Char8 as B
import Crypto

type Username = String
type PWD = String
type Service = String
type FileURL = String

data SUP = SUP Service Username PWD
  deriving(Show, Read)

data Passwords = Passwords [SUP]
  deriving(Show, Read)

createPasswordWithChar:: Int -> IO PWD
createPasswordWithChar 0 = return ""
createPasswordWithChar n = do  
  c <- randomSymbole ('0', 'z')
  cs <- createPasswordWithChar $ n-1
  return (c:cs)

createPasswordsFile:: FilePath -> String -> String -> IO ()
createPasswordsFile home file key= do
  f <- openFile (home ++ file) WriteMode
  B.hPutStr f $ ciph key "Passwords []"
  hClose f

createStandartPassword:: IO PWD
createStandartPassword = createPasswordWithChar 16

createPasswordForService:: Service -> Username -> IO SUP
createPasswordForService s u = do
  pwd <- createStandartPassword
  return $ SUP s u pwd

createAccountForService:: Service -> Username -> Passwords -> IO Passwords
createAccountForService s u pwd = do 
  ac <- createPasswordForService s u
  let nPwd = insertAccount ac pwd
  return nPwd

createPasswordList:: Passwords
createPasswordList = Passwords []

presentAccount:: SUP -> String
presentAccount (SUP s u p) = "Account at " ++ s ++ ":" ++ u ++ "->" ++ p ++ "\n"

presentAccountsInFile:: Passwords -> String
presentAccountsInFile (Passwords []) = "\n"
presentAccountsInFile (Passwords (x:xs)) = presentAccount x ++ presentAccountsInFile (Passwords xs)

createPasswordsFromFileURL:: FileURL ->String -> IO Passwords
createPasswordsFromFileURL url password = do
  file <- B.readFile url
  let f = decipher password (B.unpack file)
  let pwd = read (B.unpack f)
  return pwd

update:: Service -> Username -> PWD -> Passwords -> Passwords
update s u p pwd = case checkForExistense s u pwd of
  True -> insert s u p a
  False -> insert s u p pwd 
  where
    a = remove s u pwd 

insertAccount:: SUP -> Passwords -> Passwords
insertAccount (SUP s u p) pwd = insert s u p pwd 

insert:: Service -> Username -> PWD -> Passwords -> Passwords
insert s u p pwd = case checkForExistense s u pwd of
  False -> (SUP s u p) <> pwd 
  True -> update s u p pwd 

remove:: Service -> Username -> Passwords -> Passwords
remove s u p = case checkForExistense s u p of
  False -> p 
  True -> remover [] s u p

remover:: [SUP] -> Service -> Username -> Passwords -> Passwords
remover a s u (Passwords ((SUP se us p):xs)) | s == se && us == u = Passwords (a ++ xs)
              | otherwise = remover ((SUP se us p):a) s u (Passwords xs)

checkForExistense:: Service -> Username -> Passwords -> Bool
checkForExistense _ _ (Passwords []) = False
checkForExistense service user (Passwords ((SUP s u _):xs)) | service == s && user == u = True
                 | otherwise = checkForExistense service user $ Passwords xs

checkForExistenseService:: Service -> Passwords -> Bool
checkForExistenseService _ (Passwords []) = False
checkForExistenseService service (Passwords ((SUP s _ _):xs)) | service == s = True
                 | otherwise = checkForExistenseService service $ Passwords xs

lookupService:: Service -> Passwords -> Maybe [SUP]
lookupService s pwd = case checkForExistenseService s pwd of
  False -> Nothing
  True -> Just $ upLooker s pwd

upLooker:: Service -> Passwords -> [SUP]
upLooker s (Passwords []) = []
upLooker s (Passwords ((SUP se u p):xs)) | s == se = (SUP se u p) : upLooker s (Passwords xs)
                | otherwise = upLooker s (Passwords xs)

lookupUserAtService:: Username -> Service -> Passwords -> Maybe SUP
lookupUserAtService u s pwd = lookupService s pwd >>= findUser u

findUser:: Username -> [SUP] -> Maybe SUP
findUser u [] = Nothing
findUser u ((SUP s us p):xs) | u == us = Just (SUP s us p)
           | otherwise = findUser u xs

(<>) :: SUP -> Passwords -> Passwords
a <> (Passwords as) = Passwords (a:as)

