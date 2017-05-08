# Set your variables here
#
## START
executable= # Name of the executable to generate
main_file= # Name of the main file of this project
additional_files_and_dirs=Makefile requirements.txt # List the required files and directories here
deployment_host= # Name of the host to deploy to. Can be an IP address.
python_version=2 # Version of python to use.
## END

deps=curl sed sort cat xargs tar pwd chmod

all: checkdeps $(executable)

.virtualenv.tool.version:
	@echo "> Retrieving the version of the latest virtualenv from github..."
	@curl -Ss https://api.github.com/repos/pypa/virtualenv/git/refs/tags | sed '/"ref"/!d; s/^[^:]*://; s/[ ",]*//g; s_refs/tags/__' | sort -nr | sed '1!d' > .virtualenv.tool.version

virtualenv.tool/virtualenv.py: .virtualenv.tool.version
	@echo "> Getting latest virtualenv from github..."
	@cat .virtualenv.tool.version | xargs -I% curl -SsLo virtualenv.tgz https://github.com/pypa/virtualenv/archive/%.tar.gz
	@echo "> Extracting latest virtualenv to virtualenv.tool/..."
	@tar -xmzf virtualenv.tgz
	@rm virtualenv.tgz
	@cat .virtualenv.tool.version | xargs -I% mv virtualenv-% virtualenv.tool

virtual.env/bin/python: virtualenv.tool/virtualenv.py
	@echo "> Creating new virtualenv $@"
	@virtualenv.tool/virtualenv.py -p python$(python_version) virtual.env

vendored: virtual.env/bin/python requirements.txt
	@echo "> Vendoring project dependencies"
	@virtual.env/bin/pip install -r requirements.txt
	@virtual.env/bin/pip freeze > vendored

$(executable): $(main_file) virtual.env/bin/python vendored
	@echo "> Creating $@"
	@pwd | xargs -I% echo '#!%/virtual.env/bin/python' > $@
	@cat $< >> $@
	@chmod a+x $@

distribute: $(main_file) $(additional_files_and_dirs)
	@scp -r $^ $(strip $(deployment_host)):

deploy: distribute
	@ssh $(deployment_host) -- 'make'

run: deploy
	@echo "> Running $(executable) (one shot)"
	@ssh $(deployment_host) -- './$(executable)'

start: deploy
	@echo "> Starting $(executable) (long run)"
	@ssh $(deployment_host) -- 'pkill $(executable); >/dev/null 2>&1 </dev/null nohup ./$(executable) &'

clean:
	rm -rf *.pyc .virtualenv.tool.version virtualenv.tool virtual.env vendored $(executable)

checkdeps:
	@echo "Checking dependencies"
	@sh -e -c 'for dep in $(deps);do echo -n "> "; command -v $$dep || { echo "command '"'"'$$dep'"'"' not found. Please install it." && false; }; done'

.PHONY: checkdeps clean deploy distribute run start
