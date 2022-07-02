
build:
	hugo -d ./docs

run-local:
	hugo server

package:
	docker build .
