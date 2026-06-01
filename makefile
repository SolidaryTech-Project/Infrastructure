#Install Local Dependencies
install-local:
#Pre-commit - Inframap - Graphviz (to generate the diagrams)
	sudo apt update
	sudo apt upgrade -y
	sudo apt install -y pre-commit
	sudo apt install -y graphviz
	go install github.com/cycloidio/inframap@v0.8.0
#If is your first time using pre-commit, you need to run the command below to install the hooks
#pre-commit install
