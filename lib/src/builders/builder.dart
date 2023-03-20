abstract class Builder<T> {
  const Builder();

  Map<String, Object?> build();
}

abstract class CreateBuilder<T> extends Builder<T> {
  const CreateBuilder();
}

abstract class UpdateBuilder<T> extends Builder<T> {
  const UpdateBuilder();
}
