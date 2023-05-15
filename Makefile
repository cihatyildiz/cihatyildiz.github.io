DATE=$(date "+%Y-%m-%d %H:%M")
COMMIT_MESSAGE=""

build:
	hugo -d ./docs

local:
	hugo server

package:
	docker build . 

publish:
	hugo -d ./docs
	git pull
	git push

