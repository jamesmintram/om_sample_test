-- premake5.lua
-- version: premake-5.0.0-alpha14

-- %TM_SDK_DIR% should be set to the directory of The Machinery SDK

TM_SDK_DIR=os.getenv("TM_SDK_DIR")

if TM_SDK_DIR == nil then 
    print("ERROR: TM_SDK_DIR environment variable must be set")
    os.exit(-1)
end

if os.isfile( TM_SDK_DIR .. "/headers") == false then 
    print("Detected Dev version of TM SDK")
    TM_SDK_IS_DEV = true
end

-- Do we figure out if this is a Dev folder of Release folder
if TM_SDK_IS_DEV then 
    tm_header_paths={ TM_SDK_DIR }
    tm_header_files={ TM_SDK_DIR .. "/foundation/**.h", TM_SDK_DIR .. "/the_machinery/**.h", TM_SDK_DIR .. "/utils/**.h" }
else
    tm_header_paths=TM_SDK_DIR .. "/headers"
    tm_header_files={ TM_SDK_DIR .. "/**.h"}
end

function standard_config()
    
    newoption {
        trigger     = "clang",
        description = "Force use of CLANG for Windows builds"
    }

    filter "system:windows"
        platforms { "Win64" }
        systemversion("latest")

    filter {"system:linux"}
        platforms { "Linux" }

    filter { "system:windows", "options:clang" }
        toolset("msc-clangcl")
        buildoptions {
            "-Wno-missing-field-initializers",   -- = {0} is OK.
            "-Wno-unused-parameter",             -- Useful for documentation purposes.
            "-Wno-unused-local-typedef",         -- We don't always use all typedefs.
            "-Wno-missing-braces",               -- = {0} is OK.
            "-Wno-microsoft-anon-tag",           -- Allow anonymous structs.
        }
        buildoptions {
            "-fms-extensions",                   -- Allow anonymous struct as C inheritance.
            "-mavx",                             -- AVX.
            "-mfma",                             -- FMA.
        }
        removeflags {"FatalLinkWarnings"}        -- clang linker doesn't understand /WX

    filter "platforms:Win64"
        defines { "TM_OS_WINDOWS", "_CRT_SECURE_NO_WARNINGS" }
        includedirs(tm_header_paths)
        staticruntime "On"
        architecture "x64"
        prebuildcommands {
            "if not defined TM_SDK_DIR (echo ERROR: Environment variable TM_SDK_DIR must be set)"
        }
        libdirs { TM_SDK_DIR .. "/lib/" .. _ACTION .. "/%{cfg.buildcfg}"}
        disablewarnings {
            "4057", -- Slightly different base types. Converting from type with volatile to without.
            "4100", -- Unused formal parameter. I think unusued parameters are good for documentation.
            "4152", -- Conversion from function pointer to void *. Should be ok.
            "4200", -- Zero-sized array. Valid C99.
            "4201", -- Nameless struct/union. Valid C11.
            "4204", -- Non-constant aggregate initializer. Valid C99.
            "4206", -- Translation unit is empty. Might be #ifdefed out.
            "4214", -- Bool bit-fields. Valid C99.
            "4221", -- Pointers to locals in initializers. Valid C99.
            "4702", -- Unreachable code. We sometimes want return after exit() because otherwise we get an error about no return value.
        }
        linkoptions {"/ignore:4099"}

    filter {"platforms:Linux"}
        defines { "TM_OS_LINUX", "TM_OS_POSIX" }
        includedirs(tm_header_paths)
        architecture "x64"
        toolset "clang"
        buildoptions {
            "-fms-extensions",                   -- Allow anonymous struct as C inheritance.
            "-g",                                -- Debugging.
            "-mavx",                             -- AVX.
            "-mfma",                             -- FMA.
            "-fcommon",                          -- Allow tentative definitions
        }
        libdirs { TM_SDK_DIR .. "/lib/" .. _ACTION .. "/%{cfg.buildcfg}"}
        disablewarnings {
            "missing-field-initializers",   -- = {0} is OK.
            "unused-parameter",             -- Useful for documentation purposes.
            "unused-local-typedef",         -- We don't always use all typedefs.
            "missing-braces",               -- = {0} is OK.
            "microsoft-anon-tag",           -- Allow anonymous structs.
        }
        removeflags {"FatalWarnings"}

    filter "configurations:Debug"
        defines { "TM_CONFIGURATION_DEBUG", "DEBUG" }
        symbols "On"

    filter "configurations:Release"
        defines { "TM_CONFIGURATION_RELEASE" }
        optimize "On"

end

workspace "next_hex"
    configurations {"Debug", "Release"}
    language "C++"
    cppdialect "C++11"
    flags { "FatalWarnings", "MultiProcessorCompile" }
    warnings "Extra"
    inlining "Auto"
    sysincludedirs { "" }
    targetdir "build/bin/%{cfg.buildcfg}"

dofile("custom_tab/premake5.lua")
dofile("custom_sim/premake5.lua")