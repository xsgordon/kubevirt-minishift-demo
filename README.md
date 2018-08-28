kubevirt-minishift-demo
=======================

Overview
--------

This repository contains helper scripts and YAML files to facilitate performing a simple demonstration of the [KubeVirt](http://kubevirt.io/) project and related components including the [Containerized Data Importer](http://github.com/kubevirt/containerized-data-importer).

The demonstration environment is created using Minishift and is as a result appropriate for running on a single laptop.

Pre-requisites
--------------

Currently before running the demonstration script it is necessary to download and install:

1. `minishift`
2. `kubectl`
3. `virtctl`

KubeVirt and the Containerized Data Importer will be installed by the demo scripts.

Usage
-----

Execute `demo.sh` to create the base minishift environment:

   $ ./demo.sh

This creates a new minishift environment and deploys KubeVirt as well as the Containerized Data Importer.

As pulling the images and starting them takes some time, particularly on conference wifi, this is typically a step to perform before the demonstration so that time is focused instead on what the resultant setup can actually do.

Basic KubeVirt Demo Flow
------------------------

Once the environment is operational, it is ready for demonstration. A typical basic flow looks something like this:

1. Examine the `kube-system` namespace illustrating the presence of the KubeVirt components.
2. Use `kubectl create -f cirros-vm.yaml` to create a basic Cirros virtual machine based on a `RegistryDisk`.
3. Use `kubectl get vms` to illustrate `kubectl` can see the vm object.
4. Use `kubectl edit vm cirros-vm` or `virtctl start cirros-vm` to create the `VirtualMachineInstance`.
5. Use `kubectl get vmis` to illustrate the presence of the VM instance.
6. Use `kubectl describe vmi cirros-vm` to see the scheduling state of the virtual machine instance.
7. Use `virtctl console cirros-vm` to access the console of the virtual machine instance.

Basic KubeVirt + Containerized Data Importer Demo Flow
------------------------------------------------------

The Containerized Data Importer allows us to demonstrate spawning a virtual machine that uses a `PersistentVolume` instead of a `RegistryDisk`.

1. Use `kubectl create -f cirros-pvc.yaml` to create the Cirros `PersistentVolume`.
2. Use `watch -n 2 kubectl logs <pod>` to illustrate the state of the import process.
3. Use `kubectl create -f cirros-pvc-vm.yaml` to create a basic Cirros virtual machine based on a `PersistentVolume`.
4. Use `kubectl create -f cirros-clone-pvc.yaml` to demonstrate cloning a volume.