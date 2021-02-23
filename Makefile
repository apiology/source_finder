.PHONY: spec feature

all: localtest

localtest:
	@bundle exec rake localtest

spec:
	@bundle exec rake spec

feature:
	@bundle exec rake feature

quality:
	@bundle exec rake quality

rubocop:
	@bundle exec rake rubocop

update_from_cookiecutter: ## Bring in changes from template project used to create this repo
	IN_COOKIECUTTER_PROJECT_UPGRADER=1 cookiecutter_project_upgrader || true
	git checkout cookiecutter-template && git push && (git checkout main; bundle exec overcommit --sign)
	git checkout main && bundle exec overcommit --sign && git pull && git checkout -b update-from-cookiecutter-$$(date +%Y-%m-%d-%H%M)
	git merge cookiecutter-template || true
	@echo
	@echo "Please resolve any merge conflicts below and push up a PR with:"
	@echo
	@echo '   gh pr create --title "Update from cookiecutter" --body "Automated PR to update from cookiecutter boilerplate"'
	@echo
	@echo
