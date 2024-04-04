[k3s](https://k3s.io) est une distribution Kubernetes très légère, vous allez l'utiliser pour mettre en place un cluster de test.

1. Lancez une machine virtuelle sur votre environnement

Vous pouvez installer [Multipass](https://multipass.run), un outils très pratique pour la mise en place de VMs en local. Multipass est disponible sur Windows, Linux et MacOS.

Lancez ensuite une VM nommé k3s avec la commande suivante:

```
multipass launch -n k3s -c 4 -d 20G -m 4G
```

Note: les exemples se baseront sur l'utilisation de Multipass mais vous pouvez utiliser l'outils de virtualisation que vous avez l'habitude d'utiliser (*VirtualBox*, *kvm*, ...), dans ce cas il faudra simplement adapter certaines des commandes qui suivront.

2. Lancez un shell ssh dans cette VM et installez k3s

```
multipass shell k3s
```

L'installation de k3s peut se faire avec la commande suivante:

```
curl -sSL https://get.k3s.io | sh
```

3. Configuration de kubectl 

Configurez le client kubectl de façon à ce qu'il utilise le fichier kubeconfig créé par k3s:

```
mkdir -p $HOME/.kube
sudo mv -i /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

4. Listez les nodes de votre cluster

```
kubectl get no
```

Vous obtiendrez un résultat similaire à celui ci-dessous (votre version de k3s pourra cependant être différente):

```
NAME   STATUS   ROLES                  AGE   VERSION
k3s    Ready    control-plane,master   40s   v1.28.8+k3s1
```

Vous avez à présent accès à un cluster Kubernetes basé sur k3s, celui-ci est contitué d'un seul node.