# Starter Kit Flutter

Ce projet va vous permettre de mettre en route un projet préconfiguré en quelques minutes.

Cet outil est rendu disponible à la suite de [l'article Medium "Architecture Clean et Modulaire avec Flutter : De la Structure aux Tests Gherkin"](https://medium.com/@benotfontaine/architecture-clean-et-modulaire-avec-flutter-de-la-structure-aux-tests-gherkin-879a37c0c2a5)

--------

## Créer un nouveau projet à partir du starter kit

Première chose à faire: un fork. Une fois celui-ci fait, vous pouvez le cloner.

### Organisation des Flavors
Pour organiser les flavors, il vous suffit de modifier le fichier `flavorizr.yaml`
```yaml
flavors:
  prod:
    app:
      name: "Production"
    android:
      applicationId: "fr.benoitfontaine.starter"
    ios:
      bundleId: "fr.benoitfontaine.starter"
    macos:
      bundleId: "fr.benoitfontaine.starter"
  preprod:
    app:
      name: "Preprod"
    android:
      applicationId: "fr.benoitfontaine.starter.preprod"
    ios:
      bundleId: "fr.benoitfontaine.starter.preprod"
    macos:
      bundleId: "fr.benoitfontaine.starter.preprod"
  recette:
    app:
      name: "Recette"
    android:
      applicationId: "fr.benoitfontaine.starter.recette"
    ios:
      bundleId: "fr.benoitfontaine.starter.recette"
    macos:
      bundleId: "fr.benoitfontaine.starter.recette"
  integration:
    app:
      name: "Integration"
    android:
      applicationId: "fr.benoitfontaine.starter.integration"
    ios:
      bundleId: "fr.benoitfontaine.starter.integration"
    macos:
      bundleId: "fr.benoitfontaine.starter.integration"
  dev:
    app:
      name: "Dev"
    android:
      applicationId: "fr.benoitfontaine.starter.dev"
    ios:
      bundleId: "fr.benoitfontaine.starter.dev"
    macos:
      bundleId: "fr.benoitfontaine.starter.dev"
  test:
    app:
      name: "Test"
    android:
      applicationId: "fr.benoitfontaine.starter.test"
    ios:
      bundleId: "fr.benoitfontaine.starter.test"
    macos:
      bundleId: "fr.benoitfontaine.starter.test"

ide: idea
```

Vous pouvez ajouter/supprimer les environnements à votre convenance, à l'exception de :
- `prod`: Il s'agit de votre environnement de production
- `dev`: C'est votre poste (exécution locale)
- `test`: indispensables à l'exécution des tests

Une fois que vous l'aurez modifié, lancez la commande
```shell
flutter pub run flutter_flavorizr
```

> **ATTENTION** lancer cette commande modifie les fichiers `main.dart` et `app.dart`. 
> Pensez à les sauvegarder avant de lancer la commande

## Configurer son environnement de développement

Dans le répertoire du projet, les configuration de lancement de l'application sont disponibles dans le dossier `.run`.
Elles devraient être automatiquement détectées par votre IDE. Si ce n'est pas le cas, vous pouvez les ajouter manuellement.

Avant de commencer à coder, il est nécessaire de lancer les scripts :
``` shell
flutter pub get
```

et

``` shell
flutter pub run build_runner watch --delete-conflicting-outputs
```

Ces commandes permettent d'installer ou mettre à jour les dépendances du projet et de l'écoute des modification pour les générateurs de code (tests Gherkin, injection de dépendances, etc).

## les tests

### Retrofit

Les mocks api utilisés pour retrofit sont à mettre dans `/mocks/api/`
Leur format est le suivant :
```json
{
  "GET": {
    "statusCode": 200,
    "data": {}
  }
}
```
Vous pouvez mettre des objets JSON ou des tableaux

### Steps déjà installées

- **J'ai lancé l'application avec succès**: Lance l'application et prépare l'environnement
- **L'application démarre depuis la route {'/'}**: Lance l'application sur une route spécifique et prépare l'environnement
- **Je redimensionne mon écran vers une largeur de {1900} et une hauteur de {1080}**: redimensionne l'écran virtuel utilisé pour les tests


## Fichiers `*_module.dart`

Vous aurez remarqué la présence de fichiers suffixés `*_module.dart` dans chaque dossier. Comme les autres couches (domain et ui) n'ont le droit que d'importer le fichier module de la couche précédente :

- `ui` importe `domain_module.dart`
- `domain` importe `data_module.dart`

Automatiquement, ces modules exportent les sous-dossiers de leur dossier. Ainsi, `domain_module.dart` exporte `repositories` et `usecases` et `data_module.dart` exporte `datasources` et `models`.
De cette manière, chaque couche n'a accès qu'aux éléments qu'elle doit utiliser. Donc, si vous voulez rendre accessible un élément d'une couche à une autre, il faut l'exporter dans le module de la couche supérieure.

## Ajouter une fonctionnalité UI

### Créer un Widget Commun

**ATTENTION** : Un widget commun est un widget qui peut être utilisé dans plusieurs écrans. Il ne doit pas être spécifique à un écran.
De même, il ne doit pas contenir de logiques métiers, être le plus simple possible et ne peut être ajouté que s'il n'est utile qu'au projet en question.

Sinon, sa destination est le **design system**.

### Créer un écran

#### Initialisation
Avant d'ajouter des éléments à l'écran, il y a plusieurs étapes à suivre :

- Créer le dossier avec un nom explicite
- Créer le fichier `*_module.dart` dans le dossier. Il contiendra la classe qui injectera les routes de l'écran dans le router de l'application.
- Créer un sous-dossier par BLoC.

#### Créer un BLoC

Par BLoC, voici comment enregistrer les fichiers :

> Dans cet exemple, le bloc sera nommé `login`

```markdown
|_ login
    |_ view
        |_ components
            |_ login_button.dart (Widget stateless)
            |_ login_form.dart (Widget stateless)
        |_ login_page.dart (Initialise le BLoC)
        |_ login_view.dart (Widget qui affiche l'écran et gère l'état)
    |_ login_bloc.dart (BLoC)
    |_ login_event.dart (Événements du BLoC)
    |_ login_state.dart (États du BLoC)
    |_ login_interactor.dart (Anti-Corruption Layer)
    |_ login_module.dart (Module qui injecte les routes de l'écran dans le router)
```

Pour en savoir plus, merci de vous référer à la documentation Listo [Flutter Avancé](https://www.notion.so/listopaye/Flutter-avanc-e-0891213511e14e8d86380ea41278605b?pvs=4).

Enfin, le seul élément à être injecté est l'interactor. Il est injecté en tant que Singleton et utilisé via le `create` de `BlocProvider`.

#### Exemple de module

Vous pourrez directement copier-coller ce code pour créer un module.

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../ui_module.dart';

@singleton
class FeatureModule implements UIModule {
  final AppRouter _appRouter;

  FeatureModule(this._appRouter) {
    configure();
  }

  void configure() {
    _appRouter.addRoute(
      path: '/user/settings',
      builder: (context, state) {
        return const UserSettingsPage();
      },
    );
  }
}

```

Remplacez `Feature` par le nom de votre fonctionnalité. Pour le reste, utilisez les fonctionnalités `go_router` comme habituellement.
Les routes et sous-routes de l'écran doivent être ajoutées dans la méthode `configure()`.

## Ajouter une fonctionnalité métier

Chaque use case et entities associées doivent être publié via des exports spécifiques dans, respectivement `usecases_module.dart` et `entities_module.dart`.
Grâce à ceci, ils seront directement disponible depuis l'import de `domain_module.dart`.

### Injection de dépendances

Chaque Use Case doit être injecté en tant que Singleton via l'annotation `@singleton` de `injectable`.

Ceci permet de ne garder qu'une seule instance de chaque Use Case et d'éviter les problèmes de synchronisation.

### Cas des appels asynchrones

Pour un souci de cohérence, les appels asynchrones doivent être exclusivement gérés via des `Stream` et mis à disposition des interactors de la, couche `UI`.

### Anti-Corruption Layer

Pour éviter la transmission de "roten code" entre les couches, il est nécessaire de créer une couche d'anti-corruption entre les couches `Data` et `Domain`.
Ainsi, chaque entité doit contenir son pattern `protocol` via une factory nommée `fromDto`.

## Ajouter une fonctionnalité technique

### Utiliser Retrofit

Dans `core/di/api/backend_client.dart`, vous trouverez la classe `BackendClient` qui est un singleton qui permet de faire des appels HTTP.

Pour ajouter une nouvelle méthode, vous pouvez vous baser sur un de ces exemples :
```dart
  @GET('/tasks/{id}')
  Future<Task> getTask(@Path('id') String id);
  
  @GET('/demo')
  Future<String> queries(@Queries() Map<String, dynamic> queries);
  
  @GET('https://httpbin.org/get')
  Future<String> namedExample(
      @Query('apikey') String apiKey,
      @Query('scope') String scope,
      @Query('type') String type,
      @Query('from') int from);
  
  @PATCH('/tasks/{id}')
  Future<Task> updateTaskPart(
      @Path() String id, @Body() Map<String, dynamic> map);
  
  @PUT('/tasks/{id}')
  Future<Task> updateTask(@Path() String id, @Body() Task task);
  
  @DELETE('/tasks/{id}')
  Future<void> deleteTask(@Path() String id);
  
  @POST('/tasks')
  Future<Task> createTask(@Body() Task task);
  
  @POST('http://httpbin.org/post')
  Future<void> createNewTaskFromFile(@Part() File file);
  
  @POST('http://httpbin.org/post')
  @FormUrlEncoded()
  Future<String> postUrlEncodedFormData(@Field() String hello);
```

> **ATTENTION** Seuls les Repositories peuvent utiliser Retrofit. Les Use Cases doivent utiliser les Repositories.

### Ajouter une repository

Voici comment déclarer votre repository

```dart
import 'package:injectable/injectable.dart';

@injectable
class MyRepository {
  final Service _service;
  
  @factoryMethod
  MyRepository(this._service);
  
  repoDto call() {
    return _service.monAction();
  }
}
```

Et voici comment l'utiliser :

```dart
@injectable
class MyUseCase {
  final MyRepository _repository;
  
  @factoryMethod
  MyUseCase(this._repository);
  
  Future<DomainEntity> call() async {
    return DomainEntity.fromDto(_repository());
  }
}
```

## Format des messages de commit
Ces instructions reprennent celles de [Angular](https://docs.google.com/document/d/1QrDFcIiPjSLDn3EL15IJygNPiHORgU1_OOAqWjiDU5Y/edit#)

Ce format conduit à un **historique de commit plus facile à lire**.

Chaque message de commit est composé d'un **en-tête**, d'un **corps**, et d'un **pied de page**.


```
<en-tête>
<LIGNE VIDE>
<corps>
<LIGNE VIDE>
<pied de page>
```

L'`en-tête` est obligatoire et doit se conformer au format En-tête de Message de Commit.

Le `corps` est obligatoire pour tous les commits sauf pour ceux de type "docs".
Lorsque le corps est présent, il doit comporter au moins 20 caractères et se conformer au format Corps de Message de Commit.

Le `pied de page` est facultatif. Le format Pied de Page de Message de Commit décrit l'utilisation du pied de page et la structure qu'il doit avoir.


#### En-tête de Message de Commit

```
<carte jira> - <type>(<portée>) : <résumé court>
    |            │       │             │
    |            │       │             └─⫸ Résumé au temps présent. Non capitalisé. Pas de point à la fin.
    |            │       │
    |            │       └─⫸ Portée du Commit : core|data|domain|ui|design
    |            │
    |            └─⫸ Type de Commit : build|ci|docs|feat|fix|perf|refactor|test
    └─⫸ Numéro de carte JIRA : Numéro que vous avez récupéré sur JIRA (LIS-XXX où XXX est le numéro de la carte)
```

Les champs `<carte jira>`, `<type>` et `<résumé>` sont obligatoires, le champ `(<portée>)` est facultatif.


##### Type

Doit être l'un des suivants :

* **build**: Changements qui affectent le système de build ou les dépendances externes (exemples de portées : gulp, broccoli, npm)
* **ci**: Changements dans nos fichiers et scripts de configuration CI (exemples : CircleCi, SauceLabs)
* **docs**: Changements uniquement dans la documentation
* **feat**: Une nouvelle fonctionnalité
* **fix**: Une correction de bug
* **perf**: Un changement de code qui améliore la performance
* **refactor**: Un changement de code qui ne corrige pas un bug ni n'ajoute une fonctionnalité
* **test**: Ajout de tests manquants ou correction de tests existants


##### Portée
Il s'agit là de mettre le numéro de carte Jira qui est associée au commit.


##### Résumé

Utilisez le champ résumé pour fournir une description succincte du changement :

* utilisez l'impératif, temps présent : "changer" et non "changé" ni "changements"
* ne capitalisez pas la première lettre
* pas de point (.) à la fin


#### Corps de Message de Commit

Comme dans le résumé, utilisez l'impératif, temps présent : "corriger" et non "corrigé" ni "corrections".

Expliquez la motivation du changement dans le corps du message de commit. Ce message de commit devrait expliquer _pourquoi_ vous effectuez le changement.
Vous pouvez inclure une comparaison du comportement précédent avec le nouveau comportement afin d'illustrer l'impact du changement.


#### Pied de Page de Message de Commit

Le pied de page peut contenir des informations sur les changements majeurs et les dépréciations et est également l'endroit pour référencer des issues GitHub, des tickets Jira, et d'autres PR que ce commit ferme ou auxquels il est lié.
Par exemple :

```
MAJOR UPDATE : <résumé du changement majeur>
<LIGNE VIDE>
<description du changement majeur + instructions de migration>
<LIGNE VIDE>
<LIGNE VIDE>
Fix #<numéro de l'issue>
```

ou

```
DEPRECATED : <ce qui est déprécié>
<LIGNE VIDE>
<description de la dépréciation + chemin de mise à jour recommandé>
<LIGNE VIDE>
<LIGNE VIDE>
Close #<numéro de la PR>
```

La section Changement Majeur devrait commencer par la phrase "CHANGEMENT MAJEUR : " suivie d'un résumé du changement majeur, d'une ligne vide, et d'une description détaillée du changement majeur qui inclut également les instructions de migration.

De même, une section Dépréciation devrait commencer par "DÉPRÉCIÉ : " suivi d'une courte description de ce qui est déprécié, d'une ligne vide, et d'une description détaillée de la dépréciation qui mentionne également le chemin de mise à jour recommandé.


### Revert commits

Si le commit annule un commit précédent, il doit commencer par `revert: `, suivi de l'en-tête du commit annulé.

Le contenu du corps du message de commit doit contenir :

- des informations sur le SHA du commit annulé dans le format suivant : `This reverts commit <SHA>`,
- une description claire de la raison pour laquelle le message de commit est annulé.
