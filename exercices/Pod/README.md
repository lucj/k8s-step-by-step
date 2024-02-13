## Exercice

0. Prérequis - Création d'un répertoire de travail

Dans votre VM créez le répertoire *votingapp* dans votre home directory. C'est dans ce répertoire que vous allez créer les différents fichiers yaml qui seront nécessaire pour déployer l'application VotingApp.

1. Dans le répertoire *votingapp* créez les fichiers yaml contenant les spécifications des Pods de chaque microservice de l'application VotingApp en respectant les éléments du tableau suivant:

| Microservice | Nom du fichier     | Pod's name | Container's image                                       |
| ---          | ---                | ---        | ---                                                     |
| Vote UI      | pod-voteui.yaml    | vote-ui    | registry.gitlab.com/voting-application/vote-ui:latest   |
| Vote         | pod-vote.yaml      | vote       | registry.gitlab.com/voting-application/vote:latest      |
| Redis        | pod-redis.yaml     | redis      | redis:7.0.8-alpine3.17                                  |
| Worker       | pod-worker.yaml    | worker     | registry.gitlab.com/voting-application/worker:latest    |
| Postgres     | pod-db.yaml        | db         | postgres:15.1-alpine3.17                         |
| Result       | pod-result.yaml    | result     | registry.gitlab.com/voting-application/result:latest    |
| Result UI    | pod-resultui.yaml  | result-ui  | registry.gitlab.com/voting-application/result-ui:latest |

Pour le Pod *db* assurez vous de spécifier une variable d'environment *POSTGRES_PASSWORD* avec la valeur *postgres*

2. Lancez l'application définie par l'ensemble de ces spécifications

3. Que constatez-vous ?

4. Supprimez l'application

<details>
  <summary markdown="span">Solution</summary>

1. Les spécifications sont la suivante:

pod-voteui.yaml:
```
apiVersion: v1
kind: Pod
metadata:
  name: vote-ui
spec:
  containers:
    - image: registry.gitlab.com/voting-application/vote-ui:latest
      name: vote-ui
```

pod-vote.yaml
```
apiVersion: v1
kind: Pod
metadata:
  name: vote
spec:
  containers:
    - image: registry.gitlab.com/voting-application/vote:latest
      name: vote
```

pod-redis.yaml:
```
apiVersion: v1
kind: Pod
metadata:
  name: redis
spec:
  containers:
    - image: redis:7.0.8-alpine3.17
      name: redis
```

pod-worker.yaml:
```
apiVersion: v1
kind: Pod
metadata:
  name: worker
spec:
  containers:
    - image: registry.gitlab.com/voting-application/worker:go
      name: worker
      imagePullPolicy: Always
```

pod-db.yaml:
```
apiVersion: v1
kind: Pod
metadata:
  name: db
spec:
  containers:
  - image: postgres:15.1-alpine3.17
    name: postgres
    env:
      - name: POSTGRES_PASSWORD
        value: postgres
```

pod-result.yaml:
```
apiVersion: v1
kind: Pod
metadata:
  name: result
spec:
  containers:
    - image: registry.gitlab.com/voting-application/result:latest
      name: result
```

pod-resultui.yaml
```
apiVersion: v1
kind: Pod
metadata:
  name: result-ui
spec:
  containers:
    - image: registry.gitlab.com/voting-application/result-ui:latest
      name: result-ui
```

2. L'application peut-être lancée avec la commande suivante

```
kubectl apply -f votingapp
```

Note: lorsque vous précisez un répertoire tous les fichiers yaml de ce répertoire sont créés.

3. Que constatez-vous ?

Certains Pod ne sont pas en bonne état se santé:

```
$ kubectl get po
NAME        READY   STATUS             RESTARTS     AGE
db          1/1     Running            0            25s
redis       1/1     Running            0            25s
result      1/1     Running            0            25s
result-ui   0/1     CrashLoopBackOff   1 (4s ago)   24s
vote        1/1     Running            0            25s
vote-ui     0/1     CrashLoopBackOff   1 (3s ago)   25s
worker      1/1     Running            0            25s
```

Si nous prenons l'example du Pod *vote-ui*, ses logs indiquent qu'il ne peut pas se connecter à *vote*

```
$ kubectl logs vote-ui  
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2024/02/08 11:10:20 [emerg] 1#1: host not found in upstream "vote" in /etc/nginx/nginx.conf:44
nginx: [emerg] host not found in upstream "vote" in /etc/nginx/nginx.conf:44
```

De plus, les logs du Pod *worker* nous indiquent qu'il ne peut pas se connecter au Pod *Redis*:

```
$ kubectl logs worker
...
Waiting for Redis dial tcp: lookup redis on 10.96.0.10:53: no such host
```

Les Pods des différents microservices son créés mais ils ne peuvent pas communiquer les uns avec les autres car il faut pour cela créer des Services, c'est ce que nous allons ajouter dans la prochaine étape.

4. Nous supprimons l'application avec la commande suivante

```
kubectl delete -f votingapp
```

</details>