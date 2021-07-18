standard_config()

project "custom_simulate_entry"
    location "../build/custom_simulate_entry"
    targetname "tm_custom_simulate_entry"
    kind "SharedLib"
    language "C++"
    files {"*.inl", "*.h", "*.c"}
    sysincludedirs { "" }
