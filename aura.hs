-- AURA package manager for Arch Linux

-- System libraries
import Control.Concurrent (threadDelay)
import System.Environment (getArgs)
import System.IO (stdout, hFlush)
import System.Console.GetOpt
import Text.Printf (printf)

-- Custom libraries
import Pacman

data MouthState = Open | Closed deriving (Eq)

data Flag = AURInstall | Version | Help deriving (Eq)

options :: [OptDescr Flag]
options = [ Option ['A'] ["aursync"] (NoArg AURInstall) aDesc
          , Option ['V'] []          (NoArg Version)    ""
          , Option ['h'] ["help"]    (NoArg Help)       ""
          ]
    where aDesc = "Install from the AUR."

auraUsageMsg :: String
auraUsageMsg = usageInfo "AURA only operations:" options

-- Taken from: figlet -f small "aura"
auraLogo :: String
auraLogo = " __ _ _  _ _ _ __ _ \n" ++ 
           "/ _` | || | '_/ _` |\n" ++
           "\\__,_|\\_,_|_| \\__,_|"

openMouth :: [String]
openMouth = [ " .--."
            , "/ _.-'"
            , "\\  '-."
            , " '--'"
            ]

closedMouth :: [String]
closedMouth = [ " .--."
              , "/ _..\\"
              , "\\  ''/"
              , " '--'"
              ]

pill :: [String]
pill = [ ""
       , ".-."
       , "'-'"
       , ""
       ]       

renderPill :: Int -> [String]
renderPill pad = map (padString pad) pill

renderPills :: Int -> [[String]]
renderPills pills = undefined

renderPacmanHead :: Int -> MouthState -> [String]
renderPacmanHead pad Open   = map (padString pad) openMouth
renderPacmanHead pad Closed = map (padString pad) closedMouth

padString :: Int -> String -> String
padString pad cs = getPad ++ cs
    where getPad = concat . take pad . repeat $ " "

{-
argError :: String -> a
argError msg = error $ usageInfo (msg ++ "\n" ++ usageMsg) options
-}


main = do
  args <- getArgs
  opts <- parseOpts args
  executeOpts opts

parseOpts :: [String] -> IO ([Flag],[String],[String])
parseOpts args = case getOpt' Permute options args of
                   (opts,nonOpts,pacOpts,_) -> return (opts,nonOpts,pacOpts) 

executeOpts :: ([Flag],[String],[String]) -> IO ()
executeOpts (flags,input,pacOpts) =
    case flags of
      [Help]       -> getPacmanHelpMsg >>= putStrLn . getHelpMsg
      [Version]    -> getVersionInfo >>= animateVersionMsg
      [AURInstall] -> putStrLn "This option isn't ready yet."
      _            -> (pacman $ pacOpts ++ input) >> return ()

-- Crappy temp version.
-- Do this with regexes!
getHelpMsg :: [String] -> String
getHelpMsg pacmanHelpMsg = replacedLines ++ "\n" ++ auraUsageMsg
    where replacedLines = unlines . map replaceWord $ pacmanHelpMsg
          replaceWord   = unwords . map replace . words
          replace "pacman"      = "aura"
          replace "operations:" = "Inherited Pacman Operations:"
          replace otherWord     = otherWord

animateVersionMsg :: [String] -> IO ()
animateVersionMsg verMsg = do
  mapM_ putStrLn . map (padString lineHeaderLength) $ verMsg
  putStr $ raiseCursorBy 7
  mapM_ putStrLn $ renderPill 17
  putStr $ raiseCursorBy 4
  mapM_ putStrLn $ renderPill 12
  putStr $ raiseCursorBy 4
  mapM_ putStrLn $ renderPill 7
  putStr $ raiseCursorBy 4
  repeatShit 5
  --mapM_ putStrLn $ renderPacmanHead 0 Open
  --putStr $ raiseCursorBy 4
  --putStrLn "HEY"
  --repeatShit 10
  -- putStr clearGrid
  putStr "\n\n\n\n\n\n\n"  -- This goes last.

-- THIS HOLDS ALL THE ANSWERS
repeatShit :: Int -> IO ()
repeatShit 0 = return ()
repeatShit n = do
  mapM_ putStrLn $ renderPacmanHead 0 Open
  putStr $ raiseCursorBy 4
  hFlush stdout
  threadDelay 250000
  mapM_ putStrLn $ renderPacmanHead 0 Closed
  putStr $ raiseCursorBy 4
  hFlush stdout
  threadDelay 250000
  repeatShit (n - 1)

raiseCursorBy :: Int -> String
raiseCursorBy 0 = ""
raiseCursorBy n = "\r\b\r" ++ raiseCursorBy (n - 1)

clearGrid :: String
clearGrid = blankLines ++ raiseCursorBy 4
    where blankLines = concat . replicate 4 . padString 23 $ "\n"
