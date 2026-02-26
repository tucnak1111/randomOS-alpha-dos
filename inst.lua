-- installer.lua
io.write("guest@randomOS:~$ ")
io.flush()
local command = io.read()
if command ~= "randomos install -nogui" then
    print("unknown command")
    return

else

local url = "https://raw.githubusercontent.com/tucnak1111/randomOS/main/main.lua"
local outputFile = "downloaded_sys.lua"

print("Fetching remote sysfile metadata...")

-- Fetch headers
local handle = io.popen("curl -sL -o /dev/null -w '%{size_download}' " .. url)
local size = handle:read("*a")
handle:close()

size = tonumber(size)

if not size then
    print("Could not determine file size. Aborting.")
    return
end

size = tonumber(size)
print("Remote file size: " .. size .. " bytes")
print("Do you want to download and execute it? (y/n)")

local answer = io.read()
if answer:lower() ~= "y" then
    print("Installation cancelled.")
    return
end

print("Downloading...")

-- Real download with progress bar
os.execute("curl -L --progress-bar -o " .. outputFile .. " " .. url)

print("\nDownload complete.")
print("Executing sysfile...\n")

local chunk, err = loadfile(outputFile)
if not chunk then
    print("Execution failed: " .. err)
    return
end
chunk()
end
