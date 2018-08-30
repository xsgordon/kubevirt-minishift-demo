export MINISHIFT_ENABLE_EXPERIMENTAL=y
export KUBEVIRT_VERSION=v0.6.4
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
          --openshift-version v3.10.0

# Sorry Dan...
${MINISHIFT} ssh "sudo setenforce 0"

${OC} login -u system:admin

echo "INFO: Configuring system policy..."
${OC} adm policy add-scc-to-user privileged system:serviceaccount:kube-system:kubevirt-privileged
${OC} adm policy add-scc-to-user privileged system:serviceaccount:kube-system:kubevirt-controller
${OC} adm policy add-scc-to-user privileged system:serviceaccount:kube-system:kubevirt-infra

echo "INFO: Deploying KubeVirt..."
${OC} apply -f https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/kubevirt.yaml

echo "INFO: Deploying Containerized Data Importer..."
${OC} apply -f https://github.com/kubevirt/containerized-data-importer/releases/download/${CDI_VERSION}/cdi-controller.yaml
