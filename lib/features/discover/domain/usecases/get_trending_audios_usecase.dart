import '../entities/audio_entity.dart';
import '../repositories/discovery_repository.dart';

class GetTrendingAudiosUseCase {
  final DiscoveryRepository repository;

  GetTrendingAudiosUseCase(this.repository);

  Future<List<AudioEntity>> call() async {
    return repository.getTrendingAudios();
  }
}
