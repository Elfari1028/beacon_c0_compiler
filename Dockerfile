FROM google/dart

WORKDIR /app/

COPY pubspec.* /app/
RUN export PUB_HOSTED_URL="https://mirrors.tuna.tsinghua.edu.cn/dart-pub"
# RUN pub get

COPY . /app/
RUN pub get --offline