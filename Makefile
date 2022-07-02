
COMMIT_MESSAGE="Commit $(date "+%Y-%m-%d %H:%M")"

commit:
	git add . 
	git commit -am $COMMIT_MESSAGE

build:
	hugo -d ./docs

run-local:
	hugo server

package:
	docker build .

publish:
