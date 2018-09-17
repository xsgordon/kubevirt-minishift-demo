export MINISHIFT_ENABLE_EXPERIMENTAL=y
#export KUBEVIRT_VERSION=v0.6.4
export KUBEVIRT_VERSION=v0.8.0
export CDI_VERSION=v1.1.1

MINISHIFT=`which minishift`
if [ "$?" -ne "0" ]; then
    echo "ERROR: Unable to locate minishift binary in path."
    exit -1
fi

KUBECTL=`which kubectl`
if [ "$?" -ne "0" ]; then
    echo "ERROR: Unable to locate kubectl binary in path."
    exit -1
fi

VIRTCTL=`which virtctl`
if [ "$?" -ne "0" ]; then
    echo "ERROR: Unable to locate virtctl binary in path."
    exit -1
fi

OC=`which oc`
if [ "$?" -ne "0" ]; then
    echo "ERROR: Unable to locate oc binary in path."
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
          --openshift-version v3.10.0 \

${OC} login -u system:admin
${OC} new-project kubevirt-demo

echo "INFO: Configuring system policy..."
${OC} adm policy add-scc-to-user privileged system:serviceaccount:kube-system:kubevirt-privileged
${OC} adm policy add-scc-to-user privileged system:serviceaccount:kube-system:kubevirt-controller
${OC} adm policy add-scc-to-user privileged system:serviceaccount:kube-system:kubevirt-apiserver
${OC} adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:kweb-ui:default 

echo "INFO: Applying workarounds, if any defined."
${MINISHIFT} hostfolder remove DEMO_SCRIPT
${MINISHIFT} hostfolder add DEMO_SCRIPT \
                            --instance-only \
                            --source `pwd` \
                            --target /home/docker/kubevirt-minishift-demo
${MINISHIFT} hostfolder mount DEMO_SCRIPT
${MINISHIFT} ssh "kubevirt-minishift-demo/workarounds.sh"

echo "INFO: Deploying KubeVirt..."
${OC} apply -f https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/kubevirt.yaml

echo "INFO: Deploying Containerized Data Importer..."
${OC} apply -f https://github.com/kubevirt/containerized-data-importer/releases/download/${CDI_VERSION}/cdi-controller.yaml

# Let's pull some images we know we will need later, focus is ones the manifests wont have pulled in..
${MINISHIFT} ssh "docker pull kubevirt/virt-launcher:${KUBEVIRT_VERSION}"
${MINISHIFT} ssh "docker pull kubevirt/cirros-registry-disk-demo:latest"
${MINISHIFT} ssh "docker pull kubevirt/fedora-cloud-registry-disk-demo:latest"

echo "INFO: Deploying kubevirt-web-ui..."
${OC} new-project kweb-ui
${OC} apply -f kubevirt-web-ui.yaml
${OC} project kubevirt-demo
${OC} get route -n kweb-ui -o custom-columns="KUBEVIRT UI URL":.spec.host