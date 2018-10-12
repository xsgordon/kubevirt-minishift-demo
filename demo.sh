export MINISHIFT_ENABLE_EXPERIMENTAL=y
export KUBEVIRT_VERSION=v0.9.0
export CDI_VERSION=v1.2.0

MINISHIFT=`which minishift`
if [ "$?" -ne "0" ]; then
    echo "ERROR: Unable to locate minishift binary in path."
    echo """HINT: Grab minishift at:
      https://docs.okd.io/latest/minishift/getting-started/installing.html"""
    exit -1
fi

KUBECTL=`which kubectl`
if [ "$?" -ne "0" ]; then
    echo "WARN: Unable to locate kubectl binary in path."
    echo """HINT: Grab kubectl at:
      https://kubernetes.io/docs/tasks/tools/install-kubectl/"""
fi

VIRTCTL=`which virtctl`
if [ "$?" -ne "0" ]; then
    echo "ERROR: Unable to locate virtctl binary in path."
    echo """HINT: Grab virtctl at:
      https://github.com/kubevirt/kubevirt/releases"""
    exit -1
fi

OC=`which oc`
if [ "$?" -ne "0" ]; then
    echo "ERROR: Unable to locate oc binary in path."
    echo """HINT: Grab oc at:
      https://www.okd.io/download.html"""
    exit -1
fi

echo "INFO: Cleaning up existing minishift instance (if present)..."
${MINISHIFT} stop
${MINISHIFT} delete

echo "INFO minishift..."
${MINISHIFT} start \
          --vm-driver=kvm \
          --memory 4GB \
          --iso-url "centos" \
          --openshift-version v3.11.0 \

${OC} login -u system:admin
${OC} new-project kubevirt-demo
${OC} new-project kubevirt-clone-demo

echo "INFO: Configuring system policy..."
${OC} adm policy add-scc-to-user privileged system:serviceaccount:kube-system:kubevirt-privileged
${OC} adm policy add-scc-to-user privileged system:serviceaccount:kube-system:kubevirt-controller
${OC} adm policy add-scc-to-user privileged system:serviceaccount:kube-system:kubevirt-apiserver
${OC} adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:kubevirt-web-ui:default
${OC} adm policy add-scc-to-user privileged system:serviceaccount:kube-system:cdi-sa

echo "INFO: Applying workarounds, if any defined."
${MINISHIFT} hostfolder remove DEMO_SCRIPT
${MINISHIFT} hostfolder add DEMO_SCRIPT \
                            --instance-only \
                            --source `pwd` \
                            --target /home/docker/kubevirt-minishift-demo
${MINISHIFT} hostfolder mount DEMO_SCRIPT
${MINISHIFT} ssh "kubevirt-minishift-demo/workarounds.sh"

echo "INFO: Enable DataVolume feature gate..."
${OC} apply -f enable-data-volume.yaml

echo "INFO: Deploying KubeVirt..."
${OC} apply -f https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/kubevirt.yaml

echo "INFO: Deploying Containerized Data Importer..."
${OC} apply -f https://github.com/kubevirt/containerized-data-importer/releases/download/${CDI_VERSION}/cdi-controller.yaml

echo "INFO: Creating backup project with PVCs pre-created"
${OC} new-project kubevirt-demo-backup
${OC} create -f ./examples/cirros/cirros-pvc.yaml
${OC} create -f ./examples/fedora/fedora-pvc.yaml

echo "INFO: Deploying kubevirt-web-ui..."
${OC} new-project kubevirt-web-ui
#${OC} apply -f https://raw.githubusercontent.com/kubevirt/web-ui/master/kubevirt/kubevirt-web-ui.yaml
${OC} apply -f kubevirt-web-ui.yaml
${OC} project kubevirt-demo
${OC} get route -n kubevirt-web-ui -o custom-columns="KUBEVIRT UI URL":.spec.host

# Let's pull some images we know we will need later, focus is ones the manifests wont have pulled in..
${MINISHIFT} ssh "docker pull kubevirt/virt-launcher:${KUBEVIRT_VERSION}"
${MINISHIFT} ssh "docker pull kubevirt/cirros-registry-disk-demo:latest"
${MINISHIFT} ssh "docker pull kubevirt/fedora-cloud-registry-disk-demo:latest"
