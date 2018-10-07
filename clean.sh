#!/bin/sh

read -p "Are you sure you wish to execute clean-up? This will delete all entities created from kubevirt-minishift-demo YAML files in the currently selected namespace. (Y/n):" -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    for FILE in `find ./examples/ -maxdepth 2 -name *.yaml`; do
        kubectl delete -f ${FILE};
    done
fi

