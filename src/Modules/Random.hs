#! /usr/bin/env runhugs +l
--
-- Random.hs
-- Copyright (C) 2015 haetze <haetze@haetze-MacBookAir>
--
-- Distributed under terms of the MIT license.
--

module Random where


import System.Random

randomSymbole ::Random a => (a, a) ->   IO a
randomSymbole range = do
  g <- newStdGen
  let [x] = take 1 $ randomRs range g 
  return x

randomNumber:: (Random a, Num a, Show a) => (a,a) -> IO a
randomNumber r = randomSymbole r


randomNumbers ::(Random a, Num a, Show a) => [a] -> IO [a]
randomNumbers [] = return []
randomNumbers (_:xs) = do 
  x <- randomNumber (0, 10) 
  xs <- randomNumbers xs
  return (x:xs)

nRandomNumbers::Int -> IO [Int]
nRandomNumbers n = randomNumbers [1..n]


findNumber::(Num a, Eq a) => a -> [a] -> [a]
findNumber _ [] = []
findNumber n (x:xs) | n == x = []
        | n /= x = x : (findNumber n xs)

findNumberInMonad:: (Num a, Eq a, Monad m) => a -> [a] -> m [a]
findNumberInMonad n xs = return (findNumber n xs)
