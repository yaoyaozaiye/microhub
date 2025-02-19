# microhub
这是一个个人仓库管理系统，方便盘点个人物品，估计家产价值，随时跑路

# 物品管理系统

一个基于Spring Boot的物品管理系统，用于跟踪和管理个人物品。

## 功能特性

- 物品的增删改查
- 物品状态管理
- 标签管理
- 物品搜索
- 响应式界面

## 技术栈

- Java 8
- Spring Boot 2.5.6
- SQLite
- Thymeleaf
- Bootstrap 5.1.3
- Maven

## 本地运行

1. 确保已安装Java 8和Maven
2. 克隆项目
```bash
git clone https://github.com/yourusername/microhub.git
cd microhub
```
3. 运行应用
```bash
mvn spring-boot:run
```
4. 访问 http://localhost:8080

## Docker部署

### 使用docker-compose（推荐）

1. 确保已安装Docker和docker-compose
2. 克隆项目并进入项目目录
3. 运行：
```bash
docker-compose up -d
```
4. 访问 http://localhost:8080

### 手动构建和运行Docker镜像

1. 构建镜像：
```bash
docker build -t storage-system .
```

2. 运行容器：
```bash
docker run -d \
  --name storage-system \
  -p 8080:8080 \
  -v $(pwd)/data:/app/data \
  storage-system
```

3. 访问 http://localhost:8080

## 数据持久化

- 数据库文件位于`data/storage.sqlite`
- Docker部署时，数据通过volume持久化在宿主机的`./data`目录

## 配置说明

可以通过环境变量修改配置：

- `SPRING_DATASOURCE_URL`: 数据库URL，默认为`jdbc:sqlite:storage.sqlite`