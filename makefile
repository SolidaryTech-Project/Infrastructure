#Install Local Dependencies
install-local:
#Pre-commit - Inframap - Graphviz (to generate the diagrams)
	sudo apt update
	sudo apt upgrade -y
	sudo apt install -y pre-commit
	sudo apt install -y graphviz
	go install github.com/cycloidio/inframap@v0.8.0
#If is your first time using pre-commit, you need to run the command below to install the hooks
	pre-commit install
#Install terraform-docs (to generate the documentation)
	curl -sSLo terraform-docs.tar.gz https://terraform-docs.io/dl/v0.18.0/terraform-docs-v0.18.0-$(uname)-amd64.tar.gz
	tar -xzf terraform-docs.tar.gz terraform-docs
	sudo mv terraform-docs /usr/local/bin/
#Install terraform-docs (to generate the documentation)
	curl -sSLo terraform-docs.tar.gz https://terraform-docs.io/dl/v0.18.0/terraform-docs-v0.18.0-linux-amd64.tar.gz
	tar -xzf terraform-docs.tar.gz terraform-docs
	chmod +x terraform-docs
	sudo mv terraform-docs /usr/local/bin/
	terraform-docs --version
