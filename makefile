#Install Local Dependencies
pre-commit:
#Pre-commit - Inframap - Graphviz (to generate the diagrams)
	sudo apt update
	sudo apt upgrade -y
	sudo apt install -y pre-commit
	sudo apt install -y graphviz
	go install github.com/cycloidio/inframap@v0.8.0
#Move o inframap para o PATH global (go install joga em ~/go/bin, que costuma ficar fora do PATH)
	sudo cp "$$(go env GOPATH)/bin/inframap" /usr/local/bin/
	inframap version
#If is your first time using pre-commit, you need to run the command below to install the hooks
	pre-commit install
#Install terraform-docs (to generate the documentation)
	curl -sSLo terraform-docs.tar.gz https://terraform-docs.io/dl/v0.18.0/terraform-docs-v0.18.0-linux-amd64.tar.gz
	tar -xzf terraform-docs.tar.gz terraform-docs
	chmod +x terraform-docs
	sudo mv terraform-docs /usr/local/bin/
	terraform-docs --version
#Install tflint (linter)
	curl -sSLo tflint.zip https://github.com/terraform-linters/tflint/releases/latest/download/tflint_linux_amd64.zip
	unzip -o tflint.zip tflint
	chmod +x tflint
	sudo mv tflint /usr/local/bin/
	rm tflint.zip
	tflint --version
#Install trivy (security scanner)
	curl -sSfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin
	trivy --version
#Configure Terraform plugin cache (avoids re-downloading providers per module)
	mkdir -p ~/.terraform.d/plugin-cache
	grep -q "plugin_cache_dir" ~/.terraformrc 2>/dev/null || echo 'plugin_cache_dir = "~/.terraform.d/plugin-cache"' >> ~/.terraformrc
