module Oracles.Setting (
    configFile, Setting (..), SettingList (..), setting, settingList, getSetting,
    getSettingList,  anyTargetPlatform, anyTargetOs, anyTargetArch, anyHostOs,
    ghcWithInterpreter, ghcEnableTablesNextToCode, useLibFFIForAdjustors,
    ghcCanonVersion, cmdLineLengthLimit, iosHost, osxHost, windowsHost,
    hostSupportsRPaths, topDirectory, libsuf
    ) where

import Hadrian.Expression
import Hadrian.Oracles.TextFile
import Hadrian.Oracles.Path

import Base

-- | Each 'Setting' comes from the file @hadrian/cfg/system.config@, generated
-- by the @configure@ script from the input file @hadrian/cfg/system.config.in@.
-- For example, the line
--
-- > target-os = mingw32
--
-- sets the value of the setting 'TargetOs'. The action 'setting' 'TargetOs'
-- looks up the value of the setting and returns the string @"mingw32"@,
-- tracking the result in the Shake database.
data Setting = BuildArch
             | BuildOs
             | BuildPlatform
             | BuildVendor
             | CcClangBackend
             | CcLlvmBackend
             | CursesLibDir
             | DynamicExtension
             | FfiIncludeDir
             | FfiLibDir
             | GhcMajorVersion
             | GhcMinorVersion
             | GhcPatchLevel
             | GhcVersion
             | GhcSourcePath
             | GmpIncludeDir
             | GmpLibDir
             | HostArch
             | HostOs
             | HostPlatform
             | HostVendor
             | IconvIncludeDir
             | IconvLibDir
             | LlvmTarget
             | ProjectGitCommitId
             | ProjectName
             | ProjectVersion
             | ProjectVersionInt
             | ProjectPatchLevel
             | ProjectPatchLevel1
             | ProjectPatchLevel2
             | SystemGhc
             | TargetArch
             | TargetOs
             | TargetPlatform
             | TargetPlatformFull
             | TargetVendor

-- TODO: Reduce the variety of similar flags (e.g. CPP and non-CPP versions).
-- | Each 'SettingList' comes from the file @hadrian/cfg/system.config@,
-- generated by the @configure@ script from the input file
-- @hadrian/cfg/system.config.in@. For example, the line
--
-- > hs-cpp-args = -E -undef -traditional
--
-- sets the value of 'HsCppArgs'. The action 'settingList' 'HsCppArgs' looks up
-- the value of the setting and returns the list of strings
-- @["-E", "-undef", "-traditional"]@, tracking the result in the Shake database.
data SettingList = ConfCcArgs Stage
                 | ConfCppArgs Stage
                 | ConfGccLinkerArgs Stage
                 | ConfLdLinkerArgs Stage
                 | HsCppArgs

-- | Look up the value of a 'Setting' in @cfg/system.config@, tracking the
-- result.
setting :: Setting -> Action String
setting key = lookupValueOrError configFile $ case key of
    BuildArch          -> "build-arch"
    BuildOs            -> "build-os"
    BuildPlatform      -> "build-platform"
    BuildVendor        -> "build-vendor"
    CcClangBackend     -> "cc-clang-backend"
    CcLlvmBackend      -> "cc-llvm-backend"
    CursesLibDir       -> "curses-lib-dir"
    DynamicExtension   -> "dynamic-extension"
    FfiIncludeDir      -> "ffi-include-dir"
    FfiLibDir          -> "ffi-lib-dir"
    GhcMajorVersion    -> "ghc-major-version"
    GhcMinorVersion    -> "ghc-minor-version"
    GhcPatchLevel      -> "ghc-patch-level"
    GhcVersion         -> "ghc-version"
    GhcSourcePath      -> "ghc-source-path"
    GmpIncludeDir      -> "gmp-include-dir"
    GmpLibDir          -> "gmp-lib-dir"
    HostArch           -> "host-arch"
    HostOs             -> "host-os"
    HostPlatform       -> "host-platform"
    HostVendor         -> "host-vendor"
    IconvIncludeDir    -> "iconv-include-dir"
    IconvLibDir        -> "iconv-lib-dir"
    LlvmTarget         -> "llvm-target"
    ProjectGitCommitId -> "project-git-commit-id"
    ProjectName        -> "project-name"
    ProjectVersion     -> "project-version"
    ProjectVersionInt  -> "project-version-int"
    ProjectPatchLevel  -> "project-patch-level"
    ProjectPatchLevel1 -> "project-patch-level1"
    ProjectPatchLevel2 -> "project-patch-level2"
    SystemGhc          -> "system-ghc"
    TargetArch         -> "target-arch"
    TargetOs           -> "target-os"
    TargetPlatform     -> "target-platform"
    TargetPlatformFull -> "target-platform-full"
    TargetVendor       -> "target-vendor"

-- | Look up the value of a 'SettingList' in @cfg/system.config@, tracking the
-- result.
settingList :: SettingList -> Action [String]
settingList key = fmap words $ lookupValueOrError configFile $ case key of
    ConfCcArgs        stage -> "conf-cc-args-"         ++ stageString stage
    ConfCppArgs       stage -> "conf-cpp-args-"        ++ stageString stage
    ConfGccLinkerArgs stage -> "conf-gcc-linker-args-" ++ stageString stage
    ConfLdLinkerArgs  stage -> "conf-ld-linker-args-"  ++ stageString stage
    HsCppArgs               -> "hs-cpp-args"

