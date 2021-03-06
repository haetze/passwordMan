#! /usr/bin/env runhugs +l
--
-- Crypto.hs
-- Copyright (C) 2015 haetze <haetze@home>
--
-- Distributed under terms of the MIT license.
--

module Crypto where

import Crypto.Cipher
--import Crypto.Cipher.Types
import qualified Data.ByteString.Char8 as B


createMult16String:: String -> String
createMult16String x | length x `mod` 16 == 0 = x
                     | otherwise              = createMult16String $ x++" "


createKey x = key 
  where 
  Right key = makeKey . B.pack $ createMult16String x

createCipher:: String -> AES128
createCipher = cipherInit . createKey



--ciph:: String -> String -> String
ciph key secret =  cr 
  where 
  ks = B.pack $ createMult16String secret
  cr = ecbEncrypt (createCipher key) ks 

--decipher:: String -> String -> String
decipher key cr = secret
  where
  secret = ecbDecrypt (createCipher key) (B.pack cr)




