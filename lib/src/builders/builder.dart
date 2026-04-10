/// {@category builders}
/// {@category core}
abstract class Builder<T> {
  const Builder();

  Map<String, Object?> build();
}

/// {@category builders}
/// {@category core}
abstract class CreateBuilder<T> extends Builder<T> {
  const CreateBuilder();
}

/// {@category builders}
/// {@category core}
abstract class UpdateBuilder<T> extends Builder<T> {
  const UpdateBuilder();
}
