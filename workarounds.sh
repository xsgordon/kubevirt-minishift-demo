# Workaround for https://github.com/kubevirt/containerized-data-importer/issues/452
sudo setfacl -m user:107:rwx /var/lib/minishift/base/openshift.local.pv/pv*
