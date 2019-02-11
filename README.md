# AnyEx

快速、易部署、功能完备的博客 API 服务

## 安装指南

如果您没有 Elixir 或 Erlang/OTP 程序的编译和部署经验，推荐使用 Docker 来进行一个傻瓜式的搭建流程，同时也不会污染文件系统（多余的 Erlang/Elixir 运行时和缓存）。

不过在进行下列的流程之前您需要 clone 代码到本地，并进入项目主目录：

```` bash
https://github.com/anyex-project/anyex.git
cd anyex
````

### 基于 Docker

1. 添加配置

    ```` bash
    touch apps/storage/config/prod.secret.exs
    touch apps/web_server/config/prod.secret.exs
    ````

1. 拉取依赖

    ```` bash
    docker run -ti --rm -v $PWD:/code bluerain/elixir:1.8.1-slim mix deps.get
    ````

1. 打包应用

    ```` bash
    docker run -ti --rm -v $PWD:/code bluerain/elixir:1.8.1-slim mix release
    ````

1. 构建镜像

    ```` bash
    docker build . -t bluerain/anyex
    ````

1. 启动应用

    ```` bash
    docker-compose -f prod.docker-compose.yml up -d
    ````

    到这里应用已经启动成功，使用 `curl localhost:8080` 测试会在终端输出 `Welcome to AnyEx!`  
    不过还没有结束。虽然数据库、应用容器都已经被编排好了，参数也都配置好了，但还没有进行表数据生成，如果访问需要操作表的 API 都会返回错误。

1. 数据迁移

    ```` bash
    docker exec -ti anyex_server_1 anyex migrate
    ````

    至此，AnyEx 整个已经部署好了。得益于 Docker Compose 对容器的编排，应用总能在系统重启后自动运行并在进程崩溃时自动重启。

### 手动编译

* 安装 Elixir

    每一种系统（或 Linux 发型版）安装的方式都不同，[这里](https://elixir-lang.org/install.html)是官方的安装指南页面。

1. 添加配置

    ```` bash
    touch apps/storage/config/prod.secret.exs
    touch apps/web_server/config/prod.secret.exs
    ````

    如果您想将配置数据编译到二进制应用中，则需要进行下面的编辑（如果不需要直接看下一步）：

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
    secret: "7EvrcO4jDM"
    ````

    上面分别是数据库配置和 Web 服务配置，此处编辑的配置将永久编译到二进制应用中（如果要打包分发的话）。

1. 数据迁移

    如果您无需使用 Docker 部署应用，通常表示数据库服务已经准备好了。不过如果数据库没有创建的话也可以让应用来创建：

    ```` bash
    MIX_ENV=prod mix db.create
    ````

    数据迁移：

    ```` bash
    MIX_ENV=prod mix db.migrate
    ````

    如果您没有编辑 `.exs` 配置文件，则需要使用环境变量来传递一些数据库连接信息才能进行正确的迁移（创建数据库同理），例如：

    ```` bash
    ANYEX_DB_NAME=anyex_prod \
    ANYEX_DB_USERNAME=postgres \
    ANYEX_DB_PASSWORD=sampledb123 \
    ANYEX_DB_HOSTNAME=localhost \
    MIX_ENV=prod db.migrate
    ````

1. 拉取依赖

    ```` bash
    mix deps.get
    ````

1. 打包应用

    ```` bash
    MIX_ENV=prod mix release
    ````

1. 运行应用

    经过第六步的打包，运行时已经嵌入到构建目录中，此时只需要复制完整的构建结果到任意地方都可以运行，并且无需 Erlang 运行时(ERTS)。

    ```` bash
    cp _build/prod/rel/anyex /usr/local/anyex
    ````

    如果您没有编辑 `.exs` 配置文件，则需要指定环境变量启动应用，完整的配置变量如下：

    ```` bash
    ANYEX_DB_NAME=anyex_prod \
    ANYEX_DB_USERNAME=postgres \
    ANYEX_DB_PASSWORD=sampledb123 \
    ANYEX_DB_HOSTNAME=localhost \
    ANYEX_SERVER_PORT=8080 \
    ANYEX_SERVER_USERNAME=admin \
    ANYEX_SERVER_PASSWORD=admin123 \
    ANYEX_SERVER_SECRET=7EvrcO4jDM \
    /usr/local/anyex/bin/anyex foreground
    ````

### 配置说明

使用 Docker 容器运行和本地运行的配置方式本质上都是一样的。上面基于 Docker 构建没有“告知”应用连接信息就能迁移数据是因为在 prod.docker-compose.yml 中定义了全部的配置变量,而手动编译时如果 `.exs` 不提供配置信息则需要主动定义配置变量。

完整的配置变量说明：

* `ANYEX_DB_NAME`: 数据库名称
* `ANYEX_DB_USERNAME`: 数据库用户
* `ANYEX_DB_PASSWORD`: 数据库密码
* `ANYEX_DB_HOSTNAME`: 数据库主机名
* `ANYEX_SERVER_PORT`: Web 服务端口
* `ANYEX_SERVER_USERNAME`: 管理员用户名（用于申请 Token 的用户名）
* `ANYEX_SERVER_PASSWORD`: 管理员密码（用于申请 Token 的密码）
* `ANYEX_SERVER_SECRET`: Token 密文（用于加解密 Token）

### 附加说明

1. 为什么有一个叫做“数据迁移”的步骤，明明是“创建数据”？

    “数据迁移”并不意味着每一次都是重新创新表结构或表数据，它会智能的根据当前数据库结构来更新需要的部分，而不是傻瓜式的重头执行创建，就类似于应用发布时的“增量更新”概念。这样可以在保证原有数据存在的情况下，迁移到新的表结构上，增量的执行更改表结构的 SQL 语句，以达到即使应用升级后表结构的变动也能保留原有数据并平滑过度到兼容状态的目的。

    可以用二进制发布后的 anyex 或 mix 执行这个 `migrate` 任务。
