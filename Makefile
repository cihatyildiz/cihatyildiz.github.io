
build:
	hugo -d ./docs

run-local:
	hugo server

package:
	docker-compose up -d
