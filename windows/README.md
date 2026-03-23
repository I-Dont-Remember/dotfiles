# Windows files

## $home/.wslconfig

The default before 3/2026 was:
```
mem=8GB, processors=8, swap=2GB
```

- WSL defaults to allowing all host CPUs, so 8 logical processors on Samsung galaxybook. check with `powershell.exe -Command "(Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors"`
- check current memory setting in wsl terminal with `sudo free -h --giga`.
- swap is "free", i don't see a reason not to have a decent size there?
- Memory i don't want to hog too much from rest of the system - i had 3-4 VSCode windows & multiple claude sessions going and was just over 3GB, so 8 is too many set aside for daily use.

> ⚠️ Possible tradeoffs on using `mirrored` instead of `nat` networking
>
> - **Docker networking gets more complex** — Docker creates bridge networks (docker0, custom
  networks) that can behave unexpectedly in mirrored mode. Specifically:
    - --network=host in Docker containers now means the actual host network, which is broader
  than before
>   - Docker's internal DNS resolver can occasionally conflict with dnsTunneling
> - **Windows Firewall now applies to WSL** — services you run in WSL may get blocked by Windows
  Firewall where they weren't before. You might need to add inbound rules for things like
  local dev servers. Setting firewall=false under [experimental] disables this if it becomes
  annoying.
