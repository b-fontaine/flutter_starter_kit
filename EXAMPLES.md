# Exemples de Code - Flutter Starter Kit

Ce document contient des exemples de code détaillés pour le projet Flutter Starter Kit.
Pour les règles et contraintes de développement, consultez [AGENTS.md](./AGENTS.md).

---

## Table des matières

1. [Créer un DTO](#créer-un-dto)
2. [Créer une Entity](#créer-une-entity)
3. [Créer un Repository](#créer-un-repository)
4. [Créer un Use Case](#créer-un-use-case)
5. [Créer un BLoC complet](#créer-un-bloc-complet)
6. [Créer un module UI avec routes](#créer-un-module-ui-avec-routes)
7. [Configurer Retrofit (API Client)](#configurer-retrofit-api-client)
8. [Tests BDD avec bdd_widget_test](#tests-bdd-avec-bdd_widget_test)
9. [Mocking API avec dio_mocked_responses](#mocking-api-avec-dio_mocked_responses)

---

## Créer un DTO

Les DTOs (Data Transfer Objects) sont utilisés pour la sérialisation/désérialisation JSON. Ils résident dans
`lib/data/dto/`.

```dart
// lib/data/dto/task_dto.dart
import 'package:json_annotation/json_annotation.dart';

part 'task_dto.g.dart';

@JsonSerializable()
class TaskDto {
  const TaskDto({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.createdAt,
  });

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'description')
  final String? description;

  @JsonKey(name: 'is_completed', defaultValue: false)
  final bool isCompleted;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  factory TaskDto.fromJson(Map<String, dynamic> json) => _$TaskDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TaskDtoToJson(this);
}
```

**Exporter dans le module :**

```dart
// lib/data/dto/dto_module.dart
export 'task_dto.dart';
```

---

## Créer une Entity

Les entités du domaine résident dans `lib/domain/entities/`. Elles contiennent la factory `fromDto` pour
l'Anti-Corruption Layer.

```dart
// lib/domain/entities/task.dart
import 'package:flutter_starter_kit/data/data_module.dart';

class Task {
  const Task({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.createdAt,
  });

  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime? createdAt;

  /// Anti-Corruption Layer : conversion DTO -> Entity
  factory Task.fromDto(TaskDto dto) {
    return Task(
      id: dto.id,
      title: dto.title,
      description: dto.description,
      isCompleted: dto.isCompleted,
      createdAt: dto.createdAt,
    );
  }

  /// Conversion Entity -> DTO (si nécessaire pour les appels API)
  TaskDto toDto() {
    return TaskDto(
      id: id,
      title: title,
      description: description,
      isCompleted: isCompleted,
      createdAt: createdAt,
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
```

**Exporter dans le module :**

```dart
// lib/domain/entities/entities_module.dart
export 'task.dart';
```

---

## Créer un Repository

Les repositories résident dans `lib/data/repositories/`. Ils utilisent l'ApiClient pour les appels réseau.

```dart
// lib/data/repositories/task_repository.dart
import 'package:injectable/injectable.dart';

import 'package:flutter_starter_kit/core/core_module.dart';
import '../dto/dto_module.dart';

@injectable
class TaskRepository {
  final ApiModule _apiModule;

  @factoryMethod
  TaskRepository(this._apiModule);

  /// Récupère toutes les tâches depuis l'API
  Future<List<TaskDto>> getTasks() async {
    return _apiModule.client.getTasks();
  }

  /// Récupère une tâche par son ID
  Future<TaskDto> getTaskById(String id) async {
    return _apiModule.client.getTask(id);
  }

  /// Crée une nouvelle tâche
  Future<TaskDto> createTask(TaskDto task) async {
    return _apiModule.client.createTask(task);
  }

  /// Met à jour une tâche existante
  Future<TaskDto> updateTask(String id, TaskDto task) async {
    return _apiModule.client.updateTask(id, task);
  }

  /// Supprime une tâche
  Future<void> deleteTask(String id) async {
    return _apiModule.client.deleteTask(id);
  }
}
```

**Exporter dans le module :**

```dart
// lib/data/repositories/repositories_module.dart
export 'task_repository.dart';
```

---

## Créer un Use Case

Les Use Cases résident dans `lib/domain/usecases/`. Ils orchestrent la logique métier et convertissent les DTOs en
entités.

```dart
// lib/domain/usecases/get_tasks_use_case.dart
import 'package:injectable/injectable.dart';

import 'package:flutter_starter_kit/data/data_module.dart';
import '../entities/entities_module.dart';

@singleton
class GetTasksUseCase {
  final TaskRepository _repository;

  @factoryMethod
  GetTasksUseCase(this._repository);

  /// Récupère toutes les tâches et les convertit en entités du domaine
  Future<List<Task>> call() async {
    final dtos = await _repository.getTasks();
    return dtos.map((dto) => Task.fromDto(dto)).toList();
  }
}
```

**Exemple avec Stream (pour les données réactives) :**

```dart
// lib/domain/usecases/watch_tasks_use_case.dart
import 'dart:async';

import 'package:injectable/injectable.dart';

import 'package:flutter_starter_kit/data/data_module.dart';
import '../entities/entities_module.dart';

@singleton
class WatchTasksUseCase {
  final TaskRepository _repository;
  final StreamController<List<Task>> _controller = StreamController.broadcast();

  @factoryMethod
  WatchTasksUseCase(this._repository);

  Stream<List<Task>> call() => _controller.stream;

  Future<void> refresh() async {
    final dtos = await _repository.getTasks();
    final tasks = dtos.map((dto) => Task.fromDto(dto)).toList();
    _controller.add(tasks);
  }

  @disposeMethod
  void dispose() {
    _controller.close();
  }
}
```

**Exporter dans le module :**

```dart
// lib/domain/usecases/usecases_module.dart
export 'get_tasks_use_case.dart';
export 'watch_tasks_use_case.dart';
```

---

## Créer un BLoC complet

Un BLoC (Business Logic Component) gère l'état d'un écran. Voici la structure complète :

### 1. Events (événements)

```dart
// lib/ui/tasks/task_list_event.dart
import 'package:flutter_starter_kit/domain/domain_module.dart';

abstract class TaskListEvent {}

class LoadTasksEvent extends TaskListEvent {}

class RefreshTasksEvent extends TaskListEvent {}

class DeleteTaskEvent extends TaskListEvent {
  final String taskId;

  DeleteTaskEvent(this.taskId);
}

class ToggleTaskCompletedEvent extends TaskListEvent {
  final Task task;

  ToggleTaskCompletedEvent(this.task);
}
```

### 2. States (états)

```dart
// lib/ui/tasks/task_list_state.dart
import 'package:flutter_starter_kit/domain/domain_module.dart';

abstract class TaskListState {}

class TaskListInitial extends TaskListState {}

class TaskListLoading extends TaskListState {}

class TaskListLoaded extends TaskListState {
  final List<Task> tasks;

  TaskListLoaded(this.tasks);
}

class TaskListError extends TaskListState {
  final String message;

  TaskListError(this.message);
}
```

### 3. Interactor (Anti-Corruption Layer UI)

```dart
// lib/ui/tasks/task_list_interactor.dart
import 'package:injectable/injectable.dart';

import 'package:flutter_starter_kit/domain/domain_module.dart';

@singleton
class TaskListInteractor {
  final GetTasksUseCase _getTasksUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;

  @factoryMethod
  TaskListInteractor(this._getTasksUseCase, this._deleteTaskUseCase);

  Future<List<Task>> getTasks() => _getTasksUseCase();

  Future<void> deleteTask(String id) => _deleteTaskUseCase(id);
}
```

### 4. BLoC

```dart
// lib/ui/tasks/task_list_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import 'task_list_event.dart';
import 'task_list_state.dart';
import 'task_list_interactor.dart';

class TaskListBloc extends Bloc<TaskListEvent, TaskListState> {
  final TaskListInteractor _interactor;

  TaskListBloc(this._interactor) : super(TaskListInitial()) {
    on<LoadTasksEvent>(_onLoadTasks);
    on<RefreshTasksEvent>(_onRefreshTasks);
    on<DeleteTaskEvent>(_onDeleteTask);
  }

  Future<void> _onLoadTasks(LoadTasksEvent event,
      Emitter<TaskListState> emit,) async {
    emit(TaskListLoading());
    try {
      final tasks = await _interactor.getTasks();
      emit(TaskListLoaded(tasks));
    } catch (e) {
      emit(TaskListError(e.toString()));
    }
  }

  Future<void> _onRefreshTasks(RefreshTasksEvent event,
      Emitter<TaskListState> emit,) async {
    try {
      final tasks = await _interactor.getTasks();
      emit(TaskListLoaded(tasks));
    } catch (e) {
      emit(TaskListError(e.toString()));
    }
  }

  Future<void> _onDeleteTask(DeleteTaskEvent event,
      Emitter<TaskListState> emit,) async {
    try {
      await _interactor.deleteTask(event.taskId);
      add(RefreshTasksEvent());
    } catch (e) {
      emit(TaskListError(e.toString()));
    }
  }
}
```

### 5. Page (initialise le BLoC)

```dart
// lib/ui/tasks/view/task_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_starter_kit/injection.dart';
import '../task_list_bloc.dart';
import '../task_list_event.dart';
import '../task_list_interactor.dart';
import 'task_list_view.dart';

class TaskListPage extends StatelessWidget {
  const TaskListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      TaskListBloc(getIt<TaskListInteractor>())
        ..add(LoadTasksEvent()),
      child: const TaskListView(),
    );
  }
}
```

### 6. View (affiche l'écran)

```dart
// lib/ui/tasks/view/task_list_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../task_list_bloc.dart';
import '../task_list_event.dart';
import '../task_list_state.dart';
import 'components/task_list_item.dart';

class TaskListView extends StatelessWidget {
  const TaskListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tâches')),
      body: BlocConsumer<TaskListBloc, TaskListState>(
        listener: (context, state) {
          if (state is TaskListError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is TaskListLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TaskListLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<TaskListBloc>().add(RefreshTasksEvent());
              },
              child: ListView.builder(
                itemCount: state.tasks.length,
                itemBuilder: (context, index) {
                  final task = state.tasks[index];
                  return TaskListItem(
                    task: task,
                    onDelete: () {
                      context.read<TaskListBloc>().add(DeleteTaskEvent(task.id));
                    },
                  );
                },
              ),
            );
          }
          return const Center(child: Text('Aucune tâche'));
        },
      ),
    );
  }
}
```

### 7. Component (widget réutilisable)

```dart
// lib/ui/tasks/view/components/task_list_item.dart
import 'package:flutter/material.dart';

import 'package:flutter_starter_kit/domain/domain_module.dart';

class TaskListItem extends StatelessWidget {
  final Task task;
  final VoidCallback onDelete;

  const TaskListItem({
    super.key,
    required this.task,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(task.title),
      subtitle: task.description != null ? Text(task.description!) : null,
      leading: Icon(
        task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
        color: task.isCompleted ? Colors.green : Colors.grey,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: onDelete,
      ),
    );
  }
}
```

---

## Créer un module UI avec routes

Les modules UI injectent les routes dans le router de l'application. Ils résident dans le dossier de la feature.

```dart
// lib/ui/tasks/tasks_module.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../ui_module.dart';
import '../router.dart';
import 'view/task_list_page.dart';
import 'view/task_detail_page.dart';

@singleton
class TasksModule implements UIModule {
  final AppRouter _appRouter;

  TasksModule(this._appRouter) {
    configure();
  }

  void configure() {
    // Route principale
    _appRouter.addRoute(
      path: '/tasks',
      builder: (context, state) {
        return const TaskListPage();
      },
    );

    // Route avec paramètre
    _appRouter.addRoute(
      path: '/tasks/:id',
      builder: (context, state) {
        final taskId = state.pathParameters['id']!;
        return TaskDetailPage(taskId: taskId);
      },
    );
  }
}
```

**Interface UIModule :**

```dart
// lib/ui/ui_module.dart
abstract class UIModule {
  void configure();
}

export 'app.dart';
export 'router.dart';
```

**Navigation entre écrans :**

```dart
// Depuis n'importe quel widget
context.go('/tasks');           // Navigation simple
context.go('/tasks/123');       // Avec paramètre
context.push('/tasks/123');     // Empiler sur la pile de navigation
context.pop();                  // Retour arrière
```

---

## Configurer Retrofit (API Client)

Le fichier `lib/core/di/network/api_client.dart` définit tous les endpoints de l'API.

### Déclaration complète de l'ApiClient

```dart
// lib/core/di/network/api_client.dart
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'package:flutter_starter_kit/data/data_module.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: '')
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  // ===== GET Requests =====

  /// Récupérer une ressource par ID
  @GET('/tasks/{id}')
  Future<TaskDto> getTask(@Path('id') String id);

  /// Récupérer une liste de ressources
  @GET('/tasks')
  Future<List<TaskDto>> getTasks();

  /// Avec query parameters nommés
  @GET('/tasks')
  Future<List<TaskDto>> getTasksFiltered(@Query('status') String status,
      @Query('limit') int limit,
      @Query('offset') int offset,);

  /// Avec query parameters dynamiques (Map)
  @GET('/search')
  Future<List<TaskDto>> search(@Queries() Map<String, dynamic> queries);

  // ===== POST Requests =====

  /// Créer une ressource avec body JSON
  @POST('/tasks')
  Future<TaskDto> createTask(@Body() TaskDto task);

  /// Envoyer un formulaire URL-encoded
  @POST('/login')
  @FormUrlEncoded()
  Future<AuthResponseDto> login(@Field('username') String username,
      @Field('password') String password,);

  /// Upload de fichier (multipart)
  @POST('/upload')
  @MultiPart()
  Future<UploadResponseDto> uploadFile(@Part() File file);

  /// Upload avec métadonnées
  @POST('/documents')
  @MultiPart()
  Future<DocumentDto> uploadDocument(@Part() File file,
      @Part(name: 'title') String title,
      @Part(name: 'description') String? description,);

  // ===== PUT Requests =====

  /// Remplacer une ressource complète
  @PUT('/tasks/{id}')
  Future<TaskDto> updateTask(@Path('id') String id,
      @Body() TaskDto task,);

  // ===== PATCH Requests =====

  /// Mise à jour partielle
  @PATCH('/tasks/{id}')
  Future<TaskDto> patchTask(@Path('id') String id,
      @Body() Map<String, dynamic> updates,);

  // ===== DELETE Requests =====

  /// Supprimer une ressource
  @DELETE('/tasks/{id}')
  Future<void> deleteTask(@Path('id') String id);

  // ===== Headers personnalisés =====

  /// Avec header dynamique
  @GET('/protected/data')
  Future<DataDto> getProtectedData(@Header('Authorization') String token,);

  /// Avec headers statiques
  @GET('/api/v2/data')
  @Headers(<String, dynamic>{
    'Accept': 'application/json',
    'X-Api-Version': '2.0',
  })
  Future<DataDto> getDataV2();

  // ===== Réponse HTTP complète =====

  /// Pour accéder aux headers de réponse, status code, etc.
  @GET('/tasks/{id}')
  Future<HttpResponse<TaskDto>> getTaskWithResponse(@Path('id') String id);
}
```

### Annotations Retrofit disponibles

| Annotation                                   | Usage                                    |
|----------------------------------------------|------------------------------------------|
| `@GET`, `@POST`, `@PUT`, `@PATCH`, `@DELETE` | Méthode HTTP                             |
| `@Path('name')`                              | Paramètre dans l'URL                     |
| `@Query('name')`                             | Query parameter unique                   |
| `@Queries()`                                 | Map de query parameters                  |
| `@Body()`                                    | Corps de la requête (JSON)               |
| `@Field('name')`                             | Champ de formulaire URL-encoded          |
| `@Part()`                                    | Partie d'un multipart (fichier ou champ) |
| `@Header('name')`                            | Header HTTP dynamique                    |
| `@Headers({...})`                            | Headers HTTP statiques                   |
| `@FormUrlEncoded()`                          | Requête form-urlencoded                  |
| `@MultiPart()`                               | Requête multipart/form-data              |

---

## Tests BDD avec bdd_widget_test

Le projet utilise `bdd_widget_test` pour écrire des tests en syntaxe Gherkin.

### Configuration (build.yaml)

```yaml
# build.yaml
targets:
  $default:
    builders:
      bdd_widget_test|featureBuilder:
        options:
          stepFolderName: gherkin/steps
```

### Créer un fichier .feature

Les fichiers `.feature` vont dans `test/gherkin/features/`.

```gherkin
# test/gherkin/features/task_list.feature

Feature: Liste des tâches
  En tant qu'utilisateur
  Je veux voir la liste de mes tâches
  Afin de gérer mon travail

  Background:
    Given J'ai lancé l'application avec succès

  Scenario: Affichage de la liste vide
    Then I see {'Aucune tâche'} text

  Scenario: Affichage des tâches
    Given il y a des tâches disponibles
    Then I see {'Ma première tâche'} text
    And I see {'Ma deuxième tâche'} text

  Scenario: Suppression d'une tâche
    Given il y a des tâches disponibles
    When I tap {Icons.delete} icon
    Then I don't see {'Ma première tâche'} text

  Scenario: Navigation vers le détail
    Given il y a des tâches disponibles
    When I tap {'Ma première tâche'} text
    Then I see {'Détail de la tâche'} text
```

### Syntaxe Gherkin supportée

```gherkin
# Paramètres entre accolades (valeurs Dart valides)
Then I see {'texte'} text           # String
Then I see {42} number              # int
Then I tap {Icons.add} icon         # IconData

# Scenario Outline avec Examples
Scenario Outline: Compteur
When I tap {Icons.add} icon <times> times
Then I see <result> text

Examples:
| times | result |
|   1   |  '1'   |
|   5   |  '5'   |

# Tags pour filtrer les tests
@slow
@integration
Feature: Tests lents

  @skip
  Scenario: Test ignoré
```

### Créer une step personnalisée

Les steps sont générées automatiquement dans `test/gherkin/steps/`. Modifiez-les selon vos besoins.

```dart
// test/gherkin/steps/il_y_a_des_taches_disponibles.dart
import 'package:flutter_test/flutter_test.dart';

/// Usage: Given il y a des tâches disponibles
Future<void> ilYADesTachesDisponibles(WidgetTester tester) async {
  // Préparer les données de test (mock API, etc.)
  // Le MockInterceptor chargera automatiquement les fichiers JSON
  await tester.pumpAndSettle();
}
```

```dart
// test/gherkin/steps/je_vois_n_taches.dart
import 'package:flutter_test/flutter_test.dart';

/// Usage: Then je vois {3} tâches
Future<void> jeVoisNTaches(WidgetTester tester, int count) async {
  // Vérifier le nombre de tâches affichées
  final taskItems = find.byType(TaskListItem);
  expect(taskItems, findsNWidgets(count));
}
```

### Steps pré-installées

| Step                                                                             | Description                    |
|----------------------------------------------------------------------------------|--------------------------------|
| `J'ai lancé l'application avec succès`                                           | Initialise l'app en mode test  |
| `L'application démarre depuis la route {'/tasks'}`                               | Lance sur une route spécifique |
| `Je redimensionne mon écran vers une largeur de {1920} et une hauteur de {1080}` | Change la taille de l'écran    |
| `I see {'texte'} text`                                                           | Vérifie la présence d'un texte |
| `I don't see {'texte'} text`                                                     | Vérifie l'absence d'un texte   |
| `I tap {'texte'} text`                                                           | Tape sur un texte              |
| `I tap {Icons.add} icon`                                                         | Tape sur une icône             |
| `I enter {'valeur'} into {0} input field`                                        | Saisit du texte                |

### Lancer les tests

```bash
# Générer les fichiers de test
dart run build_runner build --delete-conflicting-outputs

# Lancer tous les tests
flutter test

# Lancer un test spécifique
flutter test test/gherkin/features/task_list_test.dart

# Filtrer par tag
flutter test --tags integration
flutter test --exclude-tags slow
```

---

## Mocking API avec dio_mocked_responses

Le package `dio_mocked_responses` intercepte les appels HTTP et retourne des réponses mockées depuis des fichiers JSON.

### Structure des fichiers de mock

Les mocks sont dans `/mocks/api/`. Le nom du fichier correspond au chemin de l'endpoint (sans préfixe de verbe HTTP).

**Important :** Un seul fichier JSON peut contenir les mocks pour plusieurs verbes HTTP (GET, POST, PUT, PATCH, DELETE) simultanément.

```
mocks/api/
├── tasks.json                  # GET, POST, PUT, PATCH, DELETE /tasks
├── tasks_123.json              # GET, PUT, PATCH, DELETE /tasks/123
├── tasks_status_pending.json   # GET /tasks?status=pending
├── login.json                  # POST /login
├── users_1_tasks.json          # GET /users/1/tasks
└── admin/                      # Persona "admin"
    └── tasks.json
```

### Format des fichiers JSON

Un fichier peut contenir plusieurs verbes HTTP pour le même endpoint :

```json
// mocks/api/tasks.json
{
  "GET": {
    "statusCode": 200,
    "data": [
      {
        "id": "1",
        "title": "Ma première tâche",
        "description": "Description de la tâche",
        "is_completed": false,
        "created_at": "2024-01-15T10:30:00Z"
      },
      {
        "id": "2",
        "title": "Ma deuxième tâche",
        "is_completed": true
      }
    ]
  },
  "POST": {
    "statusCode": 201,
    "data": {
      "id": "new-id",
      "title": "Nouvelle tâche créée"
    }
  }
}
```

### Exemple complet avec tous les verbes HTTP

```json
// mocks/api/tasks_123.json
{
  "GET": {
    "statusCode": 200,
    "data": {
      "id": "123",
      "title": "Tâche spécifique",
      "description": "Détails de la tâche 123",
      "is_completed": false
    }
  },
  "PUT": {
    "statusCode": 200,
    "data": {
      "id": "123",
      "title": "Tâche mise à jour",
      "description": "Description modifiée",
      "is_completed": true
    }
  },
  "PATCH": {
    "statusCode": 200,
    "data": {
      "id": "123",
      "title": "Tâche partiellement mise à jour",
      "is_completed": true
    }
  },
  "DELETE": {
    "statusCode": 204,
    "data": null
  }
}
```

### Simuler des erreurs

Pour simuler des erreurs, créez un fichier séparé ou utilisez les contextes :

```json
// mocks/api/tasks_not_found.json
{
  "GET": {
    "statusCode": 404,
    "data": {
      "error": "Not Found",
      "message": "Tâche non trouvée"
    }
  }
}
```

```json
// mocks/api/tasks_error.json
{
  "GET": {
    "statusCode": 500,
    "data": {
      "error": "Internal Server Error",
      "message": "Une erreur est survenue"
    }
  },
  "POST": {
    "statusCode": 400,
    "data": {
      "error": "Bad Request",
      "message": "Données invalides"
    }
  }
}
```

### Réponses dynamiques avec templates

```json
// mocks/api/login.json
{
  "POST": {
    "statusCode": 200,
    "template": {
      "content": {
        "message": "Bienvenue, ${req.data.username}!",
        "token": "jwt-token-for-${req.data.username}"
      }
    }
  }
}
```

### Utiliser les personas

Les personas permettent de simuler différents utilisateurs/rôles.

```dart
// Dans un test
MockInterceptor.setPersona('admin');
// Les mocks seront cherchés dans mocks/api/admin/

MockInterceptor.clearPersona();
// Retour aux mocks par défaut
```

### Utiliser les contextes

```dart
// Simuler un état spécifique
MockInterceptor.setContext('logged_in');
MockInterceptor.clearContext();
```

### Historique des requêtes

```dart
// Vérifier les appels API dans les tests
final history = MockInterceptor.history;
expect(history.length, 2);
expect(history[0].method, 'GET');
expect(history[0].path, '/tasks');

// Nettoyer l'historique
MockInterceptor.clearHistory();
```

### Convention de nommage des fichiers

| Endpoint                         | Fichier mock               |
|----------------------------------|----------------------------|
| `/tasks` (tous verbes)           | `tasks.json`               |
| `/tasks/123` (tous verbes)       | `tasks_123.json`           |
| `/tasks?status=pending`          | `tasks_status_pending.json`|
| `/users/1/tasks`                 | `users_1_tasks.json`       |
| `/auth/login`                    | `auth_login.json`          |

**Règles de nommage :**
- Remplacer les `/` par `_`
- Remplacer les paramètres de chemin par leur valeur (ex: `/tasks/123` → `tasks_123.json`)
- Ne PAS préfixer par le verbe HTTP
- Un fichier peut contenir plusieurs verbes HTTP
