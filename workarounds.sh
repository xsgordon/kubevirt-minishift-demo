# Workaround for https://github.com/openshift/origin/pull/20351
sed "/kubeletArguments/ a\  feature-gates:" \
    /var/lib/minishift/openshift.local.config/node-localhost/node-config.yaml
sed "/feature-gates/ a\  - DevicePlugins: true" \
    /var/lib/minishift/openshift.local.config/node-localhost/node-config.yaml
KUBELET_ROOTFS=`echo $(docker inspect $(docker ps | grep kubelet | cut -d" " -f1) | grep MergedDir | cut -d":" -f2 | grep -E -o "/[a-zA-Z0-9\/]*")`
sudo mkdir -p /var/lib/kubelet/device-plugins $KUBELET_ROOTFS/var/lib/kubelet/device-plugins
sudo mount -o bind $KUBELET_ROOTFS/var/lib/kubelet/device-plugins /var/lib/kubelet/device-plugins
echo /var/lib/kubelet/device-plugins
ls /var/lib/kubelet/device-plugins
echo $KUBELET_ROOTFS/var/lib/kubelet/device-plugins
sudo ls $KUBELET_ROOTFS/var/lib/kubelet/device-plugins
