FROM ruby:2.6-alpine3.11
#Editamos la version de bundler que usaremos
ENV BUNDLER_VERSION=2.1.4
# Librerias de OSLinux necesarias para que nuestro proyecto funcione
RUN apk add --update --no-cache \
binutils-gold \
build-base \
mysql-client \
mariadb-dev \
curl \
file \
g++ \
gcc \
git \
less \
libstdc++ \
libffi-dev \
libc-dev \ 
linux-headers \
libxml2-dev \
libxslt-dev \
libgcrypt-dev \
make \
netcat-openbsd \
nodejs \
openssl \
pkgconfig \
postgresql-dev \
python \
tzdata \
yarn
# Instalamos la version de bundler que usaremos
RUN gem install bundler -v 2.1.4
# Definimos el directorio de trabajo
WORKDIR /app
# Copiamos los archivos de dependencias
COPY Gemfile Gemfile.lock ./
# Instalamos las dependencias
RUN bundle config build.nokogiri --use-system-libraries
RUN bundle check || bundle install
# Copiamos todo al directorio de trabajo
COPY . ./ 
# Seteamos algunas variables de entorno de base de datos, dejamos la de produccion, seteadas con un vacio
# esta manera no nos molestara rails al realizar el test, las de produccion deben ser seteadas externamentes
# dependiendo del ambiente de integracion, puede ser por el manejar de git o bien desde la nube
ENV TEST_USERNAME=rails_test
ENV TEST_PASSWORD=asvJFLktUTv4cAh9
ENV PROD_USERNAME=xxxxx
ENV PROD_PASSWORD=xxxxx
# Variable en caso de que fueramos a hacer un test que requiera el API KEY
# ENV API_KEY=xxxxxx
# Corremos los test, para asegurarnos de que todo funciona bien antes de pasar a produccion
RUN ["rails", "test"]
# Editamos la variable de entorno de rails, para que entienda que debe correr en produccion
ENV RAILS_ENV=production
# Arrancamos el servidor en produccion, habilitado para todo publico
CMD ["rails", "server", "-b", "0.0.0.0"]
