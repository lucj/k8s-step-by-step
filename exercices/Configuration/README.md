## Exercice

1. Dans un fichier *secret-db.yaml*, ajoutez la spédcification d'un Secret contenant la clé *password* dont la valeur associée est *dbpass*

2. Modifiez le Deployment *db* de façon à référencer la clé de ce Secret (au lieu de spécifier le mot de passe en clair)

3. Ajoutez la variable d'environnement POSTGRES_PASSWORD dans les containers des Deployment *worker* et *result* et faites en sorte que la valeur référence la clé du Secret créé précédememnt

4. Lancez l'application définie dans cette spécification et vérifiez que vous avez accès aux interfaces de vote et de result.

5. Supprimez l'application

<details>
  <summary markdown="span">Solution</summary>

1. Le mot de passe que nous souhaitons stocké dans le Secret est *dbpass*.

Premièrement, nous encodons ce mot de passe en base64:

```
$ echo "dbpass" | base64
ZGJwYXNzCg==
```

Ensuite, nous crééons le fichier *secret-db.yaml* dont le contenu est le suivant:

```
apiVersion: v1
kind: Secret
metadata:
  name: db
data:
  password: ZGJwYXNzCg==
```

2. Nous modifions la spécification du Deployment *db* façon à référencer le contenu de la clé *password* du Secret au lieu de mettre le mot de passe directement en clair:

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
          ports:
            - containerPort: 5432
              name: postgres
```

3. Nous modifions les Deployment *worker* et *result* (les 2 microservices qui se connectent à *db*) de façon à leur donner le mot de base via le Secret.

La nouvelle spécification du Deployment *worker*:

deploy-worker.yaml:
```
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: worker
  name: worker
spec:
  replicas: 1
  selector:
    matchLabels:
      app: worker
  template:
    metadata:
      labels:
        app: worker
    spec:
      containers:
        - image: registry.gitlab.com/voting-application/worker:go
          name: worker
          env:
          - name: POSTGRES_PASSWORD
            valueFrom:
              secretKeyRef:
                name: db
                key: password
```

La nouvelle spécification du Deployment *result*:

deploy-result.yaml:
```
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: result
  name: result
spec:
  replicas: 1
  selector:
    matchLabels:
      app: result
  template:
    metadata:
      labels:
        app: result
    spec:
      containers:
        - image: registry.gitlab.com/voting-application/result:latest
          name: result
          env:
            - name: POSTGRES_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: db
                  key: password
```

4. Nous lançons l'application avec la commande suivante depuis le répertoire *manifests*:

```
kubectl apply -f .
```

Comme précédement, en utilisant l'adresse IP d'un des nodes du cluster, nous pourrions accéder aux interfaces de vote et de result via les ports *31000* et *31001* respectivement.

5. Nous supprimons l'application avec la commande suivante depuis le répertoire *manifests*:

```
kubectl delete -f .
```

</details>