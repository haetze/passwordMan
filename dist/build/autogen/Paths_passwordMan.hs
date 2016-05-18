module Paths_passwordMan (
    version,
    getBinDir, getLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
catchIO = Exception.catch

version :: Version
version = Version [0,1,0,0] []
bindir, libdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "/home/haetze/.cabal/bin"
libdir     = "/home/haetze/.cabal/lib/x86_64-freebsd-ghc-7.10.2/passwordMan-0.1.0.0-Cexq7S4lRPT20WmKr6vPNn"
datadir    = "/home/haetze/.cabal/share/x86_64-freebsd-ghc-7.10.2/passwordMan-0.1.0.0"
libexecdir = "/home/haetze/.cabal/libexec"
sysconfdir = "/home/haetze/.cabal/etc"

getBinDir, getLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "passwordMan_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "passwordMan_libdir") (\_ -> return libdir)
getDataDir = catchIO (getEnv "passwordMan_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "passwordMan_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "passwordMan_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
