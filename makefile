# The name of your script
SCRIPT_NAME = kube-secret-inventory.sh

# Check the operating system
ifeq ($(OS),Windows_NT)
    # For Windows
    CHMOD :=
    CP := copy
    SUDO :=
else
    # For Linux and macOS
    CHMOD := chmod +x
    CP := cp
    SUDO := sudo
endif

# Define a rule to make the script executable
executable:
	$(CHMOD) $(SCRIPT_NAME)

# Define a rule to copy the script to /usr/local/bin
install:
	$(SUDO) $(CP) $(SCRIPT_NAME) /usr/local/bin/

# Define a rule to do both tasks in one step
setup:
	$(MAKE) executable
	$(MAKE) install
