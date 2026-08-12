#!/bin/bash

git submodule foreach 'git checkout main && git reset --hard $$(git rev-list --max-parents=0 HEAD) && git pull'
git add .
git commit -m "Update submodules to latest main" || echo "No changes to commit"
git pull
git push origin HEAD
