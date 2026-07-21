# Docker LAMP

Ambiente de desenvolvimento LAMP (**L**inux, **A**pache, **M**ariaDB, **P**HP) totalmente containerizado com Docker Compose, incluindo phpMyAdmin para administração do banco de dados.

## Sobre este repositório

Este projeto sobe uma stack completa para desenvolvimento local de aplicações PHP, composta por três serviços:

| Serviço     | Descrição                                              | Imagem base            |
|-------------|---------------------------------------------------------|------------------------|
| `app`       | Apache 2 + PHP 8.3, construído a partir do `Dockerfile` | `ubuntu:24.04`         |
| `mariadb`   | Banco de dados MariaDB                                  | `mariadb:11.4`         |
| `phpmyadmin`| Interface web para administração do MariaDB              | `phpmyadmin:5.2`       |

O container `app` já vem com Composer instalado, `mod_rewrite` e `mod_headers` habilitados, e suporte a arquivos `.htaccess` (`AllowOverride All`) na raiz do projeto.

### Estrutura de pastas

```
docker-lamp/
├── config/
│   ├── php.ini             # Configuração customizada do PHP
│   └── 000-default.conf    # VirtualHost do Apache
├── logs/
│   ├── apache2/            # Logs de acesso e erro do Apache
│   └── mysql/              # Logs do MariaDB
├── src/                     # Código-fonte da aplicação (DocumentRoot)
├── Dockerfile               # Build da imagem do serviço "app"
├── docker-compose.yml
├── .env.example             # Modelo de variáveis de ambiente
└── README.md
```

## Requisitos

Para reproduzir este ambiente você precisa ter instalado:

- [Docker](https://docs.docker.com/get-docker/) versão 20.10 ou superior
- [Docker Compose](https://docs.docker.com/compose/install/) versão 2.x (plugin `docker compose` ou binário `docker-compose`)
- Git (para clonar o repositório)
- Portas `80`, `3306` e `8080` livres no host (ou ajustáveis via `.env`, veja abaixo)

Não é necessário ter PHP, Apache ou MySQL/MariaDB instalados na máquina host — tudo roda dentro dos containers.

## Como reproduzir o ambiente

### 1. Clonar o repositório

```bash
git clone https://github.com/leomanfredini/docker-lamp.git
cd docker-lamp
```

### 2. Configurar variáveis de ambiente

Copie o arquivo de exemplo e ajuste os valores conforme necessário:

```bash
cp .env.example .env
```

Edite o `.env` e defina, no mínimo, uma senha de root e de usuário do banco:

```env
APP_PORT=80
DB_PORT=3306
PMA_PORT=8080

MYSQL_ROOT_PASSWORD=defina-uma-senha-forte
MYSQL_DATABASE=lamp
MYSQL_USER=user
MYSQL_PASSWORD=defina-outra-senha-forte
```



### 3. Colocar o código-fonte da aplicação

Adicione os arquivos da sua aplicação PHP dentro da pasta `src/`. Esse diretório é montado como `DocumentRoot` do Apache.

### 4. Subir a stack

```bash
docker compose up -d --build
```

Esse comando constrói a imagem do serviço `app` e inicia os três containers em segundo plano.

### 5. Acessar os serviços

| Serviço     | URL                                      |
|-------------|-------------------------------------------|
| Aplicação   | http://localhost:80 (ou a porta definida em `APP_PORT`) |
| phpMyAdmin  | http://localhost:8080 (ou `PMA_PORT`)     |
| MariaDB     | `localhost:3306` (ou `DB_PORT`), via cliente de banco de dados |

### 6. Parar/derrubar o ambiente

```bash
docker compose down          # para os containers, mantém os dados do banco
docker compose down -v       # para os containers e apaga também o volume do banco
```

## Comandos úteis

```bash
# Ver logs em tempo real
docker compose logs -f app

# Acessar o shell do container da aplicação
docker exec -it docker-lamp bash

# Verificar módulos do Apache habilitados
docker exec docker-lamp apache2ctl -M

# Rodar comandos do Composer dentro do container
docker exec -it docker-lamp composer install
```

## Observações

- Este ambiente é voltado para **desenvolvimento local**, não para produção.
- Alterações no `Dockerfile` exigem rebuild da imagem (`docker compose up -d --build`).
- Alterações em `config/php.ini` e `config/000-default.conf` são aplicadas apenas reiniciando o container, já que são montadas como volume (`docker compose restart app`).
- Certifique-se de que os serviços tenham política de `restart` configurada (`unless-stopped`) para que a stack volte automaticamente após um reboot do servidor.


