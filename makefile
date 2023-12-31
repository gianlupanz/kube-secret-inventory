# The name of your script
SCRIPT_NAME = kube-secret-inventory.sh
PYTHON_NAME = converter.py

# The name of your script
SCRIPT_NAME = kube-secret-inventory.sh

# Define a rule to make the script executable
executable:
	@chmod +x $(SCRIPT_NAME)

# Define a rule to copy the script to /usr/local/bin
install:
	@sudo cp $(SCRIPT_NAME) /usr/local/bin/ksi
	@sudo cp $(PYTHON_NAME) /usr/local/bin/
	

# Define a rule to do both tasks in one step
setup:
	@$(MAKE) executable
	@$(MAKE) install
