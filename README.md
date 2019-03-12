# AnyEx [![Build Status](https://github-ci.bluerain.io/api/badges/anyex-project/anyex/status.svg)](https://github-ci.bluerain.io/anyex-project/anyex)

快速、轻量级、功能完备的博客 API 服务

## 开发技术

AnyEx 是纯 Elixir 实现的（不算间接包含的 Erlang 库），没有使用 Phoenix 框架，纯 Plug 开发的轻量级 Web 服务应用。大量的使用宏生成路由和通用数据库访问层函数/结构以至于代码量没有想象的大。

Elixir 不是化妆水品牌，是一个运行于 Erlang 虚拟机的方言，和 Erlang 一脉相承，能无缝调用 Erlang 的类库。同时它是一门纯函数式的，面向并行的语法先进且友好的高效编程技术，如果你对 Elixir 感兴趣（Ruby/Erlang 程序员非常有必要认识 Elixir），可以加入下面的交流群：

| 平台 | 账号 |
|:---:|:---:|
| TG 群| [t.me/elixir_cn](https://t.me/elixir_cn) |
| QQ 群| 280887141 |

## 部署指南

当前的计划是在接近 1.0 版本的时候开放官方 Docker 镜像，所以目前您需要采取以下的方式手动构建并部署。

## 安装指南

如果您没有 Elixir 程序的编译和部署经历，推荐使用 Docker 来进行这一套搭建流程，傻瓜式且不会污染文件系统（多余的 Erlang/Elixir 运行时和缓存）。

不过在进行下列的步骤之前您需要 clone 代码到本地，进入项目主目录并切到最新的 release 版本：

```` bash
git clone https://github.com/anyex-project/anyex.git
cd anyex
git checkout v0.10.3
````

### 基于 Docker

1. 添加配置

    ```` bash
    touch apps/storage/config/prod.secret.exs
    touch apps/web_server/config/prod.secret.exs
    ````

1. 生成文档

    ```` bash
    docker run --rm -v ${PWD}:/local openapitools/openapi-generator-cli \
    generate -i /local/apps/web_server/priv/static/doc.yaml -g html2 -o /local/apps/web_server/priv/static/doc
    ````

1. 打包应用

    ```` bash
    docker run -ti --rm --env MIX_ENV=prod -v $PWD:/code bluerain/elixir:1.8.1-slim \
    mix do clean, deps.get, release
    ````

1. 构建镜像

    ```` bash
    docker build . -t bluerain/anyex
    ````

1. 启动应用

    ```` bash
    docker-compose -f prod.docker-compose.yml up -d
    ````

    到这里应用已经启动，使用 `curl http://localhost:8080/ping` 命令测试在终端输出 `pong`  表示成功运行。

    不过还没有结束。虽然数据库、应用容器都已经启动，参数也都配置好了(在 `prod.docker-compose.yml` 中定义)。但还没有进行表数据生成，如果访问需要操作数据表的 API 都会返回错误。

1. 数据迁移

    ```` bash
    docker exec -ti anyex_server_1 anyex migrate
    ````

    执行上述命令至此，AnyEx 整个已经部署好了。得益于 Docker Compose 对容器的编排，应用总能在系统重启后自动运行并在进程崩溃时自动重启。

    注意：这一步中的容器 `anyex_server_1` 不一定存在，容器的命名可能会因为 `docker-compose` 的版本差异而不同，应以实际创建的 `server` 容器名为主。

### 手动编译

1. 安装 Elixir

    不同的操作系统（或 Linux 发型版）安装的方式无法统一，所以这里不作安装说明。更加通用的方式是使用 [asdf](https://github.com/asdf-vm/asdf) 或者参照官方[安装指南](https://elixir-lang.org/install.html)。

1. 添加配置

    ```` bash
    touch apps/storage/config/prod.secret.exs
    touch apps/web_server/config/prod.secret.exs
    ````

    如果您想将配置信息编译到二进制应用中，则需要进行下面的编辑（如果不需要直接看下一步）：

    编辑 `apps/storage/config/prod.secret.exs` 文件：

    ```` elixir
    use Mix.Config

    config :storage, Storage.Repo,
      database: "anyex_prod",
      username: "postgres",
      hostname: "localhost",
      password: "sampledb123"
    ````

    编辑 `apps/web_server/config/prod.secret.exs` 文件：

    ```` elixir
    use Mix.Config

    config :web_server,
      port: 8080,
      username: "admin",
      password: "admin123",
      default_limit: 25,
      max_limit: 50,
      markdown_enables: [:article, :tweet],
      cors_origins: ["*"],
      token_secret: "demo_secret",
      token_validity: 60 * 60 * 24 * 45,
      security_check: 3,
      path_strategy: :raw
    ````

    （上面分别是数据库配置和 Web 服务配置，此处编辑的配置将永久编译到二进制应用中）

    注意了，下面会介绍的环境变量配置方式中的变量的命名和此处的配置一一对应，区别在于环境变量有前缀 `ANYEX_DB` 或 `ANYEX_SERVER`，此外环境变量不支持类似 `60 * 60 * 24 * 45` 这种计算表达式。

1. 数据迁移

    如果您无需使用 Docker 部署应用，通常表示数据库服务已经准备好了。不过如果数据库没有创建的话也可以让应用来创建：

    ```` bash
    MIX_ENV=prod mix db.create
    ````

    数据迁移：

    ```` bash
    MIX_ENV=prod mix db.migrate
    ````

    如果您没有编辑 `*.secret.exs` 配置文件，则需要使用环境变量来传递一些数据库连接信息才能进行正确的迁移（创建数据库同理），例如：

    ```` bash
    ANYEX_DB_NAME=anyex_prod \
    ANYEX_DB_USERNAME=postgres \
    ANYEX_DB_PASSWORD=sampledb123 \
    ANYEX_DB_HOSTNAME=localhost \
    MIX_ENV=prod mix db.migrate
    ````

1. 生成文档

    文档的生成和部署方式无关，如果您可以使用 Docker 建议使用同上的命令。否则您需要自行安装 `openapi-generator-cli`，并使用下面的命令

    ```` bash
    openapi-generator-cli generate \
    -i apps/web_server/priv/static/doc.yaml -g html2 -o apps/web_server/priv/static/doc
    ````

1. 打包应用

    ```` bash
    MIX_ENV=prod mix do clean, deps.get, release
    ````

1. 运行应用

    经过第六步的打包，运行时已经嵌入到构建目录中，此时只需要复制构建结果到任意地方都可以运行，并且不依赖 ERTS（Erlang 运行时）。

    ```` bash
    cp _build/prod/rel/anyex /usr/local/anyex
    ````

    如果您没有编辑 `*.secret.exs` 配置文件，则需要指定环境变量（以下称之为“配置变量”）启动应用，完整的配置变量如下：

    ```` bash
    ANYEX_DB_NAME=anyex_prod \
    ANYEX_DB_USERNAME=postgres \
    ANYEX_DB_PASSWORD=sampledb123 \
    ANYEX_DB_HOSTNAME=localhost \
    ANYEX_SERVER_PORT=8080 \
    ANYEX_SERVER_USERNAME=admin \
    ANYEX_SERVER_PASSWORD=admin123 \
    ANYEX_SERVER_MARKDOWN_ENABLES=article,tweet \
    ANYEX_SERVER_DEFAULT_LIMIT=25 \
    ANYEX_SERVER_MAX_LIMIT=25 \
    ANYEX_SERVER_CORS_ORIGINS="*" \
    ANYEX_SERVER_TOKEN_SECRET=demo_secret \
    ANYEX_SERVER_TOKEN_VALIDITY=3888000 \
    ANYEX_SERVER_SECURITY_CHECK=3 \
    ANYEX_SERVER_PATH_STRATEGY=raw \
    /usr/local/anyex/bin/anyex foreground
    ````

### 配置说明

使用 Docker 容器运行和本地运行的配置方式本质上都是一样的。上面基于 Docker 构建没有“告知”应用连接信息就能迁移数据是因为在 `prod.docker-compose.yml` 中定义了全部的配置变量，而手动编译时如果 `*.secret.exs` 不提供配置信息则需要主动定义配置变量。

应用运行时，定义的环境变量和 `*.secret.exs` 中对应的配置同时存在时环境变量的优先级更高，例如在 `apps/web_server/config/prod.secret.exs` 中定义了 `port: 80` 但同时存在环境变量 `ANYEX_SERVER_PORT=8080` 那么 port 最终将会被设置为 `8080`。

完整的配置变量说明：

* `ANYEX_DB_NAME`: 数据库名称
* `ANYEX_DB_USERNAME`: 数据库用户
* `ANYEX_DB_PASSWORD`: 数据库密码
* `ANYEX_DB_HOSTNAME`: 数据库主机名
* `ANYEX_SERVER_PORT`: Web 服务端口
* `ANYEX_SERVER_USERNAME`: 管理员用户名（申请 Token 的用户名）
* `ANYEX_SERVER_PASSWORD`: 管理员密码（申请 Token 的密码）
* `ANYEX_SERVER_MARKDOWN_ENABLES`: 启用 Markdown 支持的资源列表
* `ANYEX_SERVER_DEFAULT_LIMIT`: 默认的分页限制（没有提供 limit 参数时）
* `ANYEX_SERVER_MAX_LIMIT`: 最大的分页限制（limit 超过此值会被重置为此值）
* `ANYEX_SERVER_CORS_ORIGINS`: 允许跨域的 origin 列表（允许全部的星号切记加上引号："*"）
* `ANYEX_SERVER_TOKEN_SECRET`: Token 密文（用于加解密 Token）
* `ANYEX_SERVER_TOKEN_VALIDITY`: Token 有效期（单位：秒）
* `ANYEX_SERVER_SECURITY_CHECK`: 针对颁发 Token 的安全检查（限制调用频率，单位：秒）
* `ANYEX_SERVER_PATH_STRATEGY`: 路径生成策略（`path` 字段）

### 附加说明

1. 为什么有一个叫做「数据迁移」的步骤，实际作用是“创建数据”？

    因为「数据迁移」只有在面对空数据库时才会有创建全部数据的效果，在已经执行过 `migrate` 的数据库环境中仅会增量的执行需要修改或新增的部分，并保留原有数据。即使面对新版本可能存在的不兼容表结构也能平滑过渡到兼容状态。也就是说，升级到存在不兼容表结构的版本以后，也需要再执行一次 `migrate` 任务。

    所以此步骤实际执行的是迁移数据而非创建数据。可以用二进制发布后的 anyex 或在项目根目录利用 mix 执行这个 `migrate` 任务。

2. 「生成文档」产生了不健全的文档怎么办？

    严格来说这是一个可选的步骤，当前甚至建议可选。它仅作为首页「静态文档」导航链接所指向的页面，如果不生成就会产生一个 404 访问，仅此而已。建议可选是因为 `OSA3` 的生态还不完全健全，导致目前还不能完美的输出 `html2` 形式的文档（Schema 都是空的），并且这个步骤跟 Swagger 文档没有关系，`OSA3` 版本的 Swagger UI 是完美并推荐的。
