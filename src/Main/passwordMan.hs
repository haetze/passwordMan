#! /usr/bin/env runhugs +l
--
-- passwordMan.hs
-- Copyright (C) 2015 haetze <haetze@ubuntu>
--
-- Distributed under terms of the MIT license.
--

{-# LANGUAGE BangPatterns #-}

import Data.Maybe
import System.Environment(getArgs)
import System.IO
import System.Directory
import PasswordMan
import qualified Data.ByteString.Char8 as B
import Crypto
import System.Posix.Terminal
import System.Posix.IO (stdInput)

main:: IO ()
main = do
  home <- getHomeDirectory
  args <- getArgs
  putStrLn "Enter password:" 
  password <- getPassword
  checkpassWordFile home password
  case args of
    ("lookupUserAt":s:u:_) ->do
       pwd <- createPasswordsFromFileURL (home++"/.passwords") password
       putStr . pre $ lookupUserAtService u s pwd
    ("lookupService":s:_) ->do 
       pwd <- createPasswordsFromFileURL (home++"/.passwords") password
       shower $ lookupService s pwd
    ("showAll":_) -> do
       pwd <- createPasswordsFromFileURL (home++"/.passwords") password
       putStr $ presentAccountsInFile pwd
    ("update":s:u:p:_) -> do
      !pwd <- createPasswordsFromFileURL (home++"/.passwords") password
      let nP = update s u p pwd 
      writeToDisk (show nP) password 
    ("insert":s:u:p:_) -> do 
      !pwd <- createPasswordsFromFileURL (home++"/.passwords") password
      let nP = insert s u p pwd 
      writeToDisk (show nP) password 
    ("remove":s:u:_) -> do 
      !pwd <- createPasswordsFromFileURL (home++"/.passwords") password
      let nP = remove s u pwd 
      writeToDisk (show nP) password 
    ("createPassword":_) -> do
      p <- createStandartPassword
      putStr $ "The password created for you is: " ++ p ++ "\n"
    ("createUser":s:u:_) -> do
      !p <- createPasswordsFromFileURL (home++"/.passwords") password
      nP <- createAccountForService s u p
      writeToDisk (show nP) password 
      putStrLn . pre $ lookupUserAtService u s nP
    _ -> putStrLn $ "Command: lookupUserAt <User> <Service> \n lookupService <Service> \n " ++
      "update <Service> <User> <Password> \n insert <Service> <User> <Password> \n remove <Service> <User> \n showAll\n createPassword\n createUser <Service> <User>\n"


shower:: Maybe [SUP] -> IO ()
shower Nothing        = putStrLn "nothing found"
shower (Just (x:[])) = putStr $ presentAccount x
shower (Just (x:xs)) = do
  putStr $ presentAccount x
  shower $ Just xs

pre:: Maybe SUP -> String
pre Nothing = "nothing found" 
pre (Just s) = presentAccount s

writeToDisk:: String -> String -> IO ()
writeToDisk s  p = do 
  home <- getHomeDirectory
  B.writeFile (home ++ "/.passwords") (ciph p s)

checkpassWordFile home key = do
  con <- getDirectoryContents home
  case (elem ".passwords" con) of
   True -> return ()
   False -> do 
    putStrLn "passwords file missing, a new (empty) is created"
    createPasswordsFile home "/.passwords" key


getPassword:: IO String
getPassword = do
  tc <- getTerminalAttributes stdInput
  setTerminalAttributes stdInput (withoutMode tc EnableEcho) Immediately
  password <- getLine
  setTerminalAttributes stdInput tc Immediately
  return password



