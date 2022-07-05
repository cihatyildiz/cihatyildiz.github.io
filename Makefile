
build:
	hugo -d ./docs

local:
	hugo server

package:
	docker build .