-- | An expression that looks up the value of a 'Setting' in @cfg/system.config@,
-- tracking the result.
getSetting :: Setting -> Expr c b String
getSetting = expr . setting

-- | An expression that looks up the value of a 'SettingList' in
-- @cfg/system.config@, tracking the result.
getSettingList :: SettingList -> Args c b
getSettingList = expr . settingList

-- | Check whether the value of a 'Setting' matches one of the given strings.
matchSetting :: Setting -> [String] -> Action Bool
matchSetting key values = (`elem` values) <$> setting key

-- | Check whether the target platform setting matches one of the given strings.
anyTargetPlatform :: [String] -> Action Bool
anyTargetPlatform = matchSetting TargetPlatformFull

-- | Check whether the target OS setting matches one of the given strings.
anyTargetOs :: [String] -> Action Bool
anyTargetOs = matchSetting TargetOs

-- | Check whether the target architecture setting matches one of the given
-- strings.
anyTargetArch :: [String] -> Action Bool
anyTargetArch = matchSetting TargetArch

-- | Check whether the host OS setting matches one of the given strings.
anyHostOs :: [String] -> Action Bool
anyHostOs = matchSetting HostOs

-- | Check whether the host OS setting is set to @"ios"@.
iosHost :: Action Bool
iosHost = anyHostOs ["ios"]

-- | Check whether the host OS setting is set to @"darwin"@.
osxHost :: Action Bool
osxHost = anyHostOs ["darwin"]

-- | Check whether the host OS supports the @-rpath@ linker option when
-- using dynamic linking.
--
-- TODO: Windows supports lazy binding (but GHC doesn't currently support
--       dynamic way on Windows anyways).
hostSupportsRPaths :: Action Bool
hostSupportsRPaths = anyHostOs ["linux", "darwin", "freebsd"]

-- | Check whether the host OS setting is set to @"mingw32"@ or @"cygwin32"@.
windowsHost :: Action Bool
windowsHost = anyHostOs ["mingw32", "cygwin32"]

-- | Check whether the target supports GHCi.
ghcWithInterpreter :: Action Bool
ghcWithInterpreter = do
    goodOs <- anyTargetOs [ "mingw32", "cygwin32", "linux", "solaris2"
                          , "freebsd", "dragonfly", "netbsd", "openbsd"
                          , "darwin", "kfreebsdgnu" ]
    goodArch <- anyTargetArch [ "i386", "x86_64", "powerpc", "sparc"
                              , "sparc64", "arm" ]
    return $ goodOs && goodArch

-- | Check whether the target architecture supports placing info tables next to
-- code. See: https://ghc.haskell.org/trac/ghc/wiki/Commentary/Rts/Storage/HeapObjects#TABLES_NEXT_TO_CODE.
ghcEnableTablesNextToCode :: Action Bool
ghcEnableTablesNextToCode = notM $ anyTargetArch ["ia64", "powerpc64", "powerpc64le"]

-- | Check to use @libffi@ for adjustors.
useLibFFIForAdjustors :: Action Bool
useLibFFIForAdjustors = notM $ anyTargetArch ["i386", "x86_64"]

-- | Canonicalised GHC version number, used for integer version comparisons. We
-- expand 'GhcMinorVersion' to two digits by adding a leading zero if necessary.
ghcCanonVersion :: Action String
ghcCanonVersion = do
    ghcMajorVersion <- setting GhcMajorVersion
    ghcMinorVersion <- setting GhcMinorVersion
    let leadingZero = [ '0' | length ghcMinorVersion == 1 ]
    return $ ghcMajorVersion ++ leadingZero ++ ghcMinorVersion

-- | Path to the GHC source tree.
topDirectory :: Action FilePath
topDirectory = fixAbsolutePathOnWindows =<< setting GhcSourcePath

-- | The file suffix used for libraries of a given build 'Way'. For example,
-- @_p.a@ corresponds to a static profiled library, and @-ghc7.11.20141222.so@
-- is a dynamic vanilly library. Why do we need GHC version number in the
-- dynamic suffix? Here is a possible reason: dynamic libraries are placed in a
-- single giant directory in the load path of the dynamic linker, and hence we
-- must distinguish different versions of GHC. In contrast, static libraries
-- live in their own per-package directory and hence do not need a unique
-- filename. We also need to respect the system's dynamic extension, e.g. @.dll@
-- or @.so@.
libsuf :: Way -> Action String
libsuf way
    | not (wayUnit Dynamic way) = return (waySuffix way ++ ".a") -- e.g., _p.a
    | otherwise = do
        extension <- setting DynamicExtension -- e.g., .dll or .so
        version   <- setting ProjectVersion   -- e.g., 7.11.20141222
        let suffix = waySuffix (removeWayUnit Dynamic way)
        return (suffix ++ "-ghc" ++ version ++ extension)