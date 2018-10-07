kubevirt-minishift-demo
=======================

Overview
--------

This repository contains helper scripts and YAML files to facilitate performing
a simple demonstration of the [KubeVirt](http://kubevirt.io/) project and
related components including the [Containerized Data Importer][1].

The demonstration environment is created using Minishift and is as a result
appropriate for running on a single laptop.

Pre-requisites
--------------

Currently before running the demonstration script it is necessary to download
and install:

1. `minishift`
2. `kubectl`
3. `virtctl`

The host system must also be enabled for nested KVM. KubeVirt and the
Containerized Data Importer will be installed by the demo scripts.

Usage
-----

Execute `demo.sh` to create the base minishift environment:

   $ ./demo.sh

This creates a new minishift environment and deploys KubeVirt as well as the
Containerized Data Importer.

As pulling the images and starting them takes some time, particularly on
conference wifi, this is typically a step to perform before the demonstration
so that time is focused instead on what the resultant setup can actually do.

Once the system is ready, use the provided YAML files to (re)create the examples
in the `kubevirt-demo` namespace that will be selected when `demo.sh` ends. To
clean-up the examples you can use `clean.sh`. This will only remove newly
created entities generated from the YAML files in the current namespace. It will
not clean up the MiniShift instance or other KubeVirt entities like the CRDs.

Inventory
---------

The following examples use the Cirros disk image and are found in
`./examples/cirros/`:

* `cirros-vm.yaml` - Create a basic Cirros virtual machine using a
  `RegistryDisk`, pulls image from Docker Hub.
* `cirros-pvc.yaml` - Create a `PersistentVolume` containing a Cirros disk image
  using the Containerized Data Importer, `img` file pulled via HTTP.
* `cirros-pvc-vm.yaml` - Create a basic Cirros virtual machine using a
  `PersistentVolume`.
* `cirros-clone-pvc.yaml` - Create a clone of the `PersistentVolume` created by
  `cirros-pvc.yaml` using the Containerized Data Importer.
* `cirros-clone-vm.yaml` - Create a virtual machine based on the cloned
  `PersistentVolume` from `cirros-clone-pvc.yaml`.

The `fedora-*` examples in `./examples/fedora/` follow the same pattern as the
Cirros examples above. In both the Cirros and Fedora examples the resultant
virtual machine has basic networking provided by the `Pod` network. The Cirros
image uses the default username and password baked into it (`cirros` and
`gocubsgo`), the Fedora image uses the `shadowman` user with the `shadowman`
password.

Basic KubeVirt Demo Flow
------------------------

Once the environment is operational, it is ready for demonstration. A typical
basic flow looks something like this:

1. Examine the `kube-system` namespace illustrating the presence of the KubeVirt
   components.
2. Use `kubectl create -f examples/cirros/cirros-vm.yaml` to create a basic
   Cirros virtual machine based on a `RegistryDisk`.
3. Use `kubectl get vms` to illustrate `kubectl` can see the vm object.
4. Use `kubectl edit vm cirros-vm` or `virtctl start cirros-vm` to create the
   `VirtualMachineInstance`.
5. Use `kubectl get vmis` to illustrate the presence of the VM instance.
6. Use `kubectl describe vmi cirros-vm` to see the scheduling state of the
   virtual machine instance.
7. Use `virtctl console cirros-vm` to access the console of the virtual machine
   instance.

Basic KubeVirt + Containerized Data Importer Demo Flow
------------------------------------------------------

The Containerized Data Importer allows us to demonstrate spawning a virtual
machine that uses a `PersistentVolume` instead of a `RegistryDisk`.

1. Use `kubectl create -f examples/cirros/cirros-pvc.yaml` to create the Cirros
   `PersistentVolume`.
2. Use `watch -n 2 kubectl logs <pod>` to illustrate the state of the import
   process.
3. Use `kubectl create -f examples/cirroscirros-pvc-vm.yaml` to create a basic
   Cirros virtual machine based on a `PersistentVolume`.
4. Use `kubectl create -f examples/cirroscirros-clone-pvc.yaml` to demonstrate
   cloning a volume.
5. Use `kubectl create -f examples/cirros/cirros-clone-vm.yaml` to demonstrate
   spawning a virtual machine from the cloned volume.

[1]: http://github.com/kubevirt/containerized-data-importer
