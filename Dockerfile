FROM google/dart

WORKDIR /app/

COPY pubspec.* /app/
RUN pub get

COPY . /app/
RUN pub get --offline