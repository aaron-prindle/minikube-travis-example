# curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube
# curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x kubectl

export MINIKUBE_WANTUPDATENOTIFICATION=false
export MINIKUBE_WANTREPORTERRORPROMPT=false
export MINIKUBE_HOME=$HOME
export CHANGE_MINIKUBE_NONE_USER=true
mkdir $HOME/.kube || true
touch $HOME/.kube/config

export KUBECONFIG=$HOME/.kube/config
sudo -E ./minikube start --vm-driver=none --extra-config=apiserver.InsecureServingOptions.BindAddress="127.0.0.1" --extra-config=apiserver.InsecureServingOptions.BindPort="8080"

# this for loop waits until kubectl can access the api server that minikube has created
KUBECTL_UP="false"
for i in {1..150} # timeout for 5 minutes
do
   ./kubectl get po &> /dev/null
   if [ $? -ne 1 ]; then
      KUBECTL_UP="true"
      break
  fi
  sleep 2
done
if [ "$KUBECTL_UP" != "true" ]; then
  echo "TEST FAILURE: kubectl could not reach api-server in allotted time"
  exit 1
fi
# kubectl commands are now able to interact with minikube cluster

# OPTIONAL depending on kube-dns requirement
# this for loop waits until the kubernetes addons are active
KUBE_ADDONS_UP="false"
for i in {1..150} # timeout for 5 minutes
do
     if [[ $(./kubectl get po -n kube-system | tail -n +2 | awk '{print $1}' | grep "kube-addon-manager") ]]; then
       if [[ ! $(./kubectl get po -n kube-system | tail -n +2 | awk '{print $2}' | grep -wEv '^([1-9]+)\/\1$') ]]; then
         echo "TEST SUCCESS: all kubernetes addons pods are up and running"
         KUBE_ADDONS_UP="true"
         break
     fi
   fi
  sleep 2
done
if [ "$KUBE_ADDONS_UP" != "true" ]; then
  echo "TEST FAILURE: kubernetes addons did not come up in allotted time"
  exit 1
fi
# kube-addons is available for cluster services