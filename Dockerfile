# 构建阶段
FROM maven:3.8.4-openjdk-8 AS builder

# 设置工作目录
WORKDIR /app

COPY settings.xml .

# 复制pom.xml
COPY pom.xml .

# 下载依赖
RUN mvn dependency:go-offline -s /app/settings.xml

# 复制源代码
COPY src ./src

# 构建应用
RUN mvn package -DskipTests -s /app/settings.xml

# 运行阶段
FROM openjdk:8-jre-slim

WORKDIR /app

# 从构建阶段复制jar文件
COPY --from=builder /app/target/*.jar app.jar

# 创建数据目录
RUN mkdir -p /app/data

# 设置数据卷
VOLUME /app/data

ENV SERVER_PORT=8081

# 暴露端口
EXPOSE 8081

# 设置启动命令
CMD ["sh", "-c", "java -jar app.jar --server.port=${SERVER_PORT}"]
