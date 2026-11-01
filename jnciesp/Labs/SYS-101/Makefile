.PHONY: build deploy inspect verify destroy clean validate

build:
	docker build --no-cache -t sys101-services:latest services

deploy: build
	sudo containerlab deploy -t topology.clab.yml

inspect:
	sudo containerlab inspect -t topology.clab.yml

verify:
	bash scripts/verify.sh

destroy:
	sudo containerlab destroy -t topology.clab.yml --cleanup

clean: destroy
	rm -f evidence/*.txt evidence/services/*.log

validate:
	bash scripts/validate-package.sh
