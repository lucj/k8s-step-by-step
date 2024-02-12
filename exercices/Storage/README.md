## Exercice


Le cluster k3s que vous utilisez pour ce cours contient une *StorageClass* permettant de créer des *PersitentVolume* de manière dynamique lorsqu'un *PersistentVolumeClaim* est créé.

```
$ kubectl get sc
NAME                   PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
local-path (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  3m22s
```

1. Dans un fichier *pvc-redis.yaml*, définissez la spécification d'une ressource *PersistentVolumeClaim* dont les caractéristiques sont les suivantes:

- nom: redis
- mode ReadWriteOnce
- demande de stockage de 100M

Puis, dans la spécification du Deployment *redis*, définissez un volume basé sur ce *PersistentVolumeClaim* précédent et, à l'aide de l'instruction *volumeMounts*, faite en sorte que le *PersistentVolume* qui sera associé soit monté dans le répertoire */data* du container redis. 

2. Dans un fichier *pvc-db.yaml* contenant la spécification d'une ressource *PersistentVolumeClaim* avec les caractéristiques suivantes:
- nom: db
- mode ReadWriteOnce
- demande de stockage de 500M

Puis, dans la spécification du Deployment *db*, définissez un volume basé sur le *PersistentVolumeClaim* précédent et, à l'aide de l'instruction *volumeMounts*, faite en sorte que le *PersistentVolume* qui sera associé soit monté dans le répertoire */var/lib/postgresql/data* du container postgres. 

3. Lancez l'application définie dans cette spécification et vérifiez qu'elle fonctionne correctement

4. Listez les ressources de types *PersistentVolumeClaim*, qu'observez-vous ?

5. Supprimez l'application

<details>
  <summary markdown="span">Solution</summary>

1. La spécification permettant de définir le *PersistentVolumeClaim* nommé *redis*:

pvc-redis.yaml:
```
apiVersion: v1
kind: PersistentVolumeClaim
metadata: 
  name: redis
spec: 
  accessModes:
    - ReadWriteOnce
  resources:
    requests: 
      storage: 100Mi
```

Le Deployment *redis* est modifié de la façon suivante:

deploy-redis.yaml:
```
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: redis
  name: redis
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
        - image: redis:7.0.8-alpine3.17
          name: redis
          volumeMounts:
          - name: data
            mountPath: /data
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: redis

```

2. La spécification permettant de définir le *PersistentVolumeClaim* nommé *db*:

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata: 
  name: db
spec: 
  accessModes:
    - ReadWriteOnce
  resources:
    requests: 
      storage: 100Mi
```

Le Deployment *db* est modifié de la façon suivante:

deploy-db.yaml:
```
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: db
  name: db
spec:
  replicas: 1
  selector:
    matchLabels:
      app: db
  template:
    metadata:
      labels:
        app: db
    spec:
      containers:
        - image: postgres:15.1-alpine3.17
          name: postgres
          env:
            - name: POSTGRES_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: db
                  key: password
          volumeMounts:
          - name: data
            mountPath: /var/lib/postgresql/data
          ports:
            - containerPort: 5432
              name: postgres
      volumes:
      - name: data
        persistentVolumeClaim: 
          claimName: db
```

3. Nous lançons l'application avec la commande suivante depuis le répertoire *manifests*:

```
kubectl apply -f .
```

Comme précédement, en utilisant l'adresse IP d'un des nodes du cluster, nous pourrions accéder aux interfaces de vote et de result via les ports *31000* et *31001* respectivement.

4. Nous pouvons lister les *PersistentVolumeClaim* et observer qu'un *PersistentVolume* a été créée pour chacun des 2 *PVC*

Liste des *PersistentVolumeClaims*:
```
$ kubectl get pvc
NAME                          STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/redis   Bound    pvc-789e3c5c-4402-4b96-b09d-ee441e8ade1d   100Mi      RWO            local-path     39s
persistentvolumeclaim/db      Bound    pvc-75b9a32c-eab5-4452-a9b8-12d41dd74e7a   100Mi      RWO            local-path     39s
```

Liste des *PersistentVolumes*:
```
$ kubectl get pv
NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM           STORAGECLASS   REASON   AGE
persistentvolume/pvc-789e3c5c-4402-4b96-b09d-ee441e8ade1d   100Mi      RWO            Delete           Bound    default/redis   local-path              32s
persistentvolume/pvc-75b9a32c-eab5-4452-a9b8-12d41dd74e7a   100Mi      RWO            Delete           Bound    default/db      local-path              32s
```

5. Nous supprimons l'application avec la commande suivante depuis le répertoire *manifests*:

```
kubectl delete -f .
```
