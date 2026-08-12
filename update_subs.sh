#!/bin/bash

mair_dae () {
    pushd submodule/$1
    git checkout main
    git pull
    popd
}

git submodule deinit -f --all
git submodule update --init

mair_dae adn_apb 
mair_dae adn_clk_rst 
mair_dae adn_common 
mair_dae adn_uart

git add .
git commit -m "Update submodules to latest main" || echo "No changes to commit"
git pull
git push origin HEAD

clear

git submodule

