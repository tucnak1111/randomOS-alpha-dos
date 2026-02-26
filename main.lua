function warn(msg)
    io.write("\27[33m") -- yellow
    print(msg)
    io.write("\27[0m") -- reset color
end

function sleep(n)
    os.execute("sleep " .. tonumber(n))
end

function progressBar(seconds)
    for i = 1, 20 do
        io.write("#")
        io.flush()
        os.execute("sleep " .. (seconds/20))
    end
    print(" 100%")
end
io.write("guest@randomOS:~$ ")
io.flush()
local command = io.read()
if command ~= "randomos run /os/utils/install.u.sh" then
    print("unknown command")
    return

else
print("Preparing for booting...")
progressBar(5)
print("> mounterx build /os/bin/ > /os/lib/")
sleep(3)
print("> cd /os/lib/ && ln -s mounterx mounter")
sleep(6)
print("Preparing the kernel...")
sleep(3)
print("> gh | i -nosilent -y -g --sudo --cache --x86_64 ./kernel.u")
progressBar(20)
print("GH: compiling kernel.u")
sleep(6)
print("GH: Do you want to use 780 MB of RAM for the kernel? (y/n)")
local answer = io.read()
if answer:lower() == "y" then
    print("GH: Using 780 MB of RAM for the kernel.")
else
    print("GH: Using default RAM allocation for the kernel.")
end
sleep(3)
print("GH: Compiling kernel.u with the specified RAM allocation...")
print("GH: downloading and installing dependencies...")
sleep(5)
print("[https://gh.org/dep/kernelmounterx@2.0.0-beta.321]215 MB / 215 MB")
progressBar(10)
print("[https://gh.org/dep/kernelmounterx-bin@1.3.5] 524 MB / 524 MB")
progressBar(20)
warn("GH: update available: mounterx-bin v1.3.5 -> v1.3.6. Update using gh | i -nosilent update & upgrade")
sleep(3)
print("finishing...")
sleep(5)
print("randomOS 0.1.0-alpha.1. All rights reserved. (c) 2024 randomOS Team")
print("Type 'help' for a list of commands.")
print("guest@randomOS:~$ ")
local command = io.read()
if command == "help" then
    print("Available commands:")
    print("- help: Show this help message")
    print("- exit: Exit the terminal")
    print("- clear: Clear the terminal")
    print("- date: Show the current date and time")
elseif command == "exit" then
    print("Exiting terminal...")
    os.exit()
end
end