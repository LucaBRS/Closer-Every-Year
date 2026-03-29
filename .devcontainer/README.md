# What is a Dev Container?
A Dev Container is a feature of VSCode that lets you develop inside a Docker container instead of on your local machine. This means your editor, terminal, and extensions all run within the container environment, not on your host OS.
This is useful because it guarantees that everyone working on the project uses the exact same environment — same tools, same dependencies, same paths.

# What does devcontainer.json do?
It tells VSCode how to attach to the container:

dockerComposeFile → points to the existing docker-compose.yml so VSCode reuses it instead of creating a new container from scratch
service → specifies which service in the compose file to attach to (in this case bruin)
workspaceFolder → tells VSCode which folder inside the container to open as the workspace (/workspace, which is where the repo volumes are mounted)
extensions → automatically installs the Bruin VSCode extension inside the container, so it can find the Bruin binary and work correctly


# Why is this needed for Bruin?
The Bruin VSCode extension needs to communicate with the Bruin CLI binary, which lives inside the container. Without Dev Containers, the extension runs on your host machine and can't reach the binary, so it doesn't work.