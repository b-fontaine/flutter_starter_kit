import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:injectable/injectable.dart';

import '/injection.dart';
import '../di_module.dart';

@dev
@integration
@recette
@preprod
@prod
@Singleton(as: ApiModule)
class ApiModuleImpl implements ApiModule {
  late final Dio _dio;
  late final ApiClient _client;

  ApiModuleImpl(Configuration configuration) {
    var cache = CacheOptions(
      store: MemCacheStore(),
      policy: CachePolicy.request,
      hitCacheOnErrorCodes: CacheStrategyFactory.allowedStatusCodes,
    );
    _dio = Dio()..interceptors.addAll([DioCacheInterceptor(options: cache)]);
    _client = ApiClient(_dio, baseUrl: configuration.apiBaseUrl);
  }

  @override
  ApiClient get client => _client;

  @override
  Dio get dio => _dio;
}
