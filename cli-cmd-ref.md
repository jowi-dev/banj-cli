# Commands


**Base Command**: banj/rose/isla/v -- rose?

**Sub Command - Description**
- rebuild -- nixos-rebuild switch
- monitor -- monitoring related commands 
- display -- display related commands
- deploy -- remote deployment commands 
- sync -- for pushing a sync OS version to a system
- update -- for getting the latest version from git
- get file/send file -- pinging files between hosts
- destroy -- garbage collection
- project -- project CLI - likely needs to be its 
    own project

**Default Behaviour Expectations**
- Any command which needs a subcommand and does not
    receive one - print a help message
- helpful messages by default, and upfront
- example commands by default, and upfront
- do not extend the CLI with commands that do not 
    directly relate to the OS


**Brainstorm**
banj tune
banj listen
banj publish "message"
banj update
banj cleanup
banj project
banj send
