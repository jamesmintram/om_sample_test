-- premake5.lua
-- version: premake-5.0.0-alpha14

-- %TM_SDK_DIR% should be set to the directory of The Machinery SDK
standard_config()

project "custom_tab"
    location "../build/custom_tab"
    targetname "tm_custom_tab"
    kind "SharedLib"
    language "C++"
    files {"*.inl", "*.h", "*.c"}
    sysincludedirs { "" }

    files { TM_SDK_DIR .. "/headers/**.h" }